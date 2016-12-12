library md_proc.src.parsers.thematic_break;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/common.dart';
import 'package:md_proc/src/parsers/container.dart';

/// Parser for thematic break.
class ThematicBreakParser extends AbstractParser<Iterable<Block>> {
  /// Constructor.
  ThematicBreakParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    final ParseResult<String> lineResult =
        container.lineParser.parse(text, offset);
    assert(lineResult.isSuccess);

    final Match match = thematicBreakTest.firstMatch(lineResult.value);
    if (match == null) {
      return const ParseResult<Iterable<Block>>.failure();
    }

    return new ParseResult<Iterable<Block>>.success(
        <ThematicBreak>[new ThematicBreak()], lineResult.offset);
  }
}
