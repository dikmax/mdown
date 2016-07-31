part of md_proc.src.parsers;

final RegExp LINE_REGEXP = new RegExp('(.*)(?:\r\n|\n|\r)');

class LineParser extends AbstractParser<String> {
  LineParser(ParsersContainer container) : super(container);

  @override
  ParseResult<String> parse(String text, int offset) {
    int length = text.length;
    if (offset >= length) {
      return const ParseResult<String>.failure();
    }

    Match match = LINE_REGEXP.matchAsPrefix(text, offset);
    String line;
    int newOffset;
    if (match == null) {
      newOffset = length;
      line = text.substring(offset, length);
    } else {
      newOffset = match.end;
      line = match[1];
    }

    return new ParseResult.success(line, newOffset);
  }
}
