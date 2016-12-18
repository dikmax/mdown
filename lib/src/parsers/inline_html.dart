library mdown.src.parsers.inline_html;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for inline html.
class InlineHtmlParser extends AbstractParser<InlineNodeImpl> {
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
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    if (text.codeUnitAt(offset) == lessThanCodeUnit) {
      for (RegExp test in _tests) {
        final Match match = test.matchAsPrefix(text, offset);
        if (match != null) {
          return new ParseResult<InlineNodeImpl>.success(
              new HtmlRawInlineImpl(text.substring(offset, match.end)),
              match.end);
        }
      }
    }

    return new ParseResult<InlineNodeImpl>.failure();
  }
}
