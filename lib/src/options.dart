class Options {
  bool smartPunctuation;

  Options({this.smartPunctuation: false});

  static Options DEFAULT = new Options(smartPunctuation: true);
  static Options STRICT = new Options();
}
