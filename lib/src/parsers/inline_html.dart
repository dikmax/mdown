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
    RegExp('(?:' + htmlOpenTag + '|' + htmlCloseTag + ')'), // Tag
    RegExp('<!---->|<!--(?:-?[^>-])(?:-?[^-])*-->'), // Comment
    RegExp('[<][?].*?[?][>]'), // Processing instruction
    RegExp('<![A-Z]+\\s+[^>]*>'), // Declaration
    RegExp('<!\\[CDATA\\[[\\s\\S]*?\\]\\]>') // CDATA
  ];

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    if (text.codeUnitAt(offset) == lessThanCodeUnit) {
      for (final RegExp test in _tests) {
        final Match match = test.matchAsPrefix(text, offset);
        if (match != null) {
          return ParseResult<InlineNodeImpl>.success(
              HtmlRawInlineImpl(text.substring(offset, match.end)), match.end);
        }
      }
    }

    return const ParseResult<InlineNodeImpl>.failure();
  }
}
