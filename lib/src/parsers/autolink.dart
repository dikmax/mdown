part of md_proc.src.parsers;

class AutolinkParser extends AbstractParser<Inlines> {
  AutolinkParser(ParsersContainer container) : super(container);

  final RegExp _AUTOLINK_REGEXP =
      new RegExp(r'<([a-zA-Z][a-zA-Z0-9+.\-]{1,31}:[^ \t\x00-\x20<>]*)>');

  final RegExp _EMAIL_REGEXP =
      new RegExp('<([a-zA-Z0-9.!#\$%&\'*+/=?^_`{|}~\\-]+@'
          '[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
          '(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*)>');

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    int codeUnit = text.codeUnitAt(offset);

    if (codeUnit != _LESS_THAN_CODE_UNIT) {
      return new ParseResult<Inlines>.failure();
    }

    Match autolinkMatch = _AUTOLINK_REGEXP.matchAsPrefix(text, offset);

    if (autolinkMatch != null) {
      String autolink = autolinkMatch[1];

      return new ParseResult<Inlines>.success(
          new Inlines.single(new Autolink(autolink)), autolinkMatch.end);
    }

    Match emailMatch = _EMAIL_REGEXP.matchAsPrefix(text, offset);

    if (emailMatch != null) {
      String email = emailMatch[1];

      return new ParseResult<Inlines>.success(
          new Inlines.single(new Autolink.email(email)), emailMatch.end);
    }

    return new ParseResult<Inlines>.failure();
  }
}
