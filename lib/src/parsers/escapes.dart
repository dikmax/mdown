part of md_proc.src.parsers;

class EscapesParser extends AbstractParser<Inlines> {
  EscapesParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    if (offset + 1 < text.length &&
        text.codeUnitAt(offset) == _SLASH_CODE_UNIT) {
      int codeUnit = text.codeUnitAt(offset + 1);
      if (ESCAPABLE_CODES.contains(codeUnit)) {
        return new ParseResult<Inlines>.success(
            new Inlines.single(new Str(new String.fromCharCode(codeUnit))),
            offset + 2);
      } else if (codeUnit == _NEWLINE_CODE_UNIT) {
        return new ParseResult<Inlines>.success(
            new Inlines.single(new LineBreak()), offset + 2);
      }
    }

    return new ParseResult<Inlines>.failure();
  }
}
