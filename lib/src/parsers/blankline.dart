library mdown.src.parsers.blankline;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for empty line.
class BlanklineParser extends AbstractStringParser<BlockNodeImpl> {
  /// Constructor.
  BlanklineParser(ParsersContainer container) : super(container);

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    final ParseResult<String> lineResult =
        container.lineParser.parse(text, offset);
    assert(lineResult.isSuccess);

    final String line = lineResult.value;

    offset = lineResult.offset;
    if (isOnlyWhitespace(line)) {
      return new ParseResult<BlockNodeImpl>.success(null, lineResult.offset);
    }

    return const ParseResult<BlockNodeImpl>.failure();
  }
}
