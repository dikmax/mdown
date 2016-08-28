part of md_proc.src.parsers;

class EllipsisParser extends AbstractParser<Inlines> {
  EllipsisParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    if (offset + 2 < text.length &&
      text.codeUnitAt(offset) == _DOT_CODE_UNIT && text.codeUnitAt(offset + 1) == _DOT_CODE_UNIT
    && text.codeUnitAt(offset + 2) == _DOT_CODE_UNIT) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new Ellipsis()),
          offset + 3);
    }

    return new ParseResult<Inlines>.failure();
  }
}
