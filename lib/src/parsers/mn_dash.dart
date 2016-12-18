library mdown.src.parsers.mn_dash;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/ast/combining_nodes.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for mdashes and ndashes.
class MNDashParser extends AbstractParser<InlineNodeImpl> {
  /// Constructor.
  MNDashParser(ParsersContainer container) : super(container);

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    final int length = text.length;
    int count = 0;
    while (offset < length && text.codeUnitAt(offset) == minusCodeUnit) {
      count++;
      offset++;
    }
    if (count > 1) {
      List<InlineNodeImpl> result;
      if (count % 3 == 0) {
        result = new List<InlineNodeImpl>.filled(
            count ~/ 3, new SmartCharImpl(SmartCharType.mdash));
      } else if (count % 2 == 0) {
        result = new List<InlineNodeImpl>.filled(
            count ~/ 2, new SmartCharImpl(SmartCharType.ndash));
      } else if (count % 3 == 2) {
        result = new List<InlineNodeImpl>.filled(
            count ~/ 3, new SmartCharImpl(SmartCharType.mdash),
            growable: true);
        result.add(new SmartCharImpl(SmartCharType.ndash));
      } else {
        // count % 3 == 1
        result = new List<InlineNodeImpl>.filled(
            (count - 4) ~/ 3, new SmartCharImpl(SmartCharType.mdash),
            growable: true);
        result.add(new SmartCharImpl(SmartCharType.ndash));
        result.add(new SmartCharImpl(SmartCharType.ndash));
      }
      if (result.length == 1) {
        return new ParseResult<InlineNodeImpl>.success(result.single, offset);
      }
      return new ParseResult<InlineNodeImpl>.success(
          new CombiningInlineNodeImpl(result), offset);
    }

    return new ParseResult<InlineNodeImpl>.failure();
  }
}
