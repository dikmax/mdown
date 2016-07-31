part of md_proc.src.parsers;

class InlineHtmlParser extends AbstractParser<Inlines> {
  InlineHtmlParser(ParsersContainer container) : super(container);

  List<RegExp> tests = <RegExp>[
    new RegExp('(?:' + HTML_OPENTAG + '|' + HTML_CLOSETAG + ')'), // Tag
    new RegExp('<!---->|<!--(?:-?[^>-])(?:-?[^-])*-->'), // Comment
    new RegExp('[<][?].*?[?][>]'), // Processing instruction
    new RegExp('<![A-Z]+\\s+[^>]*>'), // Declaration
    new RegExp('<!\\[CDATA\\[[\\s\\S]*?\\]\\]>') // CDATA
  ];

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    if (text.codeUnitAt(offset) == _LESS_THAN_CODE_UNIT) {
      for (RegExp test in tests) {
        Match match = test.matchAsPrefix(text, offset);
        if (match != null) {
          return new ParseResult.success(
              new Inlines.single(
                  new HtmlRawInline(text.substring(offset, match.end))),
              match.end);
        }
      }
    }

    return new ParseResult<Inlines>.failure();
  }
}
