part of md_proc.src.parsers;

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

    for (int char in <int>[_starCodeUnit, _minusCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.thematicBreakParser,
        container.blockquoteListParser
      ];
    }

    _blockParsers[_underscoreCodeUnit] = <AbstractParser<Iterable<Block>>>[
      container.thematicBreakParser
    ];

    _blockParsers[_sharpCodeUnit] = <AbstractParser<Iterable<Block>>>[
      container.atxHeadingParser
    ];

    for (int char in <int>[_spaceCodeUnit, _tabCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.blanklineParser,
        container.indentedCodeParser
      ];
    }

    for (int char in <int>[_newLineCodeUnit, _carriageReturnCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.blanklineParser
      ];
    }

    for (int char in <int>[_tildeCodeUnit, _backtickCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.fencedCodeParser
      ];
    }

    for (int char in <int>[_plusCodeUnit, _greaterThanCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.blockquoteListParser
      ];
    }

    if (container.options.rawHtml) {
      _blockParsers[_lessThanCodeUnit] = <AbstractParser<Iterable<Block>>>[
        container.htmlBlockParser,
        container.htmlBlock7Parser
      ];
    }

    if (container.options.rawTex) {
      _blockParsers[_backslashCodeUnit] = <AbstractParser<Iterable<Block>>>[
        container.rawTexParser
      ];
    }

    for (int char = _zeroCodeUnit; char <= _nineCodeUnit; char++) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.blockquoteListParser
      ];
    }

    // Inline parsers
    _inlineParsers = new HashMap<int, List<AbstractParser<Iterable<Inline>>>>();

    _inlineParsers[_spaceCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[_tabCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[_backslashCodeUnit] = <AbstractParser<Iterable<Inline>>>[];

    if (container.options.texMathSingleBackslash) {
      _inlineParsers[_backslashCodeUnit]
          .add(container.texMathSingleBackslashParser);
    }

    if (container.options.texMathDoubleBackslash) {
      _inlineParsers[_backslashCodeUnit]
          .add(container.texMathDoubleBackslashParser);
    }
    _inlineParsers[_backslashCodeUnit].add(container.escapesParser);

    _inlineParsers[_ampersandCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.entityParser
    ];

    _inlineParsers[_backtickCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.inlineCodeParser
    ];

    for (int char in <
        int>[_starCodeUnit, _underscoreCodeUnit]) {
      _inlineParsers[char] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];
    }

    _inlineParsers[_openBracketCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.linkImageParser
    ];

    _inlineParsers[_lessThanCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.autolinkParser
    ];

    if (container.options.rawHtml) {
      _inlineParsers[_lessThanCodeUnit].add(container.inlineHtmlParser);
    }

    if (container.options.smartPunctuation) {
      _inlineParsers[_dotCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.ellipsisParser
      ];

      _inlineParsers[_minusCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.mnDashParser
      ];

      _inlineParsers[_singleQuoteCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];

      _inlineParsers[_doubleQuoteCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];
    }

    if (container.options.strikeout || container.options.subscript) {
      _inlineParsers[_tildeCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];
    }

    if (container.options.superscript) {
      _inlineParsers[_caretCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];
    }

    if (container.options.texMathDollars) {
      _inlineParsers[_dollarCodeUnit] = <AbstractParser<Iterable<Inline>>>[
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
      final int firstChar = _getBlockFirstChar(text, offset);

      if (firstChar == -1) {
        // End of input
        break;
      }

      if (firstChar == _openBracketCodeUnit) {
        // Special treatment for link references.
        // TODO we don't need it
        final ParseResult<_LinkReference> res =
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
      if (contents is _UnparsedInlines) {
        block.contents = parseInlines(contents.raw);
      }
    } else if (block is Para) {
      final Inlines contents = block.contents;
      if (contents is _UnparsedInlines) {
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
      if (codeUnit == _exclamationMarkCodeUnit &&
          offset + 1 < length &&
          text.codeUnitAt(offset + 1) == _openBracketCodeUnit) {
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
