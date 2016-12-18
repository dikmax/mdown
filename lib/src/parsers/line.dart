library mdown.src.parsers.line;

import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for any line.
class LineParser extends AbstractParser<String> {
  /// Constructor.
  LineParser(ParsersContainer container) : super(container);

  @override
  ParseResult<String> parse(String text, int offset) {
    final int length = text.length;
    if (offset >= length) {
      return const ParseResult<String>.failure();
    }

    int endOffset = offset;
    int lineEndOffset = length;
    while (endOffset < length) {
      final int codeUnit = text.codeUnitAt(endOffset);
      if (codeUnit == carriageReturnCodeUnit) {
        lineEndOffset = endOffset;
        final int newLineCodeOffset = endOffset + 1;
        if (newLineCodeOffset < length &&
            text.codeUnitAt(newLineCodeOffset) == newLineCodeUnit) {
          endOffset = newLineCodeOffset;
        }
        break;
      } else if (codeUnit == newLineCodeUnit) {
        lineEndOffset = endOffset;
        break;
      }
      endOffset += 1;
    }

    return new ParseResult<String>.success(
        text.substring(offset, lineEndOffset), endOffset + 1);
  }
}
