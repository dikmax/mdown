library mdown.src.parsers.abstract;

import 'package:mdown/src/code_units_list.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/container.dart';


/// Base abstract parser class.
abstract class AbstractParser<A> {
  /// DI container + options.
  ParsersContainer container;

  /// Constructor.
  AbstractParser(this.container);

  /// Init method, called by [container] after construction and
  /// before running, when all fiels in [container] are defined.
  void init() {}

  /// Abstract parse method. Called with [text] to parse,
  /// and [offset] where parsing should be started.
  ParseResult<A> parse(String text, int offset);

  /// Abstract parse method. Called with [text] to parse,
  /// and [offset] where parsing should be started.
  ParseResult<A> parseList(CodeUnitsList text, int offset);
}

/// Base abstract parser class with list implemented.
abstract class AbstractStringParser<A> extends AbstractParser<A> {
  /// Constructor.
  AbstractStringParser(ParsersContainer container) : super(container);

  @override
  ParseResult<A> parseList(CodeUnitsList text, int offset) {
    return parse(new String.fromCharCodes(text), offset);
  }
}

/// Base abstract parser class with string implemented.
abstract class AbstractListParser<A> extends AbstractParser<A> {
  /// Constructor.
  AbstractListParser(ParsersContainer container) : super(container);

  @override
  ParseResult<A> parse(String text, int offset) {
    return parseList(new CodeUnitsList.string(text), offset);
  }
}
