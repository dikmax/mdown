library mdown.src.parsers.abstract;

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
}
