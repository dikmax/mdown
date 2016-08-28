part of md_proc.src.parsers;

class StrParser extends AbstractParser<Inlines> {
  final Set<int> _specialChars = new Set<int>.from(<int>[
    _AMPERSAND_CODE_UNIT,
    _BACKTICK_CODE_UNIT,
    _CLOSE_BRACKET_CODE_UNIT,
    _EXCLAMATION_MARK_CODE_UNIT,
    _LESS_THAN_CODE_UNIT,
    _NBSP_CODE_UNIT,
    _NEWLINE_CODE_UNIT,
    _OPEN_BRACKET_CODE_UNIT,
    _SLASH_CODE_UNIT,
    _SPACE_CODE_UNIT,
    _STAR_CODE_UNIT,
    _TAB_CODE_UNIT,
    _UNDERSCORE_CODE_UNIT
  ]);

  /// Constructor.
  StrParser(ParsersContainer container) : super(container) {
    if (container.options.smartPunctuation) {
      _specialChars.addAll(<int>[
        _DOT_CODE_UNIT,
        _MINUS_CODE_UNIT,
        _SINGLE_QUOTE_CODE_UNIT,
        _DOUBLE_QUOTE_CODE_UNIT
      ]);
    }
  }

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    int char = text.codeUnitAt(offset);
    if (_specialChars.contains(char)) {
      Inline result;
      if (char == _SPACE_CODE_UNIT) {
        result = new Space();
      } else if (char == _TAB_CODE_UNIT) {
        result = new Tab();
      } else if (char == _NBSP_CODE_UNIT) {
        result = new NonBreakableSpace();
      } else {
        result = new Str(new String.fromCharCode(char));
      }
      return new ParseResult<Inlines>.success(
          new Inlines.single(result), offset + 1);
    } else {
      int endOffset = offset + 1;
      int length = text.length;
      while (endOffset < length &&
          !_specialChars.contains(text.codeUnitAt(endOffset))) {
        endOffset++;
      }

      return new ParseResult<Inlines>.success(
          new Inlines.single(new Str(text.substring(offset, endOffset))),
          endOffset);
    }
  }
}
