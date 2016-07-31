part of md_proc.src.parsers;

class HardLineBreakParser extends AbstractParser<Inlines> {
  HardLineBreakParser(ParsersContainer container) : super(container);

  final RegExp HARD_LINE_BREAK_TEST =
      new RegExp(r'(?: {2,}|\t+)(?:\r\n|\n|\r)');

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    Match match = HARD_LINE_BREAK_TEST.matchAsPrefix(text, offset);

    if (match != null) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new LineBreak()), match.end);
    }

    return new ParseResult<Inlines>.failure();
  }
}
