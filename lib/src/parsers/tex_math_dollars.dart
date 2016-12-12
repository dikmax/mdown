library md_proc.src.parsers.tex_math_dollars;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/inlines.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/common.dart';
import 'package:md_proc/src/parsers/container.dart';

/// Parses string between `$...$` and `$$...$$` as TeX Math.
class TexMathDollarsParser extends AbstractParser<Inlines> {
  /// Constructor.
  TexMathDollarsParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    final int length = text.length;
    offset++;
    if (offset >= length) {
      // Just a `$` at the end of string.
      return new ParseResult<Inlines>.success(
          new Inlines.single(new Str(r'$')), offset);
    }
    final int codeUnit = text.codeUnitAt(offset);
    final bool displayMath = codeUnit == dollarCodeUnit;
    if (displayMath) {
      offset += 1;
      if (offset >= length) {
        // Just a `$` at the end of string.
        return new ParseResult<Inlines>.success(
            new Inlines.single(new Str(r'$$')), offset);
      }
    } else {
      if (codeUnit == spaceCodeUnit ||
          codeUnit == tabCodeUnit ||
          codeUnit == newLineCodeUnit ||
          codeUnit == carriageReturnCodeUnit ||
          (codeUnit >= zeroCodeUnit && codeUnit <= nineCodeUnit)) {
        return new ParseResult<Inlines>.success(
            new Inlines.single(new Str(r'$')), offset);
      }
    }

    int endOffset = offset;
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
      return new ParseResult<Inlines>.success(
          new Inlines.single(new Str(displayMath ? r'$$' : r'$')), offset);
    }

    String math = text.substring(offset, endOffset);
    if (displayMath) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new TexMathDisplay(math)), endOffset + 2);
    } else {
      final int lastCodeUnit = math.codeUnitAt(math.length - 1);
      if (lastCodeUnit == newLineCodeUnit ||
          lastCodeUnit == carriageReturnCodeUnit ||
          lastCodeUnit == spaceCodeUnit ||
          lastCodeUnit == tabCodeUnit) {
        // Inline math cannot end with space.
        return new ParseResult<Inlines>.success(
            new Inlines.single(new Str(r'$')), offset);
      }

      math = unescapeAndUnreference(math);
      return new ParseResult<Inlines>.success(
          new Inlines.single(new TexMathInline(math)), endOffset + 1);
    }
  }
}
