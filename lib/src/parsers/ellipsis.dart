library mdown.src.parsers.ellipsis;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for ellipsis.
class EllipsisParser extends AbstractParser<InlineNodeImpl> {
  /// Constructor.
  EllipsisParser(ParsersContainer container) : super(container);

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    if (offset + 2 < text.length &&
        text.codeUnitAt(offset) == dotCodeUnit &&
        text.codeUnitAt(offset + 1) == dotCodeUnit &&
        text.codeUnitAt(offset + 2) == dotCodeUnit) {
      return new ParseResult<InlineNodeImpl>.success(
          new SmartCharImpl(SmartCharType.ellipsis), offset + 3);
    }

    return const ParseResult<InlineNodeImpl>.failure();
  }
}
