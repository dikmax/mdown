part of md_proc.src.parsers;

/// Parser for html blocks using rules 1-6.
class HtmlBlockParser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  HtmlBlockParser(ParsersContainer container) : super(container);

  static final List<Pattern> _starts = <Pattern>[
    _htmlBlock1Test,
    _htmlBlock2Test,
    _htmlBlock3Test,
    _htmlBlock4Test,
    _htmlBlock5Test
  ];

  static final List<Pattern> _ends = <Pattern>[
    new RegExp(r'</(script|pre|style)>', caseSensitive: false),
    '-->',
    '?>',
    '>',
    ']]>'
  ];

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    final int nonIndentOffset = _skipIndent(text, offset);

    int rule;
    for (int i = 0; i < _starts.length; ++i) {
      if (text.startsWith(_starts[i], nonIndentOffset)) {
        rule = i;
        break;
      }
    }

    if (rule != null) {
      final int length = text.length;
      final StringBuffer result = new StringBuffer();
      while (offset < length) {
        final ParseResult<String> lineRes =
            container.lineParser.parse(text, offset);
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

    final Match htmlBlock6Match =
        _htmlBlock6Test.matchAsPrefix(text, nonIndentOffset);
    if (htmlBlock6Match != null) {
      final String tag = htmlBlock6Match[1];
      if (!_blockTags.contains(tag.toLowerCase())) {
        return new ParseResult<Iterable<Block>>.failure();
      }

      final int length = text.length;
      final StringBuffer result = new StringBuffer();
      while (offset < length) {
        final ParseResult<String> lineRes =
            container.lineParser.parse(text, offset);
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
