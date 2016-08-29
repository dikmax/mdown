part of md_proc.src.parsers;

/// Parser for ellipsis.
class EllipsisParser extends AbstractParser<Inlines> {
  /// Constructor.
  EllipsisParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    if (offset + 2 < text.length &&
      text.codeUnitAt(offset) == _dotCodeUnit && text.codeUnitAt(offset + 1) == _dotCodeUnit
    && text.codeUnitAt(offset + 2) == _dotCodeUnit) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new Ellipsis()),
          offset + 3);
    }

    return new ParseResult<Inlines>.failure();
  }
}
