library mdown.src.parsers.ellipsis;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/code_units_list.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for ellipsis.
class EllipsisParser extends AbstractListParser<InlineNodeImpl> {
  /// Constructor.
  EllipsisParser(ParsersContainer container) : super(container);

  @override
  ParseResult<InlineNodeImpl> parseList(CodeUnitsList list, int offset) {
    if (offset + 2 < list.length &&
        list[offset] == dotCodeUnit &&
        list[offset + 1] == dotCodeUnit &&
        list[offset + 2] == dotCodeUnit) {
      return new ParseResult<InlineNodeImpl>.success(
          new SmartCharImpl(SmartCharType.ellipsis), offset + 3);
    }

    return new ParseResult<InlineNodeImpl>.failure();
  }
}
