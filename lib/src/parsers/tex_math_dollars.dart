part of md_proc.src.parsers;

/// Parses string between `$...$` and `$$...$$` as TeX Math.
class TexMathDollarsParser extends AbstractParser<Inlines> {
  /// Constructor.
  TexMathDollarsParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    int length = text.length;
    offset++;
    if (offset >= length) {
      // Just a `$` at the end of string.
      return new ParseResult<Inlines>.success(
          new Inlines.single(new Str(r'$')), offset);
    }
    int codeUnit = text.codeUnitAt(offset);
    bool displayMath = codeUnit == _dollarCodeUnit;
    if (displayMath) {
      offset++;
      if (offset >= length) {
        // Just a `$` at the end of string.
        return new ParseResult<Inlines>.success(
            new Inlines.single(new Str(r'$$')), offset);
      }
    } else {
      if (codeUnit == _spaceCodeUnit ||
          codeUnit == _tabCodeUnit ||
          codeUnit == _newLineCodeUnit ||
          codeUnit == _carriageReturnCodeUnit ||
          (codeUnit >= _zeroCodeUnit && codeUnit <= _nineCodeUnit)) {
        return new ParseResult<Inlines>.success(
            new Inlines.single(new Str(r'$')), offset);
      }
    }

    int endOffset = offset;
    bool found = false;
    while (endOffset < length) {
      int codeUnit = text.codeUnitAt(endOffset);
      if (codeUnit == _backslashCodeUnit) {
        endOffset++;
        if (endOffset >= length) {
          break;
        }
      } else if (codeUnit == _dollarCodeUnit) {
        if (displayMath) {
          if (endOffset + 1 < length &&
              text.codeUnitAt(endOffset + 1) == _dollarCodeUnit) {
            found = true;
            break;
          }
        } else {
          found = true;
          break;
        }
      }
      endOffset++;
    }

    if (!found) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new Str(displayMath ? r'$$' : r'$')), offset);
    }

    String math = text.substring(offset, endOffset);
    if (displayMath) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new TexMathDisplay(math)), endOffset + 2);
    } else {
      int lastCodeUnit = math.codeUnitAt(math.length - 1);
      if (lastCodeUnit == _newLineCodeUnit ||
          lastCodeUnit == _carriageReturnCodeUnit ||
          lastCodeUnit == _spaceCodeUnit ||
          lastCodeUnit == _tabCodeUnit) {
        // Inline math cannot end with space.
        return new ParseResult<Inlines>.success(
            new Inlines.single(new Str(r'$')), offset);
      }

      math = unescapeAndUnreference(math);
      return new ParseResult<Inlines>.success(
          new Inlines.single(new TexMathInline(math)), endOffset + 1);
    }
  }
}
