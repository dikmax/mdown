part of md_proc.src.parsers;

/// Parses TeX Match between `\\(...\\)` and `\\[...\\]`.
class TexMathDoubleBackslashParser extends AbstractParser<Inlines> {
  /// Constructor.
  TexMathDoubleBackslashParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    final int length = text.length;
    if (offset + 2 >= length ||
        text.codeUnitAt(offset) != _backslashCodeUnit ||
        text.codeUnitAt(offset + 1) != _backslashCodeUnit) {
      return new ParseResult<Inlines>.failure();
    }

    offset += 2;
    final int codeUnit = text.codeUnitAt(offset);
    if (codeUnit != _openParenCodeUnit && codeUnit != _openBracketCodeUnit) {
      return new ParseResult<Inlines>.failure();
    }
    final bool displayMath = codeUnit == _openBracketCodeUnit;
    final int closeCodeUnit =
        displayMath ? _closeBracketCodeUnit : _closeParenCodeUnit;
    offset++;
    int endOffset = offset;
    bool found = false;
    while (endOffset < length - 2) {
      if (text.codeUnitAt(endOffset) == _backslashCodeUnit &&
          text.codeUnitAt(endOffset + 1) == _backslashCodeUnit &&
          text.codeUnitAt(endOffset + 2) == closeCodeUnit) {
        found = true;
        break;
      }
      endOffset++;
    }

    if (!found) {
      return new ParseResult<Inlines>.failure();
    }

    final String math = text.substring(offset, endOffset);
    if (displayMath) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new TexMathDisplay(math)), endOffset + 3);
    } else {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new TexMathInline(math)), endOffset + 3);
    }
  }
}
