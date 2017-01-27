library mdown.src.parsers.hard_line_break;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for hard line breaks.
class HardLineBreakParser extends AbstractStringParser<InlineNodeImpl> {
  /// Constructor.
  HardLineBreakParser(ParsersContainer container) : super(container);

  static const int _stateFirstOpenSpace = 0;
  static const int _stateOtherOpenChars = 1;
  static const int _stateCarriageReturn = 2;
  static const int _stateDone = 3;
  static const int _stateFailure = 4;

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    // Finite Automata
    final int firstCodeUnit = text.codeUnitAt(offset);
    offset++;
    final int length = text.length;
    int state = firstCodeUnit == spaceCodeUnit
        ? _stateFirstOpenSpace
        : _stateOtherOpenChars;
    while (offset < length) {
      final int codeUnit = text.codeUnitAt(offset);

      switch (state) {
        case _stateFirstOpenSpace:
          // After first open space.
          if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
            state = _stateFailure;
          } else {
            state = _stateOtherOpenChars;
          }

          break;

        case _stateOtherOpenChars:
          // Parsing code
          if (codeUnit == carriageReturnCodeUnit) {
            state = _stateCarriageReturn;
          } else if (codeUnit == newLineCodeUnit) {
            state = _stateDone;
          } else if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
            state = _stateFailure;
          }

          break;

        case _stateCarriageReturn:
          if (codeUnit != newLineCodeUnit) {
            offset--;
          }

          state = _stateDone;
          break;
      }

      if (state == _stateDone || state == _stateFailure) {
        offset++;
        break;
      }

      offset++;
    }

    if (state == _stateDone || state == _stateCarriageReturn) {
      return new ParseResult<InlineNodeImpl>.success(
          new HardLineBreakImpl(), offset);
    } else {
      return new ParseResult<InlineNodeImpl>.failure();
    }
  }
}
