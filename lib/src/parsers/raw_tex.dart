library mdown.src.parsers.raw_tex;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parses raw TeX blocks.
class RawTexParser extends AbstractParser<BlockNodeImpl> {
  /// Constructor.
  RawTexParser(ParsersContainer container) : super(container);

  static final RegExp _startRegExp =
      RegExp(r'^ {0,3}\\begin{([A-Za-z0-9_\-+*]+)\}');

  static String _escapeReplacement(Match match) => r'\' + match[0];

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    int off = offset;
    final ParseResult<String> lineRes = container.lineParser.parse(text, off);
    assert(lineRes.isSuccess, 'lineParser should always succeed');

    final Match startMatch = _startRegExp.firstMatch(lineRes.value);
    if (startMatch == null) {
      return const ParseResult<BlockNodeImpl>.failure();
    }

    String environment = startMatch[1];
    environment =
        environment.replaceAllMapped(RegExp(r'[+*]'), _escapeReplacement);
    final RegExp endTest =
        RegExp(r'^ {0,3}\\end\{' + environment + r'\}[ \t]*$');

    final StringBuffer result = StringBuffer()..writeln(lineRes.value);

    off = lineRes.offset;
    final int length = text.length;
    bool found = false;
    while (off < length) {
      final ParseResult<String> lineRes = container.lineParser.parse(text, off);
      assert(lineRes.isSuccess, 'lineParser should always succeed');

      off = lineRes.offset;
      result.writeln(lineRes.value);

      if (endTest.hasMatch(lineRes.value)) {
        found = true;
        break;
      }
    }

    if (!found) {
      return const ParseResult<BlockNodeImpl>.failure();
    }

    return ParseResult<BlockNodeImpl>.success(
        TexRawBlockImpl(result.toString()), off);
  }
}
