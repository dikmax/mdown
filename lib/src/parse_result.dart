library md_proc.src.parse_result;

/// Result of running parser.
class ParseResult<A> {
  /// Is run was successful?
  final bool isSuccess;

  /// Returning value, if [isSuccess] is true.
  final A value;

  /// Offset, if [isSuccess] is true.
  final int offset;

  /// Success result constructor.
  ParseResult.success(this.value, this.offset) : isSuccess = true;

  /// Faulure result constructor.
  const ParseResult.failure()
      : value = null,
        offset = null,
        isSuccess = false;
}
