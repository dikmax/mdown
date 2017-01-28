library mdown.src.parsers.para_setext_heading;

import 'dart:collection';

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/ast/combining_nodes.dart';
import 'package:mdown/src/ast/unparsed_inlines.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/code_units_list.dart';
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
class ParaSetextHeadingParser extends AbstractStringParser<BlockNodeImpl> {
  static final RegExp _setextHeadingRegExp =
      new RegExp('^ {0,3}(-+|=+)[ \t]*\$');

  static final Pattern _listSimpleTest = new RegExp(r'([+\-*]|1[.)])( |$)');

  Map<int, List<Lookup>> _paragraphBreaks;

  /// Constructor.
  ParaSetextHeadingParser(ParsersContainer container) : super(container);

  @override
  void init() {
    _paragraphBreaks = new HashMap<int, List<Lookup>>();

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
    final List<String> contents = <String>[];
    bool canBeHeading = false;
    int level = 0;
    final int length = text.length;

    BlockNodeImpl listAddition;

    while (offset < length) {
      final ParseResult<String> lineResult =
          container.lineParser.parse(text, offset);
      assert(lineResult.isSuccess);

      final String line = lineResult.value;

      if (!isOnlyWhitespace(line)) {
        if (canBeHeading) {
          if (fastBlockTest2(text, offset, minusCodeUnit, equalCodeUnit)) {
            final Match match = _setextHeadingRegExp.firstMatch(line);
            if (match != null) {
              level = match[1][0] == '=' ? 1 : 2;
              offset = lineResult.offset;
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
        final Match htmlBlock6Match =
            htmlBlock6Test.matchAsPrefix(lineResult.value, indent);
        if (htmlBlock6Match != null) {
          final String tag = htmlBlock6Match[1];
          if (blockTags.contains(tag.toLowerCase())) {
            break;
          }
        }

        // Special check for list, as it can break paragraph only if not empty
        // Ordered lists are also required to start with 1. to allow breaking.
        if (lineResult.value.startsWith(_listSimpleTest, indent)) {
          // It could be a list.

          final ParseResult<BlockNodeImpl> listResult =
              container.blockquoteListParser.parse(text, offset);
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

                offset = listResult.offset;
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
      offset = lineResult.offset;
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
      final BaseInline inlines =
          new UnparsedInlinesImpl(new CodeUnitsList.string(contentsString));

      return new ParseResult<BlockNodeImpl>.success(
          new HeadingImpl(inlines, level, attr), offset);
    }

    final BaseInline inlines =
        new UnparsedInlinesImpl(new CodeUnitsList.string(contentsString));

    if (listAddition != null) {
      final List<BlockNodeImpl> result = <BlockNodeImpl>[new ParaImpl(inlines)];
      if (listAddition is CombiningBlockNodeImpl) {
        final CombiningBlockNodeImpl combining = listAddition;
        result.addAll(combining.list);
      } else {
        result.add(listAddition);
      }
      return new ParseResult<BlockNodeImpl>.success(
          new CombiningBlockNodeImpl(result), offset);
    }
    return new ParseResult<BlockNodeImpl>.success(
        new ParaImpl(inlines), offset);
  }
}
