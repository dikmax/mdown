library mdown.src.parsers.blankline;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for empty line.
class BlanklineParser extends AbstractParser<BlockNodeImpl> {
  /// Constructor.
  BlanklineParser(ParsersContainer container) : super(container);

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    int off = offset;
    final ParseResult<String> lineResult =
        container.lineParser.parse(text, off);
    assert(lineResult.isSuccess, 'lineParser should always succeed');

    final String line = lineResult.value;

    off = lineResult.offset;
    if (isOnlyWhitespace(line)) {
      return ParseResult<BlockNodeImpl>.success(null, lineResult.offset);
    }

    return const ParseResult<BlockNodeImpl>.failure();
  }
}
