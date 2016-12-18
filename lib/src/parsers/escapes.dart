library mdown.src.parsers.escapes;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for escaped chars.
class EscapesParser extends AbstractParser<InlineNodeImpl> {
  /// Constructor.
  EscapesParser(ParsersContainer container) : super(container);

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    // At this point we know that text[offset] == '\'
    if (offset + 1 < text.length) {
      final int codeUnit = text.codeUnitAt(offset + 1);
      if (escapableCodes.contains(codeUnit)) {
        return new ParseResult<InlineNodeImpl>.success(
            new StrImpl(new String.fromCharCode(codeUnit)), offset + 2);
      } else if (codeUnit == newLineCodeUnit) {
        return new ParseResult<InlineNodeImpl>.success(
            new HardLineBreakImpl(), offset + 2);
      }
    }

    return new ParseResult<InlineNodeImpl>.failure();
  }
}
