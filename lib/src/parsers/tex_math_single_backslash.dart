part of md_proc.src.parsers;

/// Parses TeX Match between `\(...\)` and `\[...\]`.
class TexMathSingleBackslashParser extends AbstractParser<Inlines> {
  /// Constructor.
  TexMathSingleBackslashParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    ++offset;
    int length = text.length;
    if (offset >= length) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new Str('\\')), offset);
    }
    int codeUnit = text.codeUnitAt(offset);
    if (codeUnit != _openParenCodeUnit && codeUnit != _openBracketCodeUnit) {
      return new ParseResult<Inlines>.failure();
    }
    bool displayMath = codeUnit == _openBracketCodeUnit;
    int closeCodeUnit =
        displayMath ? _closeBracketCodeUnit : _closeParenCodeUnit;
    offset++;
    int endOffset = offset;
    bool found = false;
    while (endOffset < length - 1) {
      if (text.codeUnitAt(endOffset) == _backslashCodeUnit &&
          text.codeUnitAt(endOffset + 1) == closeCodeUnit) {
        found = true;
        break;
      }
      endOffset++;
    }

    if (!found) {
      return new ParseResult<Inlines>.failure();
    }

    String math = text.substring(offset, endOffset);
    if (displayMath) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new TexMathDisplay(math)), endOffset + 2);
    } else {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new TexMathInline(math)), endOffset + 2);
    }
  }
}
