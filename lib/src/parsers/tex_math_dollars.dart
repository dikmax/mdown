library mdown.src.parsers.tex_math_dollars;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/code_units_list.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parses string between `$...$` and `$$...$$` as TeX Math.
class TexMathDollarsParser extends AbstractStringParser<InlineNodeImpl> {
  /// Constructor.
  TexMathDollarsParser(ParsersContainer container) : super(container);

  CodeUnitsList _oneDollar = new CodeUnitsList.single(dollarCodeUnit);
  CodeUnitsList _twoDollars = new CodeUnitsList.string(r'$$');

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    final int length = text.length;
    offset++;
    if (offset >= length) {
      // Just a `$` at the end of string.
      return new ParseResult<InlineNodeImpl>.success(
          new StrImpl(_oneDollar), offset);
    }
    final int codeUnit = text.codeUnitAt(offset);
    final bool displayMath = codeUnit == dollarCodeUnit;
    if (displayMath) {
      offset += 1;
      if (offset >= length) {
        // Just a `$` at the end of string.
        return new ParseResult<InlineNodeImpl>.success(
            new StrImpl(_twoDollars), offset);
      }
    } else {
      if (codeUnit == spaceCodeUnit ||
          codeUnit == tabCodeUnit ||
          codeUnit == newLineCodeUnit ||
          codeUnit == carriageReturnCodeUnit ||
          (codeUnit >= zeroCodeUnit && codeUnit <= nineCodeUnit)) {
        return new ParseResult<InlineNodeImpl>.success(
            new StrImpl(new CodeUnitsList.single(dollarCodeUnit)), offset);
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
      return new ParseResult<InlineNodeImpl>.success(
          new StrImpl(displayMath ? _twoDollars : _oneDollar), offset);
    }

    String math = text.substring(offset, endOffset);
    if (displayMath) {
      return new ParseResult<InlineNodeImpl>.success(
          new TexMathDisplayImpl(math), endOffset + 2);
    } else {
      final int lastCodeUnit = math.codeUnitAt(math.length - 1);
      if (lastCodeUnit == newLineCodeUnit ||
          lastCodeUnit == carriageReturnCodeUnit ||
          lastCodeUnit == spaceCodeUnit ||
          lastCodeUnit == tabCodeUnit) {
        // Inline math cannot end with space.
        return new ParseResult<InlineNodeImpl>.success(
            new StrImpl(_oneDollar), offset);
      }

      math = unescapeAndUnreference(math);
      return new ParseResult<InlineNodeImpl>.success(
          new TexMathInlineImpl(math), endOffset + 1);
    }
  }
}
