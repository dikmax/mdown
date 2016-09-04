part of md_proc.src.parsers;

/// Parser for html blocks using rules 1-6.
class HtmlBlockParser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  HtmlBlockParser(ParsersContainer container) : super(container);

  List<Pattern> _starts = <Pattern>[
    _htmlBlock1Test,
    _htmlBlock2Test,
    _htmlBlock3Test,
    _htmlBlock4Test,
    _htmlBlock5Test
  ];

  List<Pattern> _ends = <Pattern>[
    new RegExp(r'</(script|pre|style)>', caseSensitive: false),
    '-->',
    '?>',
    '>',
    ']]>'
  ];

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    int nonIndentOffset = _skipIndent(text, offset);

    int rule;
    for (int i = 0; i < _starts.length; ++i) {
      if (_starts[i].matchAsPrefix(text, nonIndentOffset) != null) {
        rule = i;
        break;
      }
    }

    if (rule != null) {
      int length = text.length;
      StringBuffer result = new StringBuffer();
      while (offset < length) {
        ParseResult<String> lineRes = container.lineParser.parse(text, offset);
        assert(lineRes.isSuccess);

        offset = lineRes.offset;
        result.writeln(lineRes.value);
        if (lineRes.value.contains(_ends[rule])) {
          break;
        }
      }

      return new ParseResult<Iterable<Block>>.success(
          <Block>[new HtmlRawBlock(result.toString())], offset);
    }

    if (_htmlBlock6Test.matchAsPrefix(text, offset) != null) {
      int length = text.length;
      StringBuffer result = new StringBuffer();
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
