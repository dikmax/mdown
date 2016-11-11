part of md_proc.src.parsers;

/// Parser for extended attiributes.
class AttributesParser extends AbstractParser<Attributes> {
  /// Constructor.
  AttributesParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Attributes> parse(String text, int offset) {
    if (text.codeUnitAt(offset) != _openBraceCodeUnit) {
      return new ParseResult<Attributes>.failure();
    }

    offset++;

    String id;
    List<String> classes = <String>[];
    Multimap<String, String> attributes = new Multimap<String, String>();

    int length = text.length;
    while (offset < length) {
      int codeUnit = text.codeUnitAt(offset);

      if (codeUnit == _closeBraceCodeUnit) {
        offset++;
        break;
      }

      switch (codeUnit) {
        case _sharpCodeUnit:
          // Id
          int endOffset = _parseIdentifier(text, offset);
          id = text.substring(offset + 1, endOffset);
          offset = endOffset;
          break;

        case _dotCodeUnit:
          // Id
          int endOffset = _parseIdentifier(text, offset);
          classes.add(text.substring(offset + 1, endOffset));
          offset = endOffset;
          break;

        case _spaceCodeUnit:
        case _tabCodeUnit:
          offset++;
          break;

        case _newLineCodeUnit:
        case _carriageReturnCodeUnit:
          return new ParseResult<Attributes>.failure();

        default:
          int endOffset = _parseAttribute(text, offset, attributes);
          if (endOffset == offset) {
            return new ParseResult<Attributes>.failure();
          }
          offset = endOffset;

          break;
      }
    }

    return new ParseResult<Attributes>.success(
        new Attributes(id, classes, attributes), offset);
  }

  int _parseIdentifier(String text, int offset) {
    int endOffset = offset + 1;
    int length = text.length;

    while (endOffset < length) {
      int codeUnit = text.codeUnitAt(endOffset);

      if (codeUnit == _spaceCodeUnit ||
          codeUnit == _tabCodeUnit ||
          codeUnit == _newLineCodeUnit ||
          codeUnit == _carriageReturnCodeUnit ||
          codeUnit == _closeBraceCodeUnit ||
          codeUnit == _equalCodeUnit ||
          codeUnit == _sharpCodeUnit ||
          codeUnit == _dotCodeUnit) {
        break;
      }

      endOffset++;
    }

    return endOffset;
  }

  static final RegExp _attributesRegExp =
      new RegExp('([a-zA-Z0-9_\-]+)=([^ "\'\t}][^ \t}]*|"[^"]*"|\'[^\']*\')');

  int _parseAttribute(
      String text, int offset, Multimap<String, String> attributes) {
    Match match = _attributesRegExp.matchAsPrefix(text, offset);
    if (match == null) {
      return offset;
    }

    String key = match[1];
    String value = match[2];
    int startCodeUnit = value.codeUnitAt(0);
    if (startCodeUnit == _singleQuoteCodeUnit ||
        startCodeUnit == _doubleQuoteCodeUnit) {
      value = value.substring(1, value.length - 1);
    }

    attributes.add(key, value);

    return match.end;
  }
}
