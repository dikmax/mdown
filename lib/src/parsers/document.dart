part of md_proc.src.parsers;

class DocumentParser extends AbstractParser<Document> {
  Map<int, List<AbstractParser<Iterable<Block>>>> _blockParsers;

  Map<int, List<AbstractParser<Iterable<Inline>>>> _inlineParsers;

  DocumentParser(ParsersContainer container) : super(container);

  @override
  void init() {
    // Block parsers
    _blockParsers = new HashMap<int, List<AbstractParser<Iterable<Block>>>>();

    <
        int>[_STAR_CODE_UNIT, _MINUS_CODE_UNIT].forEach((int char) {
      _blockParsers[char] = [
        container.thematicBreakParser,
        container.blockquoteListParser
      ];
    });

    _blockParsers[_UNDERSCORE_CODE_UNIT] = [container.thematicBreakParser];

    _blockParsers[_SHARP_CODE_UNIT] = [container.atxHeadingParser];

    <
        int>[_SPACE_CODE_UNIT, _TAB_CODE_UNIT].forEach((int char) {
      _blockParsers[char] = [
        container.blanklineParser,
        container.indentedCodeParser
      ];
    });

    <
            int>[_NEWLINE_CODE_UNIT, _CARRIAGE_RETURN_CODE_UNIT]
        .forEach((int char) {
      _blockParsers[char] = [container.blanklineParser];
    });

    <
        int>[_TILDE_CODE_UNIT, _BACKTICK_CODE_UNIT].forEach((int char) {
      _blockParsers[char] = [container.fencedCodeParser];
    });

    <
        int>[_PLUS_CODE_UNIT, _GREATER_THAN_CODE_UNIT].forEach((int char) {
      _blockParsers[char] = [container.blockquoteListParser];
    });

    if (container.options.rawHtml) {
      _blockParsers[_LESS_THAN_CODE_UNIT] = [
        container.htmlBlockParser,
        container.htmlBlock7Parser
      ];
    }

    for (int char = _ZERO_CODE_UNIT; char <= _NINE_CODE_UNIT; char++) {
      _blockParsers[char] = [container.blockquoteListParser];
    }

    // Inline parsers
    _inlineParsers = new HashMap<int, List<AbstractParser<Iterable<Inline>>>>();

    _inlineParsers[_SPACE_CODE_UNIT] = [container.hardLineBreakParser];

    _inlineParsers[_TAB_CODE_UNIT] = [container.hardLineBreakParser];

    _inlineParsers[_SLASH_CODE_UNIT] = [container.escapesParser];

    _inlineParsers[_AMPERSAND_CODE_UNIT] = [container.entityParser];

    _inlineParsers[_BACKTICK_CODE_UNIT] = [container.inlineCodeParser];

    <
        int>[_STAR_CODE_UNIT, _UNDERSCORE_CODE_UNIT].forEach((int char) {
      _inlineParsers[char] = [container.inlineStructureParser];
    });

    _inlineParsers[_OPEN_BRACKET_CODE_UNIT] = [container.linkImageParser];

    _inlineParsers[_LESS_THAN_CODE_UNIT] = [container.autolinkParser];

    if (container.options.rawHtml) {
      _inlineParsers[_LESS_THAN_CODE_UNIT].add(container.inlineHtmlParser);
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

      if (firstChar == _OPEN_BRACKET_CODE_UNIT) {
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

  Inlines parseInlines(String text) {
    int offset = 0;
    Inlines inlines = new Inlines();

    text = text.trimRight();
    int length = text.length;
    while (offset < length) {
      int codeUnit = text.codeUnitAt(offset);
      if (codeUnit == _EXCLAMATION_MARK_CODE_UNIT &&
          offset + 1 < length &&
          text.codeUnitAt(offset + 1) == _OPEN_BRACKET_CODE_UNIT) {
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
