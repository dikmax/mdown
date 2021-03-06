library mdown.src.parsers.str;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/bit_set.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for arbitrary string.
class StrParser extends AbstractParser<InlineNodeImpl> {
  /// Constructor.
  StrParser(ParsersContainer container) : super(container);

  final BitSet _specialChars = BitSet(256);

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
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    final int char = text.codeUnitAt(offset);
    final int length = text.length;
    if (_specialChars.contains(char)) {
      InlineNodeImpl result;
      int endOffset = offset + 1;
      if (char == spaceCodeUnit) {
        while (
            endOffset < length && text.codeUnitAt(endOffset) == spaceCodeUnit) {
          endOffset += 1;
        }
        result = SpaceImpl(endOffset - offset);
      } else if (char == tabCodeUnit) {
        while (
            endOffset < length && text.codeUnitAt(endOffset) == tabCodeUnit) {
          endOffset += 1;
        }
        result = TabImpl(endOffset - offset);
      } else if (char == nonBreakableSpaceCodeUnit) {
        while (endOffset < length &&
            text.codeUnitAt(endOffset) == nonBreakableSpaceCodeUnit) {
          endOffset += 1;
        }
        result = NonBreakableSpaceImpl(endOffset - offset);
      } else {
        result = StrImpl(String.fromCharCode(char));
      }
      return ParseResult<InlineNodeImpl>.success(result, endOffset);
    } else {
      int endOffset = offset + 1;
      while (endOffset < length &&
          !_specialChars.contains(text.codeUnitAt(endOffset))) {
        endOffset += 1;
      }

      return ParseResult<InlineNodeImpl>.success(
          StrImpl(text.substring(offset, endOffset)), endOffset);
    }
  }
}
