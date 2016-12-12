library md_proc.src.parsers.line;

import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/container.dart';

final RegExp _lineRegExp = new RegExp('(.*)(?:\r\n|\n|\r)');

/// Parser for any line.
class LineParser extends AbstractParser<String> {
  /// Constructor.
  LineParser(ParsersContainer container) : super(container);

  @override
  ParseResult<String> parse(String text, int offset) {
    final int length = text.length;
    if (offset >= length) {
      return const ParseResult<String>.failure();
    }

    final Match match = _lineRegExp.matchAsPrefix(text, offset);
    String line;
    int newOffset;
    if (match == null) {
      newOffset = length;
      line = text.substring(offset, length);
    } else {
      newOffset = match.end;
      line = match[1];
    }

    return new ParseResult<String>.success(line, newOffset);
  }
}
