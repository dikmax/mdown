part of md_proc.src.parsers;

class TexMathSingleBackslashParser extends AbstractParser<Inlines> {
  TexMathSingleBackslashParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    if (text.codeUnitAt(offset) != _slashCodeUnit) {
      return new ParseResult<Inlines>.failure();
    }

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
      if (text.codeUnitAt(endOffset) == _slashCodeUnit &&
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
