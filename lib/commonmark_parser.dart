library md_proc.commonmark_parser;

import 'dart:collection';
import 'package:md_proc/options.dart';
import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/parsers.dart';
import 'package:md_proc/src/parse_result.dart';

/// Main parser class.
class CommonMarkParser {
  Options _options;

  /// DI container + options.
  ParsersContainer container;

  /// Constructor
  CommonMarkParser(this._options) {
    container = new ParsersContainer(_options);
  }

  /// Parses [markdown] and returns [Document].
  Document parse(String markdown) {
    container.references = new HashMap<String, Target>();
    final ParseResult<Document> result =
        container.documentParser.parse(markdown, 0);

    assert(result.isSuccess);
    return result.value;
  }

  /// Parses string as inlines.
  Iterable<Inline> parseInlines(String inlinesString,
      [Map<String, Target> references]) {
    container.references = references ?? new HashMap<String, Target>();

    final Iterable<Inline> inlines =
        container.documentParser.parseInlines(inlinesString);

    return inlines;
  }

  /// Predefined html writer with CommonMark default settings
  static CommonMarkParser commonmark = new CommonMarkParser(Options.commonmark);

  /// Predefined html writer with strict settings
  static CommonMarkParser strict = new CommonMarkParser(Options.strict);

  /// Predefined html writer with default settings
  static CommonMarkParser defaults = new CommonMarkParser(Options.defaults);
}
