library md_proc.src.parsers.abstract;

import 'package:md_proc/src/parsers/container.dart';
import 'package:md_proc/src/parse_result.dart';

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
