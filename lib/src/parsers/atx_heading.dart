part of md_proc.src.parsers;

/// Parser for ATX-headings.
class AtxHeadingParser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  AtxHeadingParser(ParsersContainer container) : super(container);

  static const int _stateOpen = 0;
  static const int _stateSpaces = 1;
  static const int _stateText = 2;
  static const int _stateClose = 3;
  static const int _stateAfterClose = 4;

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    ParseResult<String> lineResult = container.lineParser.parse(text, offset);

    assert(lineResult.isSuccess);

    String line = lineResult.value;
    int length = line.length;

    int level = 1;
    int state = _stateOpen;
    int startOffset = -1;
    int endOffset = -1;

    int i = _skipIndent(line, 0) + 1;

    // Finite Automata
    while (i < length) {
      int code = line.codeUnitAt(i);

      switch (state) {
        case _stateOpen:
          if (code == _sharpCodeUnit) {
            level++;
            if (level > 6) {
              return const ParseResult<Iterable<Block>>.failure();
            }
          } else if (code == _spaceCodeUnit || code == _tabCodeUnit) {
            state = _stateSpaces;
          } else {
            return const ParseResult<Iterable<Block>>.failure();
          }

          break;

        case _stateSpaces:
          if (code != _spaceCodeUnit && code != _tabCodeUnit) {
            startOffset = startOffset != -1 ? startOffset : i;
            if (code == _sharpCodeUnit) {
              endOffset = i;
              state = _stateClose;
            } else {
              state = _stateText;
            }
          }
          break;

        case _stateText:
          if (code == _spaceCodeUnit || code == _tabCodeUnit) {
            endOffset = i;
            state = _stateSpaces;
          } else if (code == _backslashCodeUnit) {
            i++;
          }
          break;

        case _stateClose:
          if (code == _spaceCodeUnit || code == _tabCodeUnit) {
            state = _stateAfterClose;
          } else if (code != _sharpCodeUnit) {
            state = _stateText;
            endOffset = -1;
          }
          break;

        case _stateAfterClose:
          if (code != _spaceCodeUnit && code != _tabCodeUnit) {
            state = _stateText;
            endOffset = -1;
            continue;
          }
          break;
      }

      i++;
    }

    endOffset = state != _stateText ? endOffset : length;

    Inlines inlines;
    Attr attr = new EmptyAttr();
    if (startOffset != -1 && endOffset != -1) {
      String content = line.substring(startOffset, endOffset);
      if (container.options.headingAttributes) {
        if (content.endsWith('}')) {
          int attributesStart = content.lastIndexOf('{');
          ParseResult<Attributes> attributesResult =
              container.attributesParser.parse(content, attributesStart);
          if (attributesResult.isSuccess) {
            content = content.substring(0, attributesStart);
            attr = attributesResult.value;
          }
        }
      }
      inlines = new _UnparsedInlines(content);
    } else {
      inlines = new Inlines();
    }

    List<AtxHeading> heading = <AtxHeading>[
      new AtxHeading(level, inlines, attr)
    ];

    return new ParseResult<Iterable<Block>>.success(heading, lineResult.offset);
  }
}
