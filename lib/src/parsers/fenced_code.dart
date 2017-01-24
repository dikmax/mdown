library mdown.src.parsers.fenced_code;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/standard_ast_factory.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/lookup.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for fenced code blocks.
class FencedCodeParser extends AbstractParser<BlockNodeImpl> {
  /// Constructor.
  FencedCodeParser(ParsersContainer container) : super(container);

  static final RegExp _fencedCodeStartTest =
    new RegExp('^( {0,3})(?:(`{3,})([^`]*)|(~{3,})([^~]*))\$');

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    ParseResult<String> lineResult = container.lineParser.parse(text, offset);
    assert(lineResult.isSuccess);

    final Match startRes = _fencedCodeStartTest.firstMatch(lineResult.value);
    if (startRes == null) {
      return const ParseResult<BlockNodeImpl>.failure();
    }

    final int indent = startRes[1].length;
    final String line = startRes[2] ?? startRes[4];
    final String infoString = (startRes[3] ?? startRes[5]).trim();
    final String char = line[0];

    final RegExp endTest = new RegExp('^ {0,3}$char{${line.length},}[ \t]*\$');

    final List<String> code = <String>[];

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

      code.add(line);
    }

    Attributes attributes;
    if (infoString != '') {
      if (container.options.fencedCodeAttributes) {
        final ParseResult<Attributes> parse =
            container.attributesParser.parse(infoString, 0);
        if (parse.isSuccess) {
          attributes = parse.value;
        }
      }
      attributes = attributes ?? _parseInfoString(infoString);
    }
    final CodeBlockImpl codeBlock = new CodeBlockImpl(code, attributes);
    return new ParseResult<BlockNodeImpl>.success(codeBlock, offset);
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
    return astFactory.infoString(infoString);
  }
}
