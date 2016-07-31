part of md_proc.src.parsers;

class HtmlBlockParser extends AbstractParser<Iterable<Block>> {
  HtmlBlockParser(ParsersContainer container) : super(container);

  static const TAGNAME = '[A-Za-z][A-Za-z0-9-]*';
  static const ATTRIBUTENAME = '[a-zA-Z_:][a-zA-Z0-9:._-]*';
  static const UNQUOTEDVALUE = "[^\"'=<>`\\x00-\\x20]+";
  static const SINGLEQUOTEDVALUE = "'[^']*'";
  static const DOUBLEQUOTEDVALUE = '"[^"]*"';
  static const ATTRIBUTEVALUE = "(?:" +
      UNQUOTEDVALUE +
      "|" +
      SINGLEQUOTEDVALUE +
      "|" +
      DOUBLEQUOTEDVALUE +
      ")";
  static const ATTRIBUTEVALUESPEC =
      "(?:" + "\\s*=" + "\\s*" + ATTRIBUTEVALUE + ")";
  static const ATTRIBUTE =
      "(?:" + "\\s+" + ATTRIBUTENAME + ATTRIBUTEVALUESPEC + "?)";
  static const OPENTAG = "<" + TAGNAME + ATTRIBUTE + "*" + "\\s*/?>";
  static const CLOSETAG = "</" + TAGNAME + "\\s*>";

  List<RegExp> starts = <RegExp>[
    _HTML_BLOCK_1_TEST,
    _HTML_BLOCK_2_TEST,
    _HTML_BLOCK_3_TEST,
    _HTML_BLOCK_4_TEST,
    _HTML_BLOCK_5_TEST
  ];

  List<RegExp> ends = <RegExp>[
    new RegExp(r'</(script|pre|style)>', caseSensitive: false),
    new RegExp(r'-->'),
    new RegExp(r'\?>'),
    new RegExp(r'>'),
    new RegExp(r'\]\]>')
  ];

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    if (!fastBlockTest(text, offset, _LESS_THAN_CODE_UNIT)) {
      return new ParseResult<Iterable<Block>>.failure();
    }

    int rule;
    for (int i = 0; i < starts.length; ++i) {
      if (starts[i].matchAsPrefix(text, offset) != null) {
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
        if (ends[rule].hasMatch(lineRes.value)) {
          break;
        }
      }

      return new ParseResult<Iterable<Block>>.success(
          <Block>[new HtmlRawBlock(result.toString())], offset);
    }

    if (_HTML_BLOCK_6_TEST.matchAsPrefix(text, offset) != null) {
      int length = text.length;
      StringBuffer result = new StringBuffer();
      while (offset < length) {
        ParseResult<String> lineRes = container.lineParser.parse(text, offset);
        assert(lineRes.isSuccess);

        offset = lineRes.offset;
        result.writeln(lineRes.value);
        if (EMPTY_LINE.hasMatch(lineRes.value)) {
          break;
        }
      }

      return new ParseResult<Iterable<Block>>.success(
          <Block>[new HtmlRawBlock(result.toString())], offset);
    }

    return new ParseResult<Iterable<Block>>.failure();
  }
}
