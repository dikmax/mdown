library md_proc.src.parsers.indented_code;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/common.dart';
import 'package:md_proc/src/parsers/container.dart';

/// Parser for indented code blocks.
class IndentedCodeParser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  IndentedCodeParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    // Simple test, that we have indent
    final int codeUnit = text.codeUnitAt(offset);
    if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
      return const ParseResult<Iterable<Block>>.failure();
    }

    // Main code

    final StringBuffer result = new StringBuffer();
    StringBuffer rest = new StringBuffer();
    bool firstLine = true;
    final int length = text.length;
    while (offset < length) {
      final ParseResult<String> lineResult =
          container.lineParser.parse(text, offset);
      assert(lineResult.isSuccess);

      final String line = lineResult.value;
      final Match emptyLine = emptyLineRegExp.firstMatch(line);
      if (emptyLine != null) {
        if (firstLine) {
          break;
        }

        final String codeLine = _codeLine(line);
        if (codeLine != null) {
          rest.writeln(codeLine);
        } else {
          rest.writeln();
        }
      } else {
        final String codeLine = _codeLine(line);
        if (codeLine == null) {
          break;
        }
        if (rest.length > 0) {
          result.write(rest);
          rest = new StringBuffer();
        }
        result.writeln(codeLine);
      }

      firstLine = false;
      offset = lineResult.offset;
    }

    if (result.length == 0) {
      return const ParseResult<Iterable<Block>>.failure();
    }

    return new ParseResult<Iterable<Block>>.success(
        <IndentedCodeBlock>[new IndentedCodeBlock(result.toString())], offset);
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

    offset++;
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
