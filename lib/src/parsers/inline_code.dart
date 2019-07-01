library mdown.src.parsers.inline_code;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for code inlines.
class InlineCodeParser extends AbstractParser<InlineNodeImpl> {
  /// Constructor.
  InlineCodeParser(ParsersContainer container) : super(container);

  static const int _stateOpenFence = 0;
  static const int _stateCode = 1;
  static const int _stateCloseFence = 2;
  static const int _stateDone = 3;

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    int off = offset;
    int fenceSize = 1;
    off++;

    // Finite Automata
    final int length = text.length;
    int state = _stateOpenFence;
    int codeStartOffset = -1;
    int endFenceSize = 0;
    int codeEndOffset = -1;
    while (off < length) {
      final int codeUnit = text.codeUnitAt(off);

      switch (state) {
        case _stateOpenFence:
          // Parsing open fence.
          if (codeUnit == backtickCodeUnit) {
            fenceSize++;
          } else {
            state = _stateCode;
            codeStartOffset = off;
          }
          break;

        case _stateCode:
          // Parsing code
          if (codeUnit == backtickCodeUnit) {
            codeEndOffset = off;
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

      off++;
    }

    if (state == _stateDone ||
        (state == _stateCloseFence && endFenceSize == fenceSize)) {
      final String code =
          trimAndReplaceSpaces(text.substring(codeStartOffset, codeEndOffset));
      ExtendedAttributes attributes;
      if (container.options.inlineCodeAttributes) {
        if (off < length && text.codeUnitAt(off) == openBraceCodeUnit) {
          final ParseResult<Attributes> attributesResult =
              container.attributesParser.parse(text, off);
          if (attributesResult.isSuccess) {
            attributes = attributesResult.value;
            off = attributesResult.offset;
          }
        }
      }
      return ParseResult<InlineNodeImpl>.success(
          CodeImpl(code, fenceSize, attributes), off);
    }

    return ParseResult<InlineNodeImpl>.success(StrImpl('`' * fenceSize),
        codeStartOffset == -1 ? off : codeStartOffset);
  }
}
