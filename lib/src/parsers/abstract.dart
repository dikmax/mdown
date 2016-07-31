part of md_proc.src.parsers;

abstract class AbstractParser<A> {
  ParsersContainer container;

  AbstractParser(this.container);

  void init() {}

  ParseResult<A> parse(String text, int offset);
}
