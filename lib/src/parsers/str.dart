library md_proc.src.parsers.str;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/inlines.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/container.dart';

/// Parser for arbitrary string.
class StrParser extends AbstractParser<Inlines> {
  final Set<int> _specialChars = new Set<int>.from(<int>[
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

  /// Constructor.
  StrParser(ParsersContainer container) : super(container) {
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
  ParseResult<Inlines> parse(String text, int offset) {
    final int char = text.codeUnitAt(offset);
    if (_specialChars.contains(char)) {
      Inline result;
      if (char == spaceCodeUnit) {
        result = new Space();
      } else if (char == tabCodeUnit) {
        result = new Tab();
      } else if (char == nonBreakableSpaceCodeUnit) {
        result = new NonBreakableSpace();
      } else {
        result = new Str(text[offset]);
      }
      return new ParseResult<Inlines>.success(
          new Inlines.single(result), offset + 1);
    } else {
      int endOffset = offset + 1;
      final int length = text.length;
      while (endOffset < length &&
          !_specialChars.contains(text.codeUnitAt(endOffset))) {
        endOffset++;
      }

      return new ParseResult<Inlines>.success(
          new Inlines.single(new Str(text.substring(offset, endOffset))),
          endOffset);
    }
  }
}
