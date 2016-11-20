part of md_proc.src.parsers;

/// Parser for empty line.
class BlanklineParser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  BlanklineParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    final ParseResult<String> lineResult =
        container.lineParser.parse(text, offset);
    assert(lineResult.isSuccess);

    final String line = lineResult.value;

    offset = lineResult.offset;
    if (_emptyLineRegExp.hasMatch(line)) {
      return new ParseResult<Iterable<Block>>.success(
          <Block>[], lineResult.offset);
    }

    return const ParseResult<Iterable<Block>>.failure();
  }
}
