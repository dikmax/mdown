library md_proc.src.parsers.document;

import 'dart:collection';
import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/inlines.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/common.dart';
import 'package:md_proc/src/parsers/container.dart';
import 'package:md_proc/src/parsers/link_reference.dart';

/// Parser for whole document.
class DocumentParser extends AbstractParser<Document> {
  Map<int, List<AbstractParser<Iterable<Block>>>> _blockParsers;

  Map<int, List<AbstractParser<Iterable<Inline>>>> _inlineParsers;

  /// Constructor.
  DocumentParser(ParsersContainer container) : super(container);

  @override
  void init() {
    // Block parsers
    _blockParsers = new HashMap<int, List<AbstractParser<Iterable<Block>>>>();

    for (int char in <int>[starCodeUnit, minusCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.thematicBreakParser,
        container.blockquoteListParser
      ];
    }

    _blockParsers[underscoreCodeUnit] = <AbstractParser<Iterable<Block>>>[
      container.thematicBreakParser
    ];

    _blockParsers[sharpCodeUnit] = <AbstractParser<Iterable<Block>>>[
      container.atxHeadingParser
    ];

    for (int char in <int>[spaceCodeUnit, tabCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.blanklineParser,
        container.indentedCodeParser
      ];
    }

    for (int char in <int>[newLineCodeUnit, carriageReturnCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.blanklineParser
      ];
    }

    for (int char in <int>[tildeCodeUnit, backtickCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.fencedCodeParser
      ];
    }

    for (int char in <int>[plusCodeUnit, greaterThanCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.blockquoteListParser
      ];
    }

    if (container.options.rawHtml) {
      _blockParsers[lessThanCodeUnit] = <AbstractParser<Iterable<Block>>>[
        container.htmlBlockParser,
        container.htmlBlock7Parser
      ];
    }

    if (container.options.rawTex) {
      _blockParsers[backslashCodeUnit] = <AbstractParser<Iterable<Block>>>[
        container.rawTexParser
      ];
    }

    for (int char = zeroCodeUnit; char <= nineCodeUnit; char++) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.blockquoteListParser
      ];
    }

    // Inline parsers
    _inlineParsers = new HashMap<int, List<AbstractParser<Iterable<Inline>>>>();

    _inlineParsers[spaceCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[tabCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[backslashCodeUnit] = <AbstractParser<Iterable<Inline>>>[];

    if (container.options.texMathSingleBackslash) {
      _inlineParsers[backslashCodeUnit]
          .add(container.texMathSingleBackslashParser);
    }

    if (container.options.texMathDoubleBackslash) {
      _inlineParsers[backslashCodeUnit]
          .add(container.texMathDoubleBackslashParser);
    }
    _inlineParsers[backslashCodeUnit].add(container.escapesParser);

    _inlineParsers[ampersandCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.entityParser
    ];

    _inlineParsers[backtickCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.inlineCodeParser
    ];

    for (int char in <
        int>[starCodeUnit, underscoreCodeUnit]) {
      _inlineParsers[char] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];
    }

    _inlineParsers[openBracketCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.linkImageParser
    ];

    _inlineParsers[lessThanCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.autolinkParser
    ];

    if (container.options.rawHtml) {
      _inlineParsers[lessThanCodeUnit].add(container.inlineHtmlParser);
    }

    if (container.options.smartPunctuation) {
      _inlineParsers[dotCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.ellipsisParser
      ];

      _inlineParsers[minusCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.mnDashParser
      ];

      _inlineParsers[singleQuoteCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];

      _inlineParsers[doubleQuoteCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];
    }

    if (container.options.strikeout || container.options.subscript) {
      _inlineParsers[tildeCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];
    }

    if (container.options.superscript) {
      _inlineParsers[caretCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];
    }

    if (container.options.texMathDollars) {
      _inlineParsers[dollarCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.texMathDollarsParser
      ];
    }
  }

  @override
  ParseResult<Document> parse(String text, int offset) {
    int offset = 0;
    final List<Block> blocks = <Block>[];

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
        final ParseResult<LinkReference> res =
            container.linkReferenceParser.parse(text, offset);
        if (res.isSuccess) {
          if (!container.references.containsKey(res.value.reference)) {
            container.references[res.value.reference] = res.value.target;
          }
          offset = res.offset;
          continue;
        }
      } else if (_blockParsers.containsKey(firstChar)) {
        bool found = false;
        for (AbstractParser<Iterable<Block>> parser
            in _blockParsers[firstChar]) {
          final ParseResult<Iterable<Block>> res = parser.parse(text, offset);
          if (res.isSuccess) {
            if (res.value.length > 0) {
              blocks.addAll(res.value);
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

      final ParseResult<Iterable<Block>> res =
          container.paraSetextHeadingParser.parse(text, offset);
      assert(res.isSuccess);

      if (res.value.length > 0) {
        blocks.addAll(res.value);
      }
      offset = res.offset;
    }

    final Iterable<Block> blocksWithInlines =
        blocks.map(_replaceInlinesInBlock);

    final Document result = new Document(blocksWithInlines);

    return new ParseResult<Document>.success(result, offset);
  }

  Block _replaceInlinesInBlock(Block block) {
    if (block is Heading) {
      final Inlines contents = block.contents;
      if (contents is UnparsedInlines) {
        block.contents = parseInlines(contents.raw);
      }
    } else if (block is Para) {
      final Inlines contents = block.contents;
      if (contents is UnparsedInlines) {
        block.contents = parseInlines(contents.raw);
      }
    } else if (block is Blockquote) {
      block.contents = block.contents.map(_replaceInlinesInBlock);
    } else if (block is ListBlock) {
      block.items = block.items.map(_replaceInlinesInListItem);
    }
    return block;
  }

  ListItem _replaceInlinesInListItem(ListItem item) {
    item.contents = item.contents.map(_replaceInlinesInBlock);
    return item;
  }

  /// Parses provided string as inlines.
  Inlines parseInlines(String text) {
    int offset = 0;
    final Inlines inlines = new Inlines();

    text = text.trimRight();
    final int length = text.length;
    while (offset < length) {
      final int codeUnit = text.codeUnitAt(offset);
      if (codeUnit == exclamationMarkCodeUnit &&
          offset + 1 < length &&
          text.codeUnitAt(offset + 1) == openBracketCodeUnit) {
        // Exclamation mark without bracket means nothing.
        final ParseResult<Inlines> res =
            container.linkImageParser.parse(text, offset);
        if (res.isSuccess) {
          if (res.value.length > 0) {
            inlines.addAll(res.value);
          }
          offset = res.offset;
          continue;
        }
      } else if (_inlineParsers.containsKey(codeUnit)) {
        bool found = false;
        for (AbstractParser<Inlines> parser in _inlineParsers[codeUnit]) {
          final ParseResult<Inlines> res = parser.parse(text, offset);
          if (res.isSuccess) {
            if (res.value.length > 0) {
              inlines.addAll(res.value);
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

      final ParseResult<Inlines> res = container.strParser.parse(text, offset);
      assert(res.isSuccess);

      if (res.value.length > 0) {
        inlines.addAll(res.value);
      }
      offset = res.offset;
    }

    return inlines;
  }
}
