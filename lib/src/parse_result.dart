library md_proc.src.parse_result;

class ParseResult<A> {
  final bool isSuccess;

  final A value;
  final int offset;

  ParseResult.success(this.value, this.offset) : isSuccess = true;
  const ParseResult.failure()
      : value = null,
        offset = null,
        isSuccess = false;
}
