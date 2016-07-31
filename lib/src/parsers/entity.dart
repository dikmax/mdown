part of md_proc.src.parsers;

class EntityParser extends AbstractParser<Inlines> {
  EntityParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    Match match = _ENTITY_REGEXP.matchAsPrefix(text, offset);
    if (match != null) {
      if (match[3] != null) {
        String code = match[3];
        if (code == 'nbsp') {
          return new ParseResult<Inlines>.success(
              new Inlines.single(new NonBreakableSpace()), match.end);
        }
        String str = htmlEntities[match[3]];
        if (str != null) {
          return new ParseResult<Inlines>.success(
              new Inlines.single(new Str(str)), match.end);
        }
      } else {
        int code;
        if (match[1] != null) {
          code = int.parse(match[1], radix: 16, onError: (_) => 0);
        } else {
          code = int.parse(match[2], radix: 10, onError: (_) => 0);
        }

        if (code > 1114111 || code == 0) {
          code = 0xFFFD;
        }

        if (code == _NBSP_CODE_UNIT) {
          return new ParseResult<Inlines>.success(
              new Inlines.single(new NonBreakableSpace()), match.end);
        }
        return new ParseResult<Inlines>.success(
            new Inlines.single(new Str(new String.fromCharCode(code))),
            match.end);
      }
    }

    return new ParseResult<Inlines>.failure();
  }
}
