part of md_proc.src.parsers;

/// Parser for thematic break.
class ThematicBreakParser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  ThematicBreakParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    if (!fastBlockTest3(text, offset, _minusCodeUnit, _starCodeUnit,
        _unredscoreCodeUnit)) {
      return const ParseResult<Iterable<Block>>.failure();
    }

    ParseResult<String> lineResult = container.lineParser.parse(text, offset);
    assert(lineResult.isSuccess);

    Match match = _thematicBreakTest.firstMatch(lineResult.value);
    if (match == null) {
      return const ParseResult<Iterable<Block>>.failure();
    }

    return new ParseResult<Iterable<Block>>.success(
        <ThematicBreak>[new ThematicBreak()], lineResult.offset);
  }
}
