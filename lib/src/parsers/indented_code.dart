library mdown.src.parsers.indented_code;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for indented code blocks.
class IndentedCodeParser extends AbstractParser<BlockNodeImpl> {
  /// Constructor.
  IndentedCodeParser(ParsersContainer container) : super(container);

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    // Simple test, that we have indent
    final int codeUnit = text.codeUnitAt(offset);
    if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
      return const ParseResult<BlockNodeImpl>.failure();
    }

    // Main code

    final List<String> result = <String>[];
    List<String> rest = <String>[];
    bool firstLine = true;
    final int length = text.length;
    while (offset < length) {
      final ParseResult<String> lineResult =
          container.lineParser.parse(text, offset);
      assert(lineResult.isSuccess);

      final String line = lineResult.value;
      if (isOnlyWhitespace(line)) {
        if (firstLine) {
          break;
        }

        final String codeLine = _codeLine(line);
        if (codeLine != null) {
          rest.add(codeLine);
        } else {
          rest.add('');
        }
      } else {
        final String codeLine = _codeLine(line);
        if (codeLine == null) {
          break;
        }
        if (rest.isNotEmpty) {
          result.addAll(rest);
          rest = <String>[];
        }
        result.add(codeLine);
      }

      firstLine = false;
      offset = lineResult.offset;
    }

    if (result.isEmpty) {
      return const ParseResult<BlockNodeImpl>.failure();
    }

    return new ParseResult<BlockNodeImpl>.success(
        new CodeBlockImpl(result, null), offset);
  }

  // TODO make it work on text
  static String _codeLine(String text, [int offset = 0]) {
    final int length = text.length;
    if (length == offset) {
      return null;
    }

    // First char
    int codeUnit = text.codeUnitAt(offset);
    if (codeUnit == tabCodeUnit) {
      return text.substring(offset + 1);
    }
    if (codeUnit != spaceCodeUnit) {
      return null;
    }

    offset += 1;
    if (offset == length) {
      return null;
    }

    // Second char
    codeUnit = text.codeUnitAt(offset);
    if (codeUnit == tabCodeUnit) {
      return text.substring(offset + 1);
    }
    if (codeUnit != spaceCodeUnit) {
      return null;
    }

    offset++;
    if (offset == length) {
      return null;
    }

    // Third char
    codeUnit = text.codeUnitAt(offset);
    if (codeUnit == tabCodeUnit) {
      return text.substring(offset + 1);
    }
    if (codeUnit != spaceCodeUnit) {
      return null;
    }

    offset++;
    if (offset == length) {
      return null;
    }

    // Fourth char
    codeUnit = text.codeUnitAt(offset);
    if (codeUnit == tabCodeUnit || codeUnit == spaceCodeUnit) {
      return text.substring(offset + 1);
    }

    return null;
  }
}
