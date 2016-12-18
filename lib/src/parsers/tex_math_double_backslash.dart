library mdown.src.parsers.tex_math_double_backslash;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parses TeX Match between `\\(...\\)` and `\\[...\\]`.
class TexMathDoubleBackslashParser extends AbstractParser<InlineNodeImpl> {
  /// Constructor.
  TexMathDoubleBackslashParser(ParsersContainer container) : super(container);

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    final int length = text.length;
    if (offset + 2 >= length ||
        text.codeUnitAt(offset) != backslashCodeUnit ||
        text.codeUnitAt(offset + 1) != backslashCodeUnit) {
      return new ParseResult<InlineNodeImpl>.failure();
    }

    offset += 2;
    final int codeUnit = text.codeUnitAt(offset);
    if (codeUnit != openParenCodeUnit && codeUnit != openBracketCodeUnit) {
      return new ParseResult<InlineNodeImpl>.failure();
    }
    final bool displayMath = codeUnit == openBracketCodeUnit;
    final int closeCodeUnit =
        displayMath ? closeBracketCodeUnit : closeParenCodeUnit;
    offset++;
    int endOffset = offset;
    bool found = false;
    while (endOffset < length - 2) {
      if (text.codeUnitAt(endOffset) == backslashCodeUnit &&
          text.codeUnitAt(endOffset + 1) == backslashCodeUnit &&
          text.codeUnitAt(endOffset + 2) == closeCodeUnit) {
        found = true;
        break;
      }
      endOffset++;
    }

    if (!found) {
      return new ParseResult<InlineNodeImpl>.failure();
    }

    final String math = text.substring(offset, endOffset);
    if (displayMath) {
      return new ParseResult<InlineNodeImpl>.success(
          new TexMathDisplayImpl(math), endOffset + 3);
    } else {
      return new ParseResult<InlineNodeImpl>.success(
          new TexMathInlineImpl(math), endOffset + 3);
    }
  }
}
