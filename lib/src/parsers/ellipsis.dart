library md_proc.src.parsers.ellipsis;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/inlines.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/container.dart';

/// Parser for ellipsis.
class EllipsisParser extends AbstractParser<Inlines> {
  /// Constructor.
  EllipsisParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    if (offset + 2 < text.length &&
        text.codeUnitAt(offset) == dotCodeUnit &&
        text.codeUnitAt(offset + 1) == dotCodeUnit &&
        text.codeUnitAt(offset + 2) == dotCodeUnit) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new Ellipsis()), offset + 3);
    }

    return new ParseResult<Inlines>.failure();
  }
}
