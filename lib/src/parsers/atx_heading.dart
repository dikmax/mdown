part of md_proc.src.parsers;

/// Parser for ATX-headings.
class AtxHeadingParser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  AtxHeadingParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    // TODO remove fast check.
    // They a performed by caller
    if (!fastBlockTest(text, offset, _sharpCodeUnit)) {
      return new ParseResult<Iterable<Block>>.failure();
    }

    ParseResult<String> lineResult = container.lineParser.parse(text, offset);

    assert(lineResult.isSuccess);

    String line = lineResult.value;
    Match match = _atxHeadingText.firstMatch(line);
    if (match == null) {
      return const ParseResult<Iterable<Block>>.failure();
    }

    int level = match[1].length;

    if (match.end == line.length) {
      List<AtxHeading> result = <AtxHeading>[
        new AtxHeading(level, new Inlines())
      ];
      return new ParseResult<Iterable<Block>>.success(
          result, lineResult.offset);
    }

    int state = line.codeUnitAt(match.end) == _sharpCodeUnit ? 2 : 0;
    List<int> rest = <int>[];
    List<int> result = <int>[];
    for (int i = match.end; i < line.length; ++i) {
      int code = line.codeUnitAt(i);

      // Finite Automata
      // TODO use constants for states
      switch (state) {
        case 0:
          if (code == _spaceCodeUnit || code == _tabCodeUnit) {
            state = 1;
          }
          result.add(code);
          break;

        case 1:
          if (code == _sharpCodeUnit) {
            state = 2;
            rest.add(code);
          } else {
            result.add(code);
            if (code != _spaceCodeUnit && code != _tabCodeUnit) {
              state = 0;
            }
          }
          break;

        case 2:
          if (code == _sharpCodeUnit) {
            rest.add(code);
          } else if (code == _spaceCodeUnit || code == _tabCodeUnit) {
            state = 3;
            rest.add(code);
          } else {
            result.addAll(rest);
            rest = <int>[];
            state = 0;
          }
          break;

        case 3:
          if (code == _spaceCodeUnit || code == _tabCodeUnit) {
            rest.add(code);
          } else if (code == _sharpCodeUnit) {
            result.addAll(rest);
            rest = <int>[code];
            state = 2;
          } else {
            result.addAll(rest);
            result.add(code);
            rest = <int>[];
            state = 0;
          }
      }
    }

    String str = new String.fromCharCodes(result).trim();

    Inlines inlines = str != '' ? new _UnparsedInlines(str) : new Inlines();

    List<AtxHeading> heading = <AtxHeading>[new AtxHeading(level, inlines)];

    return new ParseResult<Iterable<Block>>.success(heading, lineResult.offset);
  }
}
