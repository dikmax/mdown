library md_proc.src.parsers.inline_html;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/inlines.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/common.dart';
import 'package:md_proc/src/parsers/container.dart';

/// Parser for inline html.
class InlineHtmlParser extends AbstractParser<Inlines> {
  /// Constructor.
  InlineHtmlParser(ParsersContainer container) : super(container);

  static final List<RegExp> _tests = <RegExp>[
    new RegExp('(?:' + htmlOpenTag + '|' + htmlCloseTag + ')'), // Tag
    new RegExp('<!---->|<!--(?:-?[^>-])(?:-?[^-])*-->'), // Comment
    new RegExp('[<][?].*?[?][>]'), // Processing instruction
    new RegExp('<![A-Z]+\\s+[^>]*>'), // Declaration
    new RegExp('<!\\[CDATA\\[[\\s\\S]*?\\]\\]>') // CDATA
  ];

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    if (text.codeUnitAt(offset) == lessThanCodeUnit) {
      for (RegExp test in _tests) {
        final Match match = test.matchAsPrefix(text, offset);
        if (match != null) {
          return new ParseResult<Inlines>.success(
              new Inlines.single(
                  new HtmlRawInline(text.substring(offset, match.end))),
              match.end);
        }
      }
    }

    return new ParseResult<Inlines>.failure();
  }
}
