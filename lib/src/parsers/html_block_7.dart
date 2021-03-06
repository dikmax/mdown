library mdown.src.parsers.html_block_7;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for html blocks using rule 7.
class HtmlBlock7Parser extends AbstractParser<BlockNodeImpl> {
  /// Constructor.
  HtmlBlock7Parser(ParsersContainer container) : super(container);

  static final RegExp _startRegExp =
      RegExp(r'^ {0,3}(?:' + htmlOpenTag + '|' + htmlCloseTag + r')\s*$');

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    int off = offset;

    final ParseResult<String> lineRes = container.lineParser.parse(text, off);
    assert(lineRes.isSuccess, 'lineParser should always succeed');

    if (_startRegExp.firstMatch(lineRes.value) != null) {
      final StringBuffer result = StringBuffer(lineRes.value + '\n');
      off = lineRes.offset;
      final int length = text.length;
      while (off < length) {
        final ParseResult<String> lineRes =
            container.lineParser.parse(text, off);
        assert(lineRes.isSuccess, 'lineParser should always succeed');

        off = lineRes.offset;
        result.writeln(lineRes.value);
        if (isOnlyWhitespace(lineRes.value)) {
          break;
        }
      }

      return ParseResult<BlockNodeImpl>.success(
          HtmlRawBlockImpl(result.toString()), off);
    }

    return const ParseResult<BlockNodeImpl>.failure();
  }
}
