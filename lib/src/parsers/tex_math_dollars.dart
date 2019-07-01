library mdown.src.parsers.tex_math_dollars;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parses string between `$...$` and `$$...$$` as TeX Math.
class TexMathDollarsParser extends AbstractParser<InlineNodeImpl> {
  /// Constructor.
  TexMathDollarsParser(ParsersContainer container) : super(container);

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    int off = offset;
    final int length = text.length;
    off++;
    if (off >= length) {
      // Just a `$` at the end of string.
      return ParseResult<InlineNodeImpl>.success(StrImpl(r'$'), off);
    }
    final int codeUnit = text.codeUnitAt(off);
    final bool displayMath = codeUnit == dollarCodeUnit;
    if (displayMath) {
      off += 1;
      if (off >= length) {
        // Just a `$` at the end of string.
        return ParseResult<InlineNodeImpl>.success(StrImpl(r'$$'), off);
      }
    } else {
      if (codeUnit == spaceCodeUnit ||
          codeUnit == tabCodeUnit ||
          codeUnit == newLineCodeUnit ||
          codeUnit == carriageReturnCodeUnit ||
          (codeUnit >= zeroCodeUnit && codeUnit <= nineCodeUnit)) {
        return ParseResult<InlineNodeImpl>.success(StrImpl(r'$'), off);
      }
    }

    int endOffset = off;
    bool found = false;
    while (endOffset < length) {
      final int codeUnit = text.codeUnitAt(endOffset);
      if (codeUnit == backslashCodeUnit) {
        endOffset++;
        if (endOffset >= length) {
          break;
        }
      } else if (codeUnit == dollarCodeUnit) {
        if (displayMath) {
          if (endOffset + 1 < length &&
              text.codeUnitAt(endOffset + 1) == dollarCodeUnit) {
            found = true;
            break;
          }
        } else {
          found = true;
          break;
        }
      }
      endOffset++;
    }

    if (!found) {
      return ParseResult<InlineNodeImpl>.success(
          StrImpl(displayMath ? r'$$' : r'$'), off);
    }

    String math = text.substring(off, endOffset);
    if (displayMath) {
      return ParseResult<InlineNodeImpl>.success(
          TexMathDisplayImpl(math), endOffset + 2);
    } else {
      final int lastCodeUnit = math.codeUnitAt(math.length - 1);
      if (lastCodeUnit == newLineCodeUnit ||
          lastCodeUnit == carriageReturnCodeUnit ||
          lastCodeUnit == spaceCodeUnit ||
          lastCodeUnit == tabCodeUnit) {
        // Inline math cannot end with space.
        return ParseResult<InlineNodeImpl>.success(StrImpl(r'$'), off);
      }

      math = unescapeAndUnreference(math);
      return ParseResult<InlineNodeImpl>.success(
          TexMathInlineImpl(math), endOffset + 1);
    }
  }
}
