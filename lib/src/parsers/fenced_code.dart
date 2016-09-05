part of md_proc.src.parsers;

/// Parser for fenced code blocks.
class FencedCodeParser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  FencedCodeParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    ParseResult<String> lineResult = container.lineParser.parse(text, offset);
    assert(lineResult.isSuccess);

    Match startRes = _fencedCodeStartTest.firstMatch(lineResult.value);
    if (startRes == null) {
      return const ParseResult<Iterable<FencedCodeBlock>>.failure();
    }

    int indent = startRes[1].length;
    String line = startRes[2] ?? startRes[4];
    String infoString = (startRes[3] ?? startRes[5]).trim();
    String char = line[0];

    RegExp endTest = new RegExp('^ {0,3}$char{${line.length},}[ \t]*\$');

    StringBuffer code = new StringBuffer();

    offset = lineResult.offset;
    int length = text.length;
    while (offset < length) {
      lineResult = container.lineParser.parse(text, offset);
      assert(lineResult.isSuccess);

      String line = lineResult.value;
      offset = lineResult.offset;

      Match endResult = endTest.firstMatch(line);
      if (endResult != null) {
        break;
      }

      if (indent > 0) {
        line = _removeIndent(line, indent, true);
      }

      code.writeln(line);
    }

    Attr attributes;
    if (infoString != '') {
      Match space = _whitespaceCharRegExp.firstMatch(infoString);
      if (space != null) {
        infoString = infoString.substring(0, space.start);
      }
      infoString = unescapeAndUnreference(infoString);
      attributes = new InfoString(infoString);
    } else {
      attributes = new EmptyAttr();
    }
    FencedCodeBlock codeBlock = new FencedCodeBlock(code.toString(),
        fenceType: FenceType.fromChar(char),
        fenceSize: line.length,
        attributes: attributes);
    return new ParseResult<Iterable<FencedCodeBlock>>.success(
        <FencedCodeBlock>[codeBlock], offset);
  }
}
