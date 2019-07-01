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
    int off = offset;
    final int length = text.length;
    int count = 0;
    while (off < length && text.codeUnitAt(off) == minusCodeUnit) {
      count++;
      off++;
    }
    if (count > 1) {
      List<InlineNodeImpl> result;
      if (count % 3 == 0) {
        result = List<InlineNodeImpl>.filled(
            count ~/ 3, SmartCharImpl(SmartCharType.mdash));
      } else if (count % 2 == 0) {
        result = List<InlineNodeImpl>.filled(
            count ~/ 2, SmartCharImpl(SmartCharType.ndash));
      } else if (count % 3 == 2) {
        result = List<InlineNodeImpl>.filled(
            count ~/ 3, SmartCharImpl(SmartCharType.mdash),
            growable: true)
          ..add(SmartCharImpl(SmartCharType.ndash));
      } else {
        // count % 3 == 1
        result = List<InlineNodeImpl>.filled(
            (count - 4) ~/ 3, SmartCharImpl(SmartCharType.mdash),
            growable: true)
          ..add(SmartCharImpl(SmartCharType.ndash))
          ..add(SmartCharImpl(SmartCharType.ndash));
      }
      if (result.length == 1) {
        return ParseResult<InlineNodeImpl>.success(result.single, off);
      }
      return ParseResult<InlineNodeImpl>.success(
          CombiningInlineNodeImpl(result), off);
    }

    return const ParseResult<InlineNodeImpl>.failure();
  }
}
