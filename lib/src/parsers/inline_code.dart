library mdown.src.parsers.inline_code;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/code_units_list.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for code inlines.
class InlineCodeParser extends AbstractListParser<InlineNodeImpl> {
  /// Constructor.
  InlineCodeParser(ParsersContainer container) : super(container);

  static const int _stateOpenFence = 0;
  static const int _stateCode = 1;
  static const int _stateCloseFence = 2;
  static const int _stateDone = 3;

  @override
  ParseResult<InlineNodeImpl> parseList(CodeUnitsList list, int offset) {
    int fenceSize = 1;
    offset++;

    // Finite Automata
    final int length = list.length;
    int state = _stateOpenFence;
    int codeStartOffset = -1;
    int endFenceSize = 0;
    int codeEndOffset = -1;
    while (offset < length) {
      final int codeUnit = list[offset];

      switch (state) {
        case _stateOpenFence:
          // Parsing open fence.
          if (codeUnit == backtickCodeUnit) {
            fenceSize++;
          } else {
            state = _stateCode;
            codeStartOffset = offset;
          }
          break;

        case _stateCode:
          // Parsing code
          if (codeUnit == backtickCodeUnit) {
            codeEndOffset = offset;
            endFenceSize = 1;
            state = _stateCloseFence;
          }

          break;

        case _stateCloseFence:
          // Parsing end
          if (codeUnit == backtickCodeUnit) {
            endFenceSize++;
          } else if (endFenceSize == fenceSize) {
            state = _stateDone;
          } else {
            state = _stateCode;
          }
          break;
      }

      if (state == _stateDone) {
        // Done.
        break;
      }

      offset++;
    }

    if (state == _stateDone ||
        (state == _stateCloseFence && endFenceSize == fenceSize)) {
      final CodeUnitsList code =
          trimAndReplaceSpaces(list.sublist(codeStartOffset, codeEndOffset));
      ExtendedAttributes attributes;
      if (container.options.inlineCodeAttributes) {
        if (offset < length && list[offset] == openBraceCodeUnit) {
          final ParseResult<Attributes> attributesResult =
              container.attributesParser.parse(list.toString(), offset);
          if (attributesResult.isSuccess) {
            attributes = attributesResult.value;
            offset = attributesResult.offset;
          }
        }
      }
      return new ParseResult<InlineNodeImpl>.success(
          new CodeImpl(code, fenceSize, attributes), offset);
    }

    return new ParseResult<InlineNodeImpl>.success(new StrImpl(
        new CodeUnitsList.multiple(backtickCodeUnit, fenceSize)),
        codeStartOffset == -1 ? offset : codeStartOffset);
  }
}
