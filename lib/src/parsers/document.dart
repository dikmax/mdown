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

    <
        int>[_starCodeUnit, _minusCodeUnit].forEach((int char) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.thematicBreakParser,
        container.blockquoteListParser
      ];
    });

    _blockParsers[_underscoreCodeUnit] = <AbstractParser<Iterable<Block>>>[
      container.thematicBreakParser
    ];

    _blockParsers[_sharpCodeUnit] = <AbstractParser<Iterable<Block>>>[
      container.atxHeadingParser
    ];

    <
        int>[_spaceCodeUnit, _tabCodeUnit].forEach((int char) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.blanklineParser,
        container.indentedCodeParser
      ];
    });

    <
        int>[_newLineCodeUnit, _carriageReturnCodeUnit].forEach((int char) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.blanklineParser
      ];
    });

    <
        int>[_tildeCodeUnit, _backtickCodeUnit].forEach((int char) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.fencedCodeParser
      ];
    });

    <
        int>[_plusCodeUnit, _greaterThanCodeUnit].forEach((int char) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.blockquoteListParser
      ];
    });

    if (container.options.rawHtml) {
      _blockParsers[_lessThanCodeUnit] = <AbstractParser<Iterable<Block>>>[
        container.htmlBlockParser,
        container.htmlBlock7Parser
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

    _inlineParsers[_slashCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.escapesParser
    ];

    _inlineParsers[_ampersandCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.entityParser
    ];

    _inlineParsers[_backtickCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.inlineCodeParser
    ];

    <
        int>[_starCodeUnit, _underscoreCodeUnit].forEach((int char) {
      _inlineParsers[char] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];
    });

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

    if (container.options.strikeout) {
      _inlineParsers[_tildeCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.inlineStructureParser
      ];
    }
  }

  @override
  ParseResult<Document> parse(String text, int offset) {
    int offset = 0;
    List<Block> blocks = <Block>[];

    int length = text.length;
    while (offset < length) {
      int firstChar = _getBlockFirstChar(text, offset);

      if (firstChar == -1) {
        // End of input
        break;
      }

      if (firstChar == _openBracketCodeUnit) {
        // Special treatment for link references.
        // TODO we don't need it
        ParseResult<_LinkReference> res =
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
          ParseResult<Iterable<Block>> res = parser.parse(text, offset);
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

      ParseResult<Iterable<Block>> res =
          container.paraSetextHeadingParser.parse(text, offset);
      assert(res.isSuccess);

      if (res.value.length > 0) {
        blocks.addAll(res.value);
      }
      offset = res.offset;
    }

    Iterable<Block> blocksWithInlines =
        blocks.map((Block block) => _replaceInlinesInBlock(block));

    Document result = new Document(blocksWithInlines);

    return new ParseResult<Document>.success(result, offset);
  }

  Block _replaceInlinesInBlock(Block block) {
    if (block is Heading) {
      Inlines contents = block.contents;
      if (contents is _UnparsedInlines) {
        block.contents = parseInlines(contents.raw);
      }
    } else if (block is Para) {
      Inlines contents = block.contents;
      if (contents is _UnparsedInlines) {
        block.contents = parseInlines(contents.raw);
      }
    } else if (block is Blockquote) {
      block.contents =
          block.contents.map((Block block) => _replaceInlinesInBlock(block));
    } else if (block is ListBlock) {
      block.items = block.items.map((ListItem item) {
        item.contents =
            item.contents.map((Block block) => _replaceInlinesInBlock(block));
        return item;
      });
    }
    return block;
  }

  /// Parses provided string as inlines.
  Inlines parseInlines(String text) {
    int offset = 0;
    Inlines inlines = new Inlines();

    text = text.trimRight();
    int length = text.length;
    while (offset < length) {
      int codeUnit = text.codeUnitAt(offset);
      if (codeUnit == _exclamationMarkCodeUnit &&
          offset + 1 < length &&
          text.codeUnitAt(offset + 1) == _openBracketCodeUnit) {
        // Exclamation mark without bracket means nothing.
        ParseResult<Inlines> res =
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
          ParseResult<Inlines> res = parser.parse(text, offset);
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

      ParseResult<Inlines> res = container.strParser.parse(text, offset);
      assert(res.isSuccess);

      if (res.value.length > 0) {
        inlines.addAll(res.value);
      }
      offset = res.offset;
    }

    return inlines;
  }
}
