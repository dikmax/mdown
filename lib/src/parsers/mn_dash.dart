part of md_proc.src.parsers;

/// Parser for mdashes and ndashes.
class MNDashParser extends AbstractParser<Inlines> {
  /// Constructor.
  MNDashParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    final int length = text.length;
    int count = 0;
    while (offset < length && text.codeUnitAt(offset) == _minusCodeUnit) {
      count++;
      offset++;
    }
    if (count > 1) {
      List<Inline> result;
      if (count % 3 == 0) {
        result = new List<Inline>.filled(count ~/ 3, new MDash());
      } else if (count % 2 == 0) {
        result = new List<Inline>.filled(count ~/ 2, new NDash());
      } else if (count % 3 == 2) {
        result =
            new List<Inline>.filled(count ~/ 3, new MDash(), growable: true);
        result.add(new NDash());
      } else {
        // count % 3 == 1
        result = new List<Inline>.filled((count - 4) ~/ 3, new MDash(),
            growable: true);
        result.add(new NDash());
        result.add(new NDash());
      }
      return new ParseResult<Inlines>.success(new Inlines.from(result), offset);
    }

    return new ParseResult<Inlines>.failure();
  }
}
