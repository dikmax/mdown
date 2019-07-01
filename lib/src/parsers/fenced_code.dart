library mdown.src.parsers.fenced_code;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/standard_ast_factory.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for fenced code blocks.
class FencedCodeParser extends AbstractParser<BlockNodeImpl> {
  /// Constructor.
  FencedCodeParser(ParsersContainer container) : super(container);

  static final RegExp _fencedCodeStartTest =
      RegExp('^( {0,3})(?:(`{3,})([^`]*)|(~{3,})([^~]*))\$');

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    int off = offset;

    ParseResult<String> lineResult = container.lineParser.parse(text, off);
    assert(lineResult.isSuccess, 'lineParser should always succeed');

    final Match startRes = _fencedCodeStartTest.firstMatch(lineResult.value);
    if (startRes == null) {
      return const ParseResult<BlockNodeImpl>.failure();
    }

    final int indent = startRes[1].length;
    final String line = startRes[2] ?? startRes[4];
    final String infoString = (startRes[3] ?? startRes[5]).trim();
    final String char = line[0];

    final RegExp endTest = RegExp('^ {0,3}$char{${line.length},}[ \t]*\$');

    final List<String> code = <String>[];

    off = lineResult.offset;
    final int length = text.length;
    while (off < length) {
      lineResult = container.lineParser.parse(text, off);
      assert(lineResult.isSuccess, 'lineParser should always succeed');

      String line = lineResult.value;
      off = lineResult.offset;

      final Match endResult = endTest.firstMatch(line);
      if (endResult != null) {
        break;
      }

      if (indent > 0) {
        line = removeIndent(line, indent, allowLess: true);
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
    final CodeBlockImpl codeBlock = CodeBlockImpl(code, attributes);
    return ParseResult<BlockNodeImpl>.success(codeBlock, off);
  }

  InfoString _parseInfoString(String infoString) {
    String infoStringText = infoString;

    int infoStringEnd = 0;
    final int infoStringLength = infoStringText.length;
    while (infoStringEnd < infoStringLength) {
      final int codeUnit = infoStringText.codeUnitAt(infoStringEnd);
      if (codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit) {
        break;
      }
      infoStringEnd++;
    }
    if (infoStringEnd != infoStringLength) {
      infoStringText = infoStringText.substring(0, infoStringEnd);
    }
    infoStringText = unescapeAndUnreference(infoStringText);
    return astFactory.infoString(infoStringText);
  }
}
