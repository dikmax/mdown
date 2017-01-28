library mdown.src.parsers.document;

import 'dart:collection';

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/standard_ast_factory.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/ast/combining_nodes.dart';
import 'package:mdown/src/ast/replacing_visitor.dart';
import 'package:mdown/src/ast/unparsed_inlines.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/code_units_list.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

class ListInlineParsingVisitor extends ListReplacingAstVisitor {}

class InlineParsingVisitor extends ReplacingAstVisitor
    implements UnparsedInlinesVisitor<AstNodeImpl> {
  final DocumentParser _documentParser;

  InlineParsingVisitor(this._documentParser);

  @override
  BaseCompositeInlineImpl visitUnparsedInlines(UnparsedInlines node) {
    final List<InlineNodeImpl> contents =
        _documentParser.parseInlines(node.contents);
    return astFactory.baseCompositeInline(contents);
  }
}

/// Parser for whole document.
class DocumentParser extends AbstractStringParser<Document> {
  Map<int, List<AbstractParser<BlockNodeImpl>>> _blockParsers;

  List<AbstractParser<BlockNodeImpl>> _blockParsersRest;

  Map<int, List<AbstractParser<InlineNodeImpl>>> _inlineParsers;

  /// Constructor.
  DocumentParser(ParsersContainer container) : super(container);

  @override
  void init() {
    // Block parsers
    _blockParsers = new HashMap<int, List<AbstractParser<BlockNodeImpl>>>();

    for (int char in <int>[starCodeUnit, minusCodeUnit]) {
      _blockParsers[char] = <AbstractParser<BlockNodeImpl>>[
        container.thematicBreakParser,
        container.blockquoteListParser
      ];
    }

    _blockParsers[underscoreCodeUnit] = <AbstractParser<BlockNodeImpl>>[
      container.thematicBreakParser
    ];

    _blockParsers[sharpCodeUnit] = <AbstractParser<BlockNodeImpl>>[
      container.atxHeadingParser
    ];

    for (int char in <int>[spaceCodeUnit, tabCodeUnit]) {
      _blockParsers[char] = <AbstractParser<BlockNodeImpl>>[
        container.blanklineParser,
        container.indentedCodeParser
      ];
    }

    for (int char in <int>[newLineCodeUnit, carriageReturnCodeUnit]) {
      _blockParsers[char] = <AbstractParser<BlockNodeImpl>>[
        container.blanklineParser
      ];
    }

    for (int char in <int>[tildeCodeUnit, backtickCodeUnit]) {
      _blockParsers[char] = <AbstractParser<BlockNodeImpl>>[
        container.fencedCodeParser
      ];
    }

    for (int char in <int>[plusCodeUnit, greaterThanCodeUnit]) {
      _blockParsers[char] = <AbstractParser<BlockNodeImpl>>[
        container.blockquoteListParser
      ];
    }

    if (container.options.rawHtml) {
      _blockParsers[lessThanCodeUnit] = <AbstractParser<BlockNodeImpl>>[
        container.htmlBlockParser,
        container.htmlBlock7Parser
      ];
    }

    if (container.options.rawTex) {
      _blockParsers[backslashCodeUnit] = <AbstractParser<BlockNodeImpl>>[
        container.rawTexParser
      ];
    }

    for (int char = zeroCodeUnit; char <= nineCodeUnit; char++) {
      _blockParsers[char] = <AbstractParser<BlockNodeImpl>>[
        container.blockquoteListParser
      ];
    }

    // Rest of block parsers
    _blockParsersRest = <AbstractParser<BlockNodeImpl>>[];
    if (container.options.pipeTables) {
      _blockParsersRest.add(container.pipeTablesParser);
    }
    _blockParsersRest.add(container.paraSetextHeadingParser);

    // Inline parsers
    _inlineParsers = new HashMap<int, List<AbstractParser<InlineNodeImpl>>>();

    _inlineParsers[spaceCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[tabCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[backslashCodeUnit] = <AbstractParser<InlineNodeImpl>>[];

    if (container.options.texMathSingleBackslash) {
      _inlineParsers[backslashCodeUnit]
          .add(container.texMathSingleBackslashParser);
    }

    if (container.options.texMathDoubleBackslash) {
      _inlineParsers[backslashCodeUnit]
          .add(container.texMathDoubleBackslashParser);
    }
    _inlineParsers[backslashCodeUnit].add(container.escapesParser);

    _inlineParsers[ampersandCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.entityParser
    ];

    _inlineParsers[backtickCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.inlineCodeParser
    ];

    for (int char in <int>[starCodeUnit, underscoreCodeUnit]) {
      _inlineParsers[char] = <AbstractParser<InlineNodeImpl>>[
        container.inlineStructureParser
      ];
    }

    _inlineParsers[openBracketCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.linkImageParser
    ];

    _inlineParsers[lessThanCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.autolinkParser
    ];

    if (container.options.rawHtml) {
      _inlineParsers[lessThanCodeUnit].add(container.inlineHtmlParser);
    }

    if (container.options.smartPunctuation) {
      _inlineParsers[dotCodeUnit] = <AbstractParser<InlineNodeImpl>>[
        container.ellipsisParser
      ];

      _inlineParsers[minusCodeUnit] = <AbstractParser<InlineNodeImpl>>[
        container.mnDashParser
      ];

      _inlineParsers[singleQuoteCodeUnit] = <AbstractParser<InlineNodeImpl>>[
        container.inlineStructureParser
      ];

      _inlineParsers[doubleQuoteCodeUnit] = <AbstractParser<InlineNodeImpl>>[
        container.inlineStructureParser
      ];
    }

    if (container.options.strikeout || container.options.subscript) {
      _inlineParsers[tildeCodeUnit] = <AbstractParser<InlineNodeImpl>>[
        container.inlineStructureParser
      ];
    }

    if (container.options.superscript) {
      _inlineParsers[caretCodeUnit] = <AbstractParser<InlineNodeImpl>>[
        container.inlineStructureParser
      ];
    }

    if (container.options.texMathDollars) {
      _inlineParsers[dollarCodeUnit] = <AbstractParser<InlineNodeImpl>>[
        container.texMathDollarsParser
      ];
    }
  }

  @override
  ParseResult<Document> parse(String text, int offset) {
    int offset = 0;
    final List<BlockNodeImpl> blocks = <BlockNodeImpl>[];

    final int length = text.length;
    while (offset < length) {
      final int firstChar = getBlockFirstChar(text, offset);

      if (firstChar == -1) {
        // End of input
        break;
      }

      if (firstChar == openBracketCodeUnit) {
        // Special treatment for link references.
        // TODO we don't need it
        final ParseResult<LinkReferenceImpl> res =
            container.linkReferenceParser.parse(text, offset);
        if (res.isSuccess) {
          final String referenceString = res.value.normalizedReference;
          if (!container.references.containsKey(referenceString)) {
            container.references[referenceString] = res.value;
          }
          offset = res.offset;
          continue;
        }
      } else if (_blockParsers.containsKey(firstChar)) {
        bool found = false;
        for (AbstractParser<BlockNodeImpl> parser in _blockParsers[firstChar]) {
          final ParseResult<BlockNodeImpl> res = parser.parse(text, offset);
          if (res.isSuccess) {
            if (res.value != null) {
              if (res.value is CombiningBlockNodeImpl) {
                final CombiningBlockNodeImpl combining = res.value;
                blocks.addAll(combining.list);
              } else {
                blocks.add(res.value);
              }
            }
            offset = res.offset;
            found = true;
            break;
          }
        }

        if (found) {
          continue;
        }
      }

      for (AbstractParser<BlockNodeImpl> parser in _blockParsersRest) {
        final ParseResult<BlockNodeImpl> res = parser.parse(text, offset);
        if (res.isSuccess) {
          if (res.value != null) {
            if (res.value is CombiningBlockNodeImpl) {
              final CombiningBlockNodeImpl combining = res.value;
              blocks.addAll(combining.list);
            } else {
              blocks.add(res.value);
            }
          }
          offset = res.offset;
          break;
        }
      }
    }

    final InlineParsingVisitor visitor = new InlineParsingVisitor(this);
    final int blocksLength = blocks.length;
    final List<BlockNodeImpl> blocksWithInlines =
        new List<BlockNodeImpl>(blocksLength);
    for (int i = 0; i < blocksLength; ++i) {
      blocksWithInlines[i] = blocks[i].accept<AstNode>(visitor) as BlockNode;
    }

    final Document result = astFactory.document(blocksWithInlines);

    return new ParseResult<Document>.success(result, offset);
  }

  /// Parses provided string as inlines.
  List<InlineNodeImpl> parseInlines(CodeUnitsList list) {
    int offset = 0;
    final List<InlineNodeImpl> inlines = <InlineNodeImpl>[];

    list = list.trimRight();
    final int length = list.length;
    while (offset < length) {
      final int codeUnit = list[offset];
      if (codeUnit == exclamationMarkCodeUnit &&
          offset + 1 < length &&
          list[offset + 1] == openBracketCodeUnit) {
        // Exclamation mark without bracket means nothing.
        final ParseResult<InlineNodeImpl> res =
            container.linkImageParser.parseList(list, offset);
        if (res.isSuccess) {
          if (res.value != null) {
            // Link image parser doesn't return combining nodes.
            inlines.add(res.value);
          }
          offset = res.offset;
          continue;
        }
      } else if (_inlineParsers.containsKey(codeUnit)) {
        bool found = false;
        for (AbstractParser<InlineNodeImpl> parser
            in _inlineParsers[codeUnit]) {
          final ParseResult<InlineNodeImpl> res = parser.parseList(list, offset);
          if (res.isSuccess) {
            if (res.value != null) {
              if (res.value is CombiningInlineNodeImpl) {
                final CombiningInlineNodeImpl combining = res.value;
                inlines.addAll(combining.list);
              } else {
                inlines.add(res.value);
              }
            }
            offset = res.offset;
            found = true;
            break;
          }
        }

        if (found) {
          continue;
        }
      }

      final ParseResult<InlineNodeImpl> res =
          container.strParser.parseList(list, offset);
      assert(res.isSuccess);

      inlines.add(res.value);
      offset = res.offset;
    }

    return inlines;
  }
}
