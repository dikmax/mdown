library md_proc.src.parsers.html_block;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/lookup.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/common.dart';
import 'package:md_proc/src/parsers/container.dart';

/// Parser for html blocks using rules 1-6.
class HtmlBlockParser extends AbstractParser<Iterable<Block>> {
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
    new RegExp(r'</(script|pre|style)>', caseSensitive: false),
    '-->',
    '?>',
    '>',
    ']]>'
  ];

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    final int nonIndentOffset = skipIndent(text, offset);

    int rule;
    for (int i = 0; i < _starts.length; ++i) {
      if (_starts[i].isFound(text, nonIndentOffset)) {
        rule = i;
        break;
      }
    }

    if (rule != null) {
      final int length = text.length;
      final StringBuffer result = new StringBuffer();
      while (offset < length) {
        final ParseResult<String> lineRes =
            container.lineParser.parse(text, offset);
        assert(lineRes.isSuccess);

        offset = lineRes.offset;
        result.writeln(lineRes.value);
        if (lineRes.value.contains(_ends[rule])) {
          break;
        }
      }

      return new ParseResult<Iterable<Block>>.success(
          <Block>[new HtmlRawBlock(result.toString())], offset);
    }

    final Match htmlBlock6Match =
        htmlBlock6Test.matchAsPrefix(text, nonIndentOffset);
    if (htmlBlock6Match != null) {
      final String tag = htmlBlock6Match[1];
      if (!blockTags.contains(tag.toLowerCase())) {
        return new ParseResult<Iterable<Block>>.failure();
      }

      final int length = text.length;
      final StringBuffer result = new StringBuffer();
      while (offset < length) {
        final ParseResult<String> lineRes =
            container.lineParser.parse(text, offset);
        assert(lineRes.isSuccess);

        offset = lineRes.offset;
        result.writeln(lineRes.value);
        if (emptyLineRegExp.hasMatch(lineRes.value)) {
          break;
        }
      }

      return new ParseResult<Iterable<Block>>.success(
          <Block>[new HtmlRawBlock(result.toString())], offset);
    }

    return new ParseResult<Iterable<Block>>.failure();
  }
}
