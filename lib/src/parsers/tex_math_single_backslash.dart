library mdown.src.parsers.tex_math_single_backslash;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parses TeX Match between `\(...\)` and `\[...\]`.
class TexMathSingleBackslashParser extends AbstractParser<InlineNodeImpl> {
  /// Constructor.
  TexMathSingleBackslashParser(ParsersContainer container) : super(container);

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    int off = offset + 1;
    final int length = text.length;
    if (off >= length) {
      return ParseResult<InlineNodeImpl>.success(StrImpl('\\'), off);
    }
    final int codeUnit = text.codeUnitAt(off);
    if (codeUnit != openParenCodeUnit && codeUnit != openBracketCodeUnit) {
      return const ParseResult<InlineNodeImpl>.failure();
    }
    final bool displayMath = codeUnit == openBracketCodeUnit;
    final int closeCodeUnit =
        displayMath ? closeBracketCodeUnit : closeParenCodeUnit;
    off++;
    int endOffset = off;
    bool found = false;
    while (endOffset < length - 1) {
      if (text.codeUnitAt(endOffset) == backslashCodeUnit &&
          text.codeUnitAt(endOffset + 1) == closeCodeUnit) {
        found = true;
        break;
      }
      endOffset++;
    }

    if (!found) {
      return const ParseResult<InlineNodeImpl>.failure();
    }

    final String math = text.substring(off, endOffset);
    if (displayMath) {
      return ParseResult<InlineNodeImpl>.success(
          TexMathDisplayImpl(math), endOffset + 2);
    } else {
      return ParseResult<InlineNodeImpl>.success(
          TexMathInlineImpl(math), endOffset + 2);
    }
  }
}
