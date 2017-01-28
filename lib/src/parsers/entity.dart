library mdown.src.parsers.entity;

import 'package:mdown/entities.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/code_units_list.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for entities.
class EntityParser extends AbstractStringParser<InlineNodeImpl> {
  /// Constructor.
  EntityParser(ParsersContainer container) : super(container);

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    final Match match = entityRegExp.matchAsPrefix(text, offset);
    if (match != null) {
      if (match[3] != null) {
        final String code = match[3];
        if (code == 'nbsp') {
          return new ParseResult<InlineNodeImpl>.success(
              new NonBreakableSpaceImpl(1), match.end);
        }
        final String str = htmlEntities[match[3]];
        if (str != null) {
          return new ParseResult<InlineNodeImpl>.success(
              new StrImpl(new CodeUnitsList.string(str)), match.end);
        }
      } else {
        int codeUnit;
        if (match[1] != null) {
          codeUnit = int.parse(match[1], radix: 16, onError: (_) => 0);
        } else {
          codeUnit = int.parse(match[2], radix: 10, onError: (_) => 0);
        }

        if (codeUnit > 1114111 || codeUnit == 0) {
          codeUnit = 0xFFFD;
        }

        if (codeUnit == nonBreakableSpaceCodeUnit) {
          return new ParseResult<InlineNodeImpl>.success(
              new NonBreakableSpaceImpl(1), match.end);
        }
        return new ParseResult<InlineNodeImpl>.success(
            new StrImpl(new CodeUnitsList.single(codeUnit)), match.end);
      }
    }

    return new ParseResult<InlineNodeImpl>.failure();
  }
}
