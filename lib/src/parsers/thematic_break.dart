library mdown.src.parsers.thematic_break;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';
import 'package:mdown/src/lookup.dart';

/// Parser for thematic break.
class ThematicBreakParser extends AbstractParser<BlockNodeImpl> {
  /// Constructor.
  ThematicBreakParser(ParsersContainer container) : super(container);

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    final ParseResult<String> lineResult =
        container.lineParser.parse(text, offset);
    assert(lineResult.isSuccess, 'listParser should always succeed.');

    final int indent = skipIndent(text, offset);
    if (!thematicBreakLookup.isFound(text, indent)) {
      return const ParseResult<BlockNodeImpl>.failure();
    }

    return ParseResult<BlockNodeImpl>.success(
        ThematicBreakImpl(), lineResult.offset);
  }
}
