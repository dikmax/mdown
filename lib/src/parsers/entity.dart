library md_proc.src.parsers.entity;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/entities.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/inlines.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/common.dart';
import 'package:md_proc/src/parsers/container.dart';

/// Parser for entities.
class EntityParser extends AbstractParser<Inlines> {
  /// Constructor.
  EntityParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    final Match match = entityRegExp.matchAsPrefix(text, offset);
    if (match != null) {
      if (match[3] != null) {
        final String code = match[3];
        if (code == 'nbsp') {
          return new ParseResult<Inlines>.success(
              new Inlines.single(new NonBreakableSpace()), match.end);
        }
        final String str = htmlEntities[match[3]];
        if (str != null) {
          return new ParseResult<Inlines>.success(
              new Inlines.single(new Str(str)), match.end);
        }
      } else {
        int code;
        if (match[1] != null) {
          code = int.parse(match[1], radix: 16, onError: (_) => 0);
        } else {
          code = int.parse(match[2], radix: 10, onError: (_) => 0);
        }

        if (code > 1114111 || code == 0) {
          code = 0xFFFD;
        }

        if (code == nonBreakableSpaceCodeUnit) {
          return new ParseResult<Inlines>.success(
              new Inlines.single(new NonBreakableSpace()), match.end);
        }
        return new ParseResult<Inlines>.success(
            new Inlines.single(new Str(new String.fromCharCode(code))),
            match.end);
      }
    }

    return new ParseResult<Inlines>.failure();
  }
}
