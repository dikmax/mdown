part of md_proc.src.parsers;

/// Parser for thematic break.
class ThematicBreakParser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  ThematicBreakParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
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
