part of md_proc.src.parsers;

/// Parser for hard line breaks.
class HardLineBreakParser extends AbstractParser<Inlines> {
  /// Constructor.
  HardLineBreakParser(ParsersContainer container) : super(container);

  final RegExp _hardLineBreakTest = new RegExp(r'(?: {2,}|\t+)(?:\r\n|\n|\r)');

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    Match match = _hardLineBreakTest.matchAsPrefix(text, offset);

    if (match != null) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new LineBreak()), match.end);
    }

    return new ParseResult<Inlines>.failure();
  }
}
