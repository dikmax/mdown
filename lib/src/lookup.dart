library md_proc.src.lookup;

abstract class Lookup {
  Lookup();

  factory Lookup.regExp(Pattern pattern) => new PatternLookup(pattern);

  bool isFound(String text, int offset);
}

class PatternLookup extends Lookup {
  final Pattern _pattern;

  PatternLookup(this._pattern);

  @override
  bool isFound(String text, int offset) =>
      _pattern.matchAsPrefix(text, offset) != null;
}

final Lookup atxHeadingLookup =
    new Lookup.regExp(new RegExp('(#{1,6})(?:[ \t]|\$)'));
final Lookup blockquoteSimpleLookup = new Lookup.regExp('>');
final Lookup fencedCodeStartLookup =
    new Lookup.regExp(new RegExp('(?:(`{3,})([^`]*)|(~{3,})([^~]*))\$'));
final Lookup thematicBreakLookup = new Lookup.regExp(
    new RegExp('((?:\\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,})\$'));

final Lookup htmlBlock1Lookup = new Lookup.regExp(
    new RegExp(r'<(?:script|pre|style)(?:\s|>|$)', caseSensitive: false));
final Lookup htmlBlock2Lookup = new Lookup.regExp('<!--');
final Lookup htmlBlock3Lookup = new Lookup.regExp('<?');
final Lookup htmlBlock4Lookup = new Lookup.regExp('<!');
final Lookup htmlBlock5Lookup = new Lookup.regExp('<!\[CDATA\[');
final Lookup htmlBlock6Lookup = new Lookup.regExp(new RegExp(
  r'</?([a-zA-Z1-6]+)(?:\s|/?>|$)',
));
