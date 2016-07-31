part of md_proc.src.parsers;

class BlanklineParser extends AbstractParser<Iterable<Block>> {
  BlanklineParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    ParseResult<String> lineResult = container.lineParser.parse(text, offset);
    assert(lineResult.isSuccess);

    String line = lineResult.value;

    offset = lineResult.offset;
    if (EMPTY_LINE.hasMatch(line)) {
      return new ParseResult<Iterable<Block>>.success(
          <Block>[], lineResult.offset);
    }

    return const ParseResult<Iterable<Block>>.failure();
  }
}
