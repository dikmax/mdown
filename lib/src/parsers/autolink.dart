library mdown.src.parsers.autolink;

import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Autolinks (`<http://example.com/>`) parser
class AutolinkParser extends AbstractParser<InlineNodeImpl> {
  /// Constructor.
  AutolinkParser(ParsersContainer container) : super(container);

  static final RegExp _autolinkRegExp =
      new RegExp(r'<([a-zA-Z][a-zA-Z0-9+.\-]{1,31}:[^ \t\x00-\x20<>]*)>');

  static final RegExp _emailRegExp =
      new RegExp('<([a-zA-Z0-9.!#\$%&\'*+/=?^_`{|}~\\-]+@'
          '[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
          '(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*)>');

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    final Match autolinkMatch = _autolinkRegExp.matchAsPrefix(text, offset);

    if (autolinkMatch != null) {
      final String autolink = autolinkMatch[1];

      return new ParseResult<InlineNodeImpl>.success(
          new AutolinkImpl(autolink), autolinkMatch.end);
    }

    final Match emailMatch = _emailRegExp.matchAsPrefix(text, offset);

    if (emailMatch != null) {
      final String email = emailMatch[1];

      return new ParseResult<InlineNodeImpl>.success(
          new AutolinkEmailImpl(email), emailMatch.end);
    }

    return const ParseResult<InlineNodeImpl>.failure();
  }
}
