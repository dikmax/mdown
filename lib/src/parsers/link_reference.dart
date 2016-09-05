part of md_proc.src.parsers;

class _LinkReference extends Block {
  String reference;
  String normalizedReference;
  Target target;

  _LinkReference(this.reference, this.target) {
    normalizedReference = normalize(reference);
  }

  static String normalize(String s) => _trimAndReplaceSpaces(s).toUpperCase();
}

/// Parser for link reference blocks.
class LinkReferenceParser extends AbstractParser<_LinkReference> {
  /// Constructor.
  LinkReferenceParser(ParsersContainer container) : super(container);

  /// Regexp to check that we don't have empty line.
  static const String _notEmptyLineRegExp =
      r'(?:\r\n|\n|\r)(?![ \t]*(?:\r\n|\n|\r))';

  static final RegExp _linkRefereceRegExp = new RegExp(
      // Label
      r' {0,3}\[((?:[^\[\]\r\n]|\\\]|\\\[|' +
          _notEmptyLineRegExp +
          r')+)\]:' +
          // Space after label
          r'(?:[ \t]|' +
          _notEmptyLineRegExp +
          r')*' +
          // Link
          r'([^ \t\r\n]*)' +
          // Space after and title (optional)
          r'(?:(?:[ \t]|' +
          _notEmptyLineRegExp +
          r')+(' +
          r'"(?:[^"\r\n]|\\"|' +
          _notEmptyLineRegExp +
          r')*"|' +
          r"'(?:[^'\r\n]|\\'|" +
          _notEmptyLineRegExp +
          r")*'|" +
          r'\((?:[^)\r\n]|\\\)|' +
          _notEmptyLineRegExp +
          r')*\)' +
          r'))?' +
          // End line whitespace and end (required).
          r'[ \t]*(?:\r\n|\n|\r|$)');

  @override
  ParseResult<_LinkReference> parse(String text, int offset) {
    Match match = _linkRefereceRegExp.matchAsPrefix(text, offset);

    if (match == null) {
      return new ParseResult<_LinkReference>.failure();
    }

    String label = _LinkReference.normalize(match[1]);
    if (label.length == 0) {
      // Label cannot be empty
      return new ParseResult<_LinkReference>.failure();
    }

    String link = match[2];
    if (link == '') {
      // Target cannot be empty
      return new ParseResult<_LinkReference>.failure();
    }
    if (link.startsWith('<') && link.endsWith('>') && !link.endsWith(r'\>')) {
      link = link.substring(1, link.length - 1);
    }
    link = unescapeAndUnreference(link);

    String title = match[3];
    if (title != null) {
      title = title.substring(1, title.length - 1);
      title = unescapeAndUnreference(title);
    }

    return new ParseResult<_LinkReference>.success(
        new _LinkReference(label, new Target(link, title)), match.end);
  }
}
