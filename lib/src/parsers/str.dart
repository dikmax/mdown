library mdown.src.parsers.str;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/bit_set.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/code_units_list.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for arbitrary string.
class StrParser extends AbstractListParser<InlineNodeImpl> {
  final BitSet _specialChars = new BitSet(256);

  /// Constructor.
  StrParser(ParsersContainer container) : super(container);

  @override
  void init() {
    _specialChars.addAll(<int>[
      ampersandCodeUnit,
      backtickCodeUnit,
      closeBracketCodeUnit,
      exclamationMarkCodeUnit,
      lessThanCodeUnit,
      nonBreakableSpaceCodeUnit,
      newLineCodeUnit,
      openBracketCodeUnit,
      backslashCodeUnit,
      spaceCodeUnit,
      starCodeUnit,
      tabCodeUnit,
      underscoreCodeUnit
    ]);

    if (container.options.smartPunctuation) {
      _specialChars.addAll(<int>[
        dotCodeUnit,
        minusCodeUnit,
        singleQuoteCodeUnit,
        doubleQuoteCodeUnit
      ]);
    }

    if (container.options.strikeout || container.options.subscript) {
      _specialChars.add(tildeCodeUnit);
    }

    if (container.options.superscript) {
      _specialChars.add(caretCodeUnit);
    }

    if (container.options.texMathDollars) {
      _specialChars.add(dollarCodeUnit);
    }
  }

  @override
  ParseResult<InlineNodeImpl> parseList(CodeUnitsList list, int offset) {
    final int codeUnit = list[offset];
    final int length = list.length;
    if (_specialChars.contains(codeUnit)) {
      InlineNodeImpl result;
      int endOffset = offset + 1;
      if (codeUnit == spaceCodeUnit) {
        while (
            endOffset < length && list[endOffset] == spaceCodeUnit) {
          endOffset += 1;
        }
        result = new SpaceImpl(endOffset - offset);
      } else if (codeUnit == tabCodeUnit) {
        while (
            endOffset < length && list[endOffset] == tabCodeUnit) {
          endOffset += 1;
        }
        result = new TabImpl(endOffset - offset);
      } else if (codeUnit == nonBreakableSpaceCodeUnit) {
        while (endOffset < length &&
            list[endOffset] == nonBreakableSpaceCodeUnit) {
          endOffset += 1;
        }
        result = new NonBreakableSpaceImpl(endOffset - offset);
      } else {
        result = new StrImpl(new CodeUnitsList.single(codeUnit));
      }
      return new ParseResult<InlineNodeImpl>.success(result, endOffset);
    } else {
      int endOffset = offset + 1;
      while (endOffset < length &&
          !_specialChars.contains(list[endOffset])) {
        endOffset += 1;
      }

      return new ParseResult<InlineNodeImpl>.success(
          new StrImpl(list.sublist(offset, endOffset)), endOffset);
    }
  }
}
