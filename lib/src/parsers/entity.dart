library mdown.src.parsers.entity;

import 'package:mdown/entities.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for entities.
class EntityParser extends AbstractParser<InlineNodeImpl> {
  /// Constructor.
  EntityParser(ParsersContainer container) : super(container);

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    final Match match = entityRegExp.matchAsPrefix(text, offset);
    if (match != null) {
      if (match[3] != null) {
        final String code = match[3];
        if (code == 'nbsp') {
          return ParseResult<InlineNodeImpl>.success(
              NonBreakableSpaceImpl(1), match.end);
        }
        final String str = htmlEntities[match[3]];
        if (str != null) {
          return ParseResult<InlineNodeImpl>.success(StrImpl(str), match.end);
        }
      } else {
        int code;
        if (match[1] != null) {
          code = int.tryParse(match[1], radix: 16) ?? 0;
        } else {
          code = int.tryParse(match[2], radix: 10) ?? 0;
        }

        if (code > 1114111 || code == 0) {
          code = 0xFFFD;
        }

        if (code == nonBreakableSpaceCodeUnit) {
          return ParseResult<InlineNodeImpl>.success(
              NonBreakableSpaceImpl(1), match.end);
        }
        return ParseResult<InlineNodeImpl>.success(
            StrImpl(String.fromCharCode(code)), match.end);
      }
    }

    return const ParseResult<InlineNodeImpl>.failure();
  }
}
