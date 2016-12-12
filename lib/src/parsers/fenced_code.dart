library md_proc.src.parsers.fenced_code;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/common.dart';
import 'package:md_proc/src/parsers/container.dart';

/// Parser for fenced code blocks.
class FencedCodeParser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  FencedCodeParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    ParseResult<String> lineResult = container.lineParser.parse(text, offset);
    assert(lineResult.isSuccess);

    final Match startRes = fencedCodeStartTest.firstMatch(lineResult.value);
    if (startRes == null) {
      return const ParseResult<Iterable<FencedCodeBlock>>.failure();
    }

    final int indent = startRes[1].length;
    final String line = startRes[2] ?? startRes[4];
    final String infoString = (startRes[3] ?? startRes[5]).trim();
    final String char = line[0];

    final RegExp endTest = new RegExp('^ {0,3}$char{${line.length},}[ \t]*\$');

    final StringBuffer code = new StringBuffer();

    offset = lineResult.offset;
    final int length = text.length;
    while (offset < length) {
      lineResult = container.lineParser.parse(text, offset);
      assert(lineResult.isSuccess);

      String line = lineResult.value;
      offset = lineResult.offset;

      final Match endResult = endTest.firstMatch(line);
      if (endResult != null) {
        break;
      }

      if (indent > 0) {
        line = removeIndent(line, indent, true);
      }

      code.writeln(line);
    }

    Attr attributes;
    if (infoString != '') {
      if (container.options.fencedCodeAttributes) {
        final ParseResult<Attributes> parse =
            container.attributesParser.parse(infoString, 0);
        if (parse.isSuccess) {
          attributes = parse.value;
        }
      }
      attributes = attributes ?? _parseInfoString(infoString);
    } else {
      attributes = new EmptyAttr();
    }
    final FencedCodeBlock codeBlock = new FencedCodeBlock(code.toString(),
        fenceType: FenceType.fromChar(char),
        fenceSize: line.length,
        attributes: attributes);
    return new ParseResult<Iterable<FencedCodeBlock>>.success(
        <FencedCodeBlock>[codeBlock], offset);
  }

  InfoString _parseInfoString(String infoString) {
    int infoStringEnd = 0;
    final int infoStringLength = infoString.length;
    while (infoStringEnd < infoStringLength) {
      final int codeUnit = infoString.codeUnitAt(infoStringEnd);
      if (codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit) {
        break;
      }
      infoStringEnd++;
    }
    if (infoStringEnd != infoStringLength) {
      infoString = infoString.substring(0, infoStringEnd);
    }
    infoString = unescapeAndUnreference(infoString);
    return new InfoString(infoString);
  }
}
