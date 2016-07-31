library md_proc.commonmark_parser;

import 'dart:collection';
import 'package:md_proc/options.dart';
import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/parsers.dart';
import 'package:md_proc/src/parse_result.dart';

class CommonMarkParser {
  Options _options;

  // Map<String, Target> _references;

  Set<String> _inlineDelimiters;
  Set<String> _strSpecialChars;
  Set<String> _intrawordDelimiters;

  ParsersContainer container;

  /// Constructor
  CommonMarkParser(this._options) {
    container = new ParsersContainer(_options);

    _inlineDelimiters = new Set<String>.from(["_", "*"]);
    _strSpecialChars = new Set<String>.from(
        [" ", "*", "_", "`", "!", "[", "]", "&", "<", "\\"]);
    _intrawordDelimiters = new Set<String>.from(["*"]);
    if (_options.smartPunctuation) {
      _inlineDelimiters.addAll(["'", "\""]);
      _strSpecialChars.addAll(["'", "\"", ".", "-"]);
    }
    if (_options.strikeout || _options.subscript) {
      _inlineDelimiters.add("~");
      _strSpecialChars.add("~");
      _intrawordDelimiters.add("~");
    }
    if (_options.superscript) {
      _inlineDelimiters.add('^');
      _strSpecialChars.add('^');
      _intrawordDelimiters.add('^');
    }
  }

  Document parse(String markdown) {
    container.references = new HashMap<String, Target>();
    final ParseResult<Document> result =
        container.documentParser.parse(markdown, 0);

    assert(result.isSuccess);
    return result.value;
  }

  Iterable<Inline> parseInlines(String inlinesString,
      [Map<String, Target> references]) {
    container.references =
        references == null ? new HashMap<String, Target>() : references;

    Iterable<Inline> inlines = container.documentParser.parseInlines(inlinesString);

    return inlines;
  }

  /// Predefined html writer with CommonMark default settings
  static CommonMarkParser commonmark = new CommonMarkParser(Options.commonmark);

  /// Predefined html writer with strict settings
  static CommonMarkParser strict = new CommonMarkParser(Options.strict);

  /// Predefined html writer with default settings
  static CommonMarkParser defaults = new CommonMarkParser(Options.defaults);
}
