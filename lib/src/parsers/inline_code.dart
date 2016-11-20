part of md_proc.src.parsers;

/// Parser for code inlines.
class InlineCodeParser extends AbstractParser<Inlines> {
  /// Constructor.
  InlineCodeParser(ParsersContainer container) : super(container);

  static const int _stateOpenFence = 0;
  static const int _stateCode = 1;
  static const int _stateCloseFence = 2;
  static const int _stateDone = 3;

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    int fenceSize = 1;
    offset++;

    // Finite Automata
    final int length = text.length;
    int state = _stateOpenFence;
    int codeStartOffset = -1;
    int endFenceSize = 0;
    int codeEndOffset = -1;
    while (offset < length) {
      final int codeUnit = text.codeUnitAt(offset);

      switch (state) {
        case _stateOpenFence:
          // Parsing open fence.
          if (codeUnit == _backtickCodeUnit) {
            fenceSize++;
          } else {
            state = _stateCode;
            codeStartOffset = offset;
          }
          break;

        case _stateCode:
          // Parsing code
          if (codeUnit == _backtickCodeUnit) {
            codeEndOffset = offset;
            endFenceSize = 1;
            state = _stateCloseFence;
          }

          break;

        case _stateCloseFence:
          // Parsing end
          if (codeUnit == _backtickCodeUnit) {
            endFenceSize++;
          } else if (endFenceSize == fenceSize) {
            state = _stateDone;
          } else {
            state = _stateCode;
          }
          break;
      }

      if (state == _stateDone) {
        // Done.
        break;
      }

      offset++;
    }

    if (state == _stateDone ||
        (state == _stateCloseFence && endFenceSize == fenceSize)) {
      final String code =
          _trimAndReplaceSpaces(text.substring(codeStartOffset, codeEndOffset));
      Attr attributes = new EmptyAttr();
      if (container.options.inlineCodeAttributes) {
        if (offset < length && text.codeUnitAt(offset) == _openBraceCodeUnit) {
          final ParseResult<Attributes> attributesResult =
              container.attributesParser.parse(text, offset);
          if (attributesResult.isSuccess) {
            attributes = attributesResult.value;
            offset = attributesResult.offset;
          }
        }
      }
      return new ParseResult<Inlines>.success(
          new Inlines.single(
              new Code(code, fenceSize: fenceSize, attributes: attributes)),
          offset);
    }

    return new ParseResult<Inlines>.success(
        new Inlines.single(new Str('`' * fenceSize)),
        codeStartOffset == -1 ? offset : codeStartOffset);
  }
}
