library mdown.commonmark_parser;

import 'dart:collection';

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/standard_ast_factory.dart';
import 'package:mdown/options.dart';
import 'package:mdown/src/code_units_list.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/container.dart';

/// Main parser class.
class MarkdownParser {
  Options _options;

  /// DI container + options.
  ParsersContainer container;

  /// Constructor
  MarkdownParser(this._options) {
    container = new ParsersContainer(_options);
  }

  /// Parses [markdown] and returns [Document].
  Document parse(String markdown) {
    container.references = new HashMap<String, LinkReference>();
    final ParseResult<Document> result =
        container.documentParser.parse(markdown, 0);

    assert(result.isSuccess);
    return result.value;
  }

  /// Parses string as inlines.
  Iterable<InlineNode> parseInlines(String inlinesString,
      [Map<String, Target> references]) {
    final Map<String, LinkReference> refs = <String, LinkReference>{};
    if (references != null) {
      references.forEach((String key, Target target) {
        refs[key] = astFactory.linkReference(key, target, null);
      });
    }
    container.references = refs;

    return container.documentParser.parseInlines(
        new CodeUnitsList.string(inlinesString));
  }

  /// Predefined html writer with CommonMark default settings
  static MarkdownParser commonmark = new MarkdownParser(Options.commonmark);

  /// Predefined html writer with strict settings
  static MarkdownParser strict = new MarkdownParser(Options.strict);

  /// Predefined html writer with default settings
  static MarkdownParser defaults = new MarkdownParser(Options.defaults);
}
