part of md_proc.src.parsers;

/// Parser for arbitrary string.
class StrParser extends AbstractParser<Inlines> {
  final Set<int> _specialChars = new Set<int>.from(<int>[
    _ampersandCodeUnit,
    _backtickCodeUnit,
    _closeBracketCodeUnit,
    _exclamationMarkCodeUnit,
    _lessThanCodeUnit,
    _nonBreakableSpaceCodeUnit,
    _newLineCodeUnit,
    _openBracketCodeUnit,
    _backslashCodeUnit,
    _spaceCodeUnit,
    _starCodeUnit,
    _tabCodeUnit,
    _underscoreCodeUnit
  ]);

  /// Constructor.
  StrParser(ParsersContainer container) : super(container) {
    if (container.options.smartPunctuation) {
      _specialChars.addAll(<int>[
        _dotCodeUnit,
        _minusCodeUnit,
        _singleQuoteCodeUnit,
        _doubleQuoteCodeUnit
      ]);
    }

    if (container.options.strikeout || container.options.subscript) {
      _specialChars.add(_tildeCodeUnit);
    }

    if (container.options.superscript) {
      _specialChars.add(_caretCodeUnit);
    }

    if (container.options.texMathDollars) {
      _specialChars.add(_dollarCodeUnit);
    }
  }

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    int char = text.codeUnitAt(offset);
    if (_specialChars.contains(char)) {
      Inline result;
      if (char == _spaceCodeUnit) {
        result = new Space();
      } else if (char == _tabCodeUnit) {
        result = new Tab();
      } else if (char == _nonBreakableSpaceCodeUnit) {
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
