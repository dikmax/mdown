class ParserOptions {
  bool smartPunctuation;

  ParserOptions({this.smartPunctuation: false});

  static ParserOptions DEFAULT = new ParserOptions(smartPunctuation: true);
  static ParserOptions STRICT = new ParserOptions();
}
