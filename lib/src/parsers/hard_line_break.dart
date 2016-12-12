library md_proc.src.parsers.hard_line_break;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/inlines.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/container.dart';

/// Parser for hard line breaks.
class HardLineBreakParser extends AbstractParser<Inlines> {
  /// Constructor.
  HardLineBreakParser(ParsersContainer container) : super(container);

  static final RegExp _hardLineBreakTest =
      new RegExp(r'(?: {2,}|\t+)(?:\r\n|\n|\r)');

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    final Match match = _hardLineBreakTest.matchAsPrefix(text, offset);

    if (match != null) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new LineBreak()), match.end);
    }

    return new ParseResult<Inlines>.failure();
  }
}
