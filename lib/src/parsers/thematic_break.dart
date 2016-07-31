part of md_proc.src.parsers;

class ThematicBreakParser extends AbstractParser<Iterable<Block>> {
  ThematicBreakParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    if (!fastBlockTest3(text, offset, _MINUS_CODE_UNIT, _STAR_CODE_UNIT,
        _UNDERSCORE_CODE_UNIT)) {
      return const ParseResult<Iterable<Block>>.failure();
    }

    ParseResult<String> lineResult = container.lineParser.parse(text, offset);
    assert(lineResult.isSuccess);

    Match match = _THEMATIC_BREAK_TEST.firstMatch(lineResult.value);
    if (match == null) {
      return const ParseResult<Iterable<Block>>.failure();
    }

    return new ParseResult<Iterable<Block>>.success(
        <ThematicBreak>[new ThematicBreak()], lineResult.offset);
  }
}
