part of md_proc.src.parsers;

/// Parser for inline html.
class InlineHtmlParser extends AbstractParser<Inlines> {
  /// Constructor.
  InlineHtmlParser(ParsersContainer container) : super(container);

  static final List<RegExp> _tests = <RegExp>[
    new RegExp('(?:' + _htmlOpenTag + '|' + _htmlCloseTag + ')'), // Tag
    new RegExp('<!---->|<!--(?:-?[^>-])(?:-?[^-])*-->'), // Comment
    new RegExp('[<][?].*?[?][>]'), // Processing instruction
    new RegExp('<![A-Z]+\\s+[^>]*>'), // Declaration
    new RegExp('<!\\[CDATA\\[[\\s\\S]*?\\]\\]>') // CDATA
  ];

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    if (text.codeUnitAt(offset) == _lessThanCodeUnit) {
      for (RegExp test in _tests) {
        final Match match = test.matchAsPrefix(text, offset);
        if (match != null) {
          return new ParseResult<Inlines>.success(
              new Inlines.single(
                  new HtmlRawInline(text.substring(offset, match.end))),
              match.end);
        }
      }
    }

    return new ParseResult<Inlines>.failure();
  }
}
