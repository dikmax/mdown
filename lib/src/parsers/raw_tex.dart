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
      new RegExp(r'^ {0,3}\\begin\{([A-Za-z0-9_\-+*]+)\}');

  static String _escapeReplacement(Match match) => r'\' + match[0];

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    final ParseResult<String> lineRes =
        container.lineParser.parse(text, offset);
    assert(lineRes.isSuccess);

    final Match startMatch = _startRegExp.firstMatch(lineRes.value);
    if (startMatch == null) {
      return new ParseResult<BlockNodeImpl>.failure();
    }

    String enviroment = startMatch[1];
    enviroment =
        enviroment.replaceAllMapped(new RegExp(r'[+*]'), _escapeReplacement);
    final RegExp endTest =
        new RegExp(r'^ {0,3}\\end\{' + enviroment + r'\}[ \t]*$');

    final StringBuffer result = new StringBuffer();
    result.writeln(lineRes.value);

    offset = lineRes.offset;
    final int length = text.length;
    bool found = false;
    while (offset < length) {
      final ParseResult<String> lineRes =
          container.lineParser.parse(text, offset);
      assert(lineRes.isSuccess);

      offset = lineRes.offset;
      result.writeln(lineRes.value);

      if (endTest.hasMatch(lineRes.value)) {
        found = true;
        break;
      }
    }

    if (!found) {
      return new ParseResult<BlockNodeImpl>.failure();
    }

    return new ParseResult<BlockNodeImpl>.success(
        new TexRawBlockImpl(result.toString()), offset);
  }
}
