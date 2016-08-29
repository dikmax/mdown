part of md_proc.src.parsers;

/// Parser for html blocks using rule 7.
class HtmlBlock7Parser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  HtmlBlock7Parser(ParsersContainer container) : super(container);

  RegExp _startRegExp =
      new RegExp(r'^ {0,3}(?:' + _htmlOpenTag + '|' + _htmlCloseTag + r')\s*$');

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    if (!fastBlockTest(text, offset, _lessThanCodeUnit)) {
      return new ParseResult<Iterable<Block>>.failure();
    }

    ParseResult<String> lineRes = container.lineParser.parse(text, offset);
    assert(lineRes.isSuccess);

    if (_startRegExp.firstMatch(lineRes.value) != null) {
      StringBuffer result = new StringBuffer(lineRes.value + '\n');
      offset = lineRes.offset;
      int length = text.length;
      while (offset < length) {
        ParseResult<String> lineRes = container.lineParser.parse(text, offset);
        assert(lineRes.isSuccess);

        offset = lineRes.offset;
        result.writeln(lineRes.value);
        if (_emptyLineRegExp.hasMatch(lineRes.value)) {
          break;
        }
      }

      return new ParseResult<Iterable<Block>>.success(
          <Block>[new HtmlRawBlock(result.toString())], offset);
    }

    return new ParseResult<Iterable<Block>>.failure();
  }
}
