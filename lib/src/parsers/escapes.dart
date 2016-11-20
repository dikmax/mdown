part of md_proc.src.parsers;

/// Parser for escaped chars.
class EscapesParser extends AbstractParser<Inlines> {
  /// Constructor.
  EscapesParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    // At this point we know that text[offset] == '\'
    if (offset + 1 < text.length) {
      final int codeUnit = text.codeUnitAt(offset + 1);
      if (_escapableCodes.contains(codeUnit)) {
        return new ParseResult<Inlines>.success(
            new Inlines.single(new Str(new String.fromCharCode(codeUnit))),
            offset + 2);
      } else if (codeUnit == _newLineCodeUnit) {
        return new ParseResult<Inlines>.success(
            new Inlines.single(new LineBreak()), offset + 2);
      }
    }

    return new ParseResult<Inlines>.failure();
  }
}
