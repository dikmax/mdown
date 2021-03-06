library mdown.src.parsers.html_block;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/lookup.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for html blocks using rules 1-6.
class HtmlBlockParser extends AbstractParser<BlockNodeImpl> {
  /// Constructor.
  HtmlBlockParser(ParsersContainer container) : super(container);

  static final List<Lookup> _starts = <Lookup>[
    htmlBlock1Lookup,
    htmlBlock2Lookup,
    htmlBlock3Lookup,
    htmlBlock4Lookup,
    htmlBlock5Lookup
  ];

  static final List<Pattern> _ends = <Pattern>[
    // TODO(dikmax): replace regexp
    RegExp(r'</(script|pre|style)>', caseSensitive: false),
    '-->',
    '?>',
    '>',
    ']]>'
  ];

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    int off = offset;
    final int nonIndentOffset = skipIndent(text, off);

    int rule;
    for (int i = 0; i < _starts.length; ++i) {
      if (_starts[i].isFound(text, nonIndentOffset)) {
        rule = i;
        break;
      }
    }

    if (rule != null) {
      final int length = text.length;
      final StringBuffer result = StringBuffer();
      while (off < length) {
        final ParseResult<String> lineRes =
            container.lineParser.parse(text, off);
        assert(lineRes.isSuccess, 'lineParser should always succeed');

        off = lineRes.offset;
        result.writeln(lineRes.value);
        if (lineRes.value.contains(_ends[rule])) {
          break;
        }
      }

      return ParseResult<BlockNodeImpl>.success(
          HtmlRawBlockImpl(result.toString()), off);
    }

    final Match htmlBlock6Match =
        htmlBlock6Test.matchAsPrefix(text, nonIndentOffset);
    if (htmlBlock6Match != null) {
      final String tag = htmlBlock6Match[1];
      if (!blockTags.contains(tag.toLowerCase())) {
        return const ParseResult<BlockNodeImpl>.failure();
      }

      final int length = text.length;
      final StringBuffer result = StringBuffer();
      while (off < length) {
        final ParseResult<String> lineRes =
            container.lineParser.parse(text, off);
        assert(lineRes.isSuccess, 'lineParser should always succeed');

        if (isOnlyWhitespace(lineRes.value)) {
          break;
        }
        off = lineRes.offset;
        result.writeln(lineRes.value);
      }

      return ParseResult<BlockNodeImpl>.success(
          HtmlRawBlockImpl(result.toString()), off);
    }

    return const ParseResult<BlockNodeImpl>.failure();
  }
}
