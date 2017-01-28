library mdown.src.parsers.escapes;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/code_units_list.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for escaped chars.
class EscapesParser extends AbstractListParser<InlineNodeImpl> {
  /// Constructor.
  EscapesParser(ParsersContainer container) : super(container);

  @override
  ParseResult<InlineNodeImpl> parseList(CodeUnitsList list, int offset) {
    // At this point we know that text[offset] == '\'
    if (offset + 1 < list.length) {
      final int codeUnit = list[offset + 1];
      if (escapableCodes.contains(codeUnit)) {
        return new ParseResult<InlineNodeImpl>.success(
            new StrImpl(new CodeUnitsList.single(codeUnit)), offset + 2);
      } else if (codeUnit == newLineCodeUnit) {
        return new ParseResult<InlineNodeImpl>.success(
            new HardLineBreakImpl(), offset + 2);
      }
    }

    return new ParseResult<InlineNodeImpl>.failure();
  }
}
