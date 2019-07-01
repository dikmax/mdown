library mdown.src.parsers.para_setext_heading;

import 'dart:collection';

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/ast/combining_nodes.dart';
import 'package:mdown/src/ast/unparsed_inlines.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/lookup.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Fast checks block, if it starts with [charCodeUnit1] or [charCodeUnit2],
/// taking indent into account.
bool fastBlockTest2(
    String text, int offset, int charCodeUnit1, int charCodeUnit2) {
  final int nonIndentOffset = skipIndent(text, offset);

  if (nonIndentOffset == -1) {
    return false;
  }

  final int codeUnit = text.codeUnitAt(nonIndentOffset);
  return codeUnit == charCodeUnit1 || codeUnit == charCodeUnit2;
}

/// Parser for paragraphs and setext headings.
class ParaSetextHeadingParser extends AbstractParser<BlockNodeImpl> {
  /// Constructor.
  ParaSetextHeadingParser(ParsersContainer container) : super(container);

  static final RegExp _setextHeadingRegExp = RegExp('^ {0,3}(-+|=+)[ \t]*\$');

  static final Pattern _listSimpleTest = RegExp(r'([+\-*]|1[.)])( |$)');

  Map<int, List<Lookup>> _paragraphBreaks;

  @override
  void init() {
    _paragraphBreaks = HashMap<int, List<Lookup>>();

    _paragraphBreaks[starCodeUnit] = <Lookup>[thematicBreakLookup];
    _paragraphBreaks[minusCodeUnit] = <Lookup>[thematicBreakLookup];
    _paragraphBreaks[underscoreCodeUnit] = <Lookup>[thematicBreakLookup];

    _paragraphBreaks[backtickCodeUnit] = <Lookup>[fencedCodeStartLookup];
    _paragraphBreaks[sharpCodeUnit] = <Lookup>[atxHeadingLookup];
    _paragraphBreaks[greaterThanCodeUnit] = <Lookup>[blockquoteSimpleLookup];

    if (container.options.rawHtml) {
      _paragraphBreaks[lessThanCodeUnit] = <Lookup>[
        htmlBlock1Lookup,
        htmlBlock2Lookup,
        htmlBlock3Lookup,
        htmlBlock4Lookup,
        htmlBlock5Lookup
      ];
    }
  }

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    int off = offset;
    final List<String> contents = <String>[];
    bool canBeHeading = false;
    int level = 0;
    final int length = text.length;

    BlockNodeImpl listAddition;

    while (off < length) {
      final ParseResult<String> lineResult =
          container.lineParser.parse(text, off);
      assert(lineResult.isSuccess, 'lineParser should always succeed');

      final String line = lineResult.value;

      if (!isOnlyWhitespace(line)) {
        if (canBeHeading) {
          if (fastBlockTest2(text, off, minusCodeUnit, equalCodeUnit)) {
            final Match match = _setextHeadingRegExp.firstMatch(line);
            if (match != null) {
              level = match[1][0] == '=' ? 1 : 2;
              off = lineResult.offset;
              break;
            }
          }
        }

        final int indent = skipIndent(lineResult.value, 0);
        if (indent != -1 && contents.isNotEmpty) {
          final int codeUnit = lineResult.value.codeUnitAt(indent);
          final List<Lookup> lookups = _paragraphBreaks[codeUnit];
          if (lookups != null &&
              lookups.any((Lookup lookup) =>
                  lookup.isFound(lineResult.value, indent))) {
            // Paragraph stops here as we've got another block.
            break;
          }
        }

        // Special check for html block rule 6.
        if (container.options.rawHtml) {
          final Match htmlBlock6Match =
              htmlBlock6Test.matchAsPrefix(lineResult.value, indent);
          if (htmlBlock6Match != null) {
            final String tag = htmlBlock6Match[1];
            if (blockTags.contains(tag.toLowerCase())) {
              break;
            }
          }
        }

        // Special check for list, as it can break paragraph only if not empty
        // Ordered lists are also required to start with 1. to allow breaking.
        if (lineResult.value.startsWith(_listSimpleTest, indent)) {
          // It could be a list.

          final ParseResult<BlockNodeImpl> listResult =
              container.blockquoteListParser.parse(text, off);
          if (listResult.isSuccess) {
            // It's definitely a list
            BlockNodeImpl firstBlock = listResult.value;
            if (firstBlock is CombiningBlockNodeImpl) {
              final CombiningBlockNodeImpl combining = firstBlock;
              firstBlock = combining.list.first;
            }
            if (firstBlock is ListBlockImpl) {
              if (firstBlock.items.isNotEmpty &&
                  firstBlock.items.first.contents.isNotEmpty) {
                // It's not empty list, append it in the end and stop parsing.

                off = listResult.offset;
                listAddition = listResult.value;
                break;
              }
            }
          }
        }

        int trimOffset = 0;
        final int length = line.length;
        while (trimOffset < length) {
          final int codeUnit = line.codeUnitAt(trimOffset);
          if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
            break;
          }
          trimOffset++;
        }
        contents.add(trimOffset > 0 ? line.substring(trimOffset) : line);
        canBeHeading = true;
      } else {
        // Empty line should be parsed by blank line parser.
        // List tightness rely on this. So, we exit here.
        break;
      }
      off = lineResult.offset;
    }

    String contentsString = contents.join('\n');
    if (level > 0) {
      ExtendedAttributes attr;
      if (container.options.headingAttributes) {
        if (contentsString.codeUnitAt(contentsString.length - 1) ==
            closeBraceCodeUnit) {
          final int attributesStart = contentsString.lastIndexOf('{');
          final ParseResult<Attributes> attributesResult =
              container.attributesParser.parse(contentsString, attributesStart);
          if (attributesResult.isSuccess) {
            contentsString = contentsString.substring(0, attributesStart);
            attr = attributesResult.value;
          }
        }
      }
      final BaseInline inlines = UnparsedInlinesImpl(contentsString);

      return ParseResult<BlockNodeImpl>.success(
          HeadingImpl(inlines, level, attr), off);
    }

    final BaseInline inlines = UnparsedInlinesImpl(contentsString);

    if (listAddition != null) {
      final List<BlockNodeImpl> result = <BlockNodeImpl>[ParaImpl(inlines)];
      if (listAddition is CombiningBlockNodeImpl) {
        final CombiningBlockNodeImpl combining = listAddition;
        result.addAll(combining.list);
      } else {
        result.add(listAddition);
      }
      return ParseResult<BlockNodeImpl>.success(
          CombiningBlockNodeImpl(result), off);
    }
    return ParseResult<BlockNodeImpl>.success(ParaImpl(inlines), off);
  }
}
