part of md_proc.src.parsers;

/// Autolinks (`<http://example.com/>`) parser
class AutolinkParser extends AbstractParser<Inlines> {
  /// Constructor.
  AutolinkParser(ParsersContainer container) : super(container);

  static final RegExp _autolinkRegExp =
      new RegExp(r'<([a-zA-Z][a-zA-Z0-9+.\-]{1,31}:[^ \t\x00-\x20<>]*)>');

  static final RegExp _emailRegExp =
      new RegExp('<([a-zA-Z0-9.!#\$%&\'*+/=?^_`{|}~\\-]+@'
          '[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
          '(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*)>');

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    final Match autolinkMatch = _autolinkRegExp.matchAsPrefix(text, offset);

    if (autolinkMatch != null) {
      final String autolink = autolinkMatch[1];

      return new ParseResult<Inlines>.success(
          new Inlines.single(new Autolink(autolink)), autolinkMatch.end);
    }

    final Match emailMatch = _emailRegExp.matchAsPrefix(text, offset);

    if (emailMatch != null) {
      final String email = emailMatch[1];

      return new ParseResult<Inlines>.success(
          new Inlines.single(new Autolink.email(email)), emailMatch.end);
    }

    return new ParseResult<Inlines>.failure();
  }
}
