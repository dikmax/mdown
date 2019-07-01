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
    int off = offset;

    // Simple test, that we have indent
    final int codeUnit = text.codeUnitAt(off);
    if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
      return const ParseResult<BlockNodeImpl>.failure();
    }

    // Main code

    final List<String> result = <String>[];
    List<String> rest = <String>[];
    bool firstLine = true;
    final int length = text.length;
    while (off < length) {
      final ParseResult<String> lineResult =
          container.lineParser.parse(text, off);
      assert(lineResult.isSuccess, 'lineParser should always succeed');

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
      off = lineResult.offset;
    }

    if (result.isEmpty) {
      return const ParseResult<BlockNodeImpl>.failure();
    }

    return ParseResult<BlockNodeImpl>.success(CodeBlockImpl(result, null), off);
  }

  // TODO(dikmax): make it work on text
  static String _codeLine(String text, [int offset = 0]) {
    int off = offset;
    final int length = text.length;
    if (length == off) {
      return null;
    }

    // First char
    int codeUnit = text.codeUnitAt(off);
    if (codeUnit == tabCodeUnit) {
      return text.substring(off + 1);
    }
    if (codeUnit != spaceCodeUnit) {
      return null;
    }

    off += 1;
    if (off == length) {
      return null;
    }

    // Second char
    codeUnit = text.codeUnitAt(off);
    if (codeUnit == tabCodeUnit) {
      return text.substring(off + 1);
    }
    if (codeUnit != spaceCodeUnit) {
      return null;
    }

    off++;
    if (off == length) {
      return null;
    }

    // Third char
    codeUnit = text.codeUnitAt(off);
    if (codeUnit == tabCodeUnit) {
      return text.substring(off + 1);
    }
    if (codeUnit != spaceCodeUnit) {
      return null;
    }

    off++;
    if (off == length) {
      return null;
    }

    // Fourth char
    codeUnit = text.codeUnitAt(off);
    if (codeUnit == tabCodeUnit || codeUnit == spaceCodeUnit) {
      return text.substring(off + 1);
    }

    return null;
  }
}
