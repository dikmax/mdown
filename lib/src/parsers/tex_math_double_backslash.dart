library md_proc.src.parsers.tex_math_double_backslash;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/inlines.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/container.dart';

/// Parses TeX Match between `\\(...\\)` and `\\[...\\]`.
class TexMathDoubleBackslashParser extends AbstractParser<Inlines> {
  /// Constructor.
  TexMathDoubleBackslashParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    final int length = text.length;
    if (offset + 2 >= length ||
        text.codeUnitAt(offset) != backslashCodeUnit ||
        text.codeUnitAt(offset + 1) != backslashCodeUnit) {
      return new ParseResult<Inlines>.failure();
    }

    offset += 2;
    final int codeUnit = text.codeUnitAt(offset);
    if (codeUnit != openParenCodeUnit && codeUnit != openBracketCodeUnit) {
      return new ParseResult<Inlines>.failure();
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
      return new ParseResult<Inlines>.failure();
    }

    final String math = text.substring(offset, endOffset);
    if (displayMath) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new TexMathDisplay(math)), endOffset + 3);
    } else {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new TexMathInline(math)), endOffset + 3);
    }
  }
}
