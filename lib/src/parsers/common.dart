part of md_proc.src.parsers;

final RegExp _anyLineRegExp = new RegExp(r'.*$');
final RegExp _emptyLineRegExp = new RegExp(r'^[ \t]*$');

const String _escapable = "!\"#\$%&'()*+,-./:;<=>?@[\\]^_`{|}~";
final Set<int> _escapableCodes =
    new Set<int>.from(_escapable.split('').map((String s) => s.codeUnitAt(0)));

// TODO move to paragraph file
final RegExp _atxHeadingTest = new RegExp('^ {0,3}(#{1,6})(?:[ \t]|\$)');
final RegExp _blockquoteSimpleTest = new RegExp(r'^ {0,3}>');
final RegExp _fencedCodeStartTest =
    new RegExp('^( {0,3})(?:(`{3,})([^`]*)|(~{3,})([^~]*))\$');
final RegExp _thematicBreakTest = new RegExp(
    '^( {0,3})((?:\\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,})\$');

final Pattern _htmlBlock1Test =
    new RegExp(r'<(?:script|pre|style)(?:\s|>|$)', caseSensitive: false);
final Pattern _htmlBlock2Test = '<!--';
final Pattern _htmlBlock3Test = '<?';
final Pattern _htmlBlock4Test = '<!';
final Pattern _htmlBlock5Test = '<!\[CDATA\[';
final Pattern _htmlBlock6Test = new RegExp(
  r'</?([a-zA-Z1-6]+)(?:\s|/?>|$)',
);
final Set<String> _blockTags = new Set<String>.from(<String>[
  'address',
  'article',
  'aside',
  'base',
  'basefont',
  'blockquote',
  'body',
  'caption',
  'center',
  'col',
  'colgroup',
  'dd',
  'details',
  'dialog',
  'dir',
  'div',
  'dl',
  'dt',
  'fieldset',
  'figcaption',
  'figure',
  'footer',
  'form',
  'frame',
  'frameset',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'head',
  'header',
  'hr',
  'html',
  'iframe',
  'legend',
  'li',
  'link',
  'main',
  'menu',
  'menuitem',
  'meta',
  'nav',
  'noframes',
  'ol',
  'optgroup',
  'option',
  'p',
  'param',
  'section',
  'source',
  'title',
  'summary',
  'table',
  'tbody',
  'td',
  'tfoot',
  'th',
  'thead',
  'title',
  'tr',
  'track',
  'ul'
]);

const String _htmlTagName = '[A-Za-z][A-Za-z0-9-]*';
const String _htmlAttributeName = '[a-zA-Z_:][a-zA-Z0-9:._-]*';
const String _htmlUnquotedValue = "[^\"'=<>`\\x00-\\x20]+";
const String _htmlSingleQuotedValue = "'[^']*'";
const String _htmlDoubleQuotedValue = '"[^"]*"';
const String _htmlAttributeValue = "(?:" +
    _htmlUnquotedValue +
    "|" +
    _htmlSingleQuotedValue +
    "|" +
    _htmlDoubleQuotedValue +
    ")";
const String _htmlAttributeValueSpec =
    "(?:" + "\\s*=" + "\\s*" + _htmlAttributeValue + ")";
const String _htmlAttribute =
    "(?:" + "\\s+" + _htmlAttributeName + _htmlAttributeValueSpec + "?)";
const String _htmlOpenTag =
    "<" + _htmlTagName + _htmlAttribute + "*" + "\\s*/?>";
const String _htmlCloseTag = "</" + _htmlTagName + "\\s*>";

final RegExp _clashSpaceRegExp = new RegExp('[ \t\r\n]+');

String _removeIndent(String line, int amount, bool allowLess,
    [int startIndent = 0]) {
  int offset = 0;
  while (offset < amount && offset < line.length) {
    final int code = line.codeUnitAt(offset);
    if (code == _tabCodeUnit) {
      line = line.replaceFirst(
          '\t', ' ' * (4 - (startIndent & 3))); // (4 - startIndent % 4)
    } else if (code == _spaceCodeUnit) {
      ++offset;
      ++startIndent;
    } else {
      break;
    }
  }
  if (offset >= amount || allowLess) {
    return line.substring(offset);
  }
  return null;
}

String _trimAndReplaceSpaces(String s) {
  return s.trim().replaceAll(_clashSpaceRegExp, ' ');
}

final RegExp _escapeRegExp =
    new RegExp(r'\\([!"#$%&' + "'" + r'()*+,\-./:;<=>?@\[\\\]^_`{|}~])');

final RegExp _entityRegExp = new RegExp(
    '&(?:#[xX]([A-Fa-f0-9]{1,8})|#([0-9]{1,8})|([A-Za-z][A-Za-z0-9]{1,31}));');

final RegExp _unescapeUnreferenceRegExp =
    new RegExp(_escapeRegExp.pattern + '|' + _entityRegExp.pattern);

final RegExp _unescapeUnrefereceTest = new RegExp(r'[\\&]');

/// Unescapes (`\!` -> `!`) and unreferences (`&amp;` -> `&`) string.
String unescapeAndUnreference(String s) {
  if (_unescapeUnrefereceTest.hasMatch(s)) {
    return s.replaceAllMapped(_unescapeUnreferenceRegExp,
        _unescapeUnreferenceReplacement);
  } else {
    return s;
  }
}

String _unescapeUnreferenceReplacement(Match match) {
  if (match[1] != null) {
    // Escape
    return match[1];
  }
  if (match[4] != null) {
    // Named entity
    final String str = htmlEntities[match[4]];
    if (str != null) {
      return str;
    }
  } else {
    int code;
    if (match[2] != null) {
      // Hex entity
      code = int.parse(match[2], radix: 16, onError: (_) => 0);
    } else {
      // Decimal entity
      code = int.parse(match[3], radix: 10, onError: (_) => 0);
    }

    if (code > 1114111 || code == 0) {
      code = 0xFFFD;
    }
    return new String.fromCharCode(code);
  }

  return match[0];
}

int _skipIndent(String text, int offset) {
  // First char
  int codeUnit = text.codeUnitAt(offset);
  if (codeUnit != _spaceCodeUnit) {
    return offset;
  }

  final int length = text.length;
  offset++;
  if (offset == length) {
    return -1;
  }

  // Second char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit != _spaceCodeUnit) {
    return offset;
  }

  offset++;
  if (offset == length) {
    return -1;
  }

  // Third char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit != _spaceCodeUnit) {
    return offset;
  }

  offset++;
  if (offset == length) {
    return -1;
  }

  // Fourth char
  return offset;
}

int _getBlockFirstChar(String text, int offset) {
  final int nonIndentOffset = _skipIndent(text, offset);

  return nonIndentOffset != -1 ? text.codeUnitAt(nonIndentOffset) : -1;
}

/// Inlines list
class Inlines extends ListBase<Inline> {
  List<Inline> _inlines = new List<Inline>();
  bool _cachedContainsLink;

  /// Constructor
  Inlines();

  /// Constructor from
  Inlines.from(Iterable<Inline> inlines)
      : _inlines = new List<Inline>.from(inlines);

  Inlines.single(Inline inline) : _inlines = <Inline>[] {
    _inlines.add(inline);
  }

  @override
  int get length => _inlines.length;

  @override
  set length(int length) {
    _inlines.length = length;
  }

  @override
  void operator []=(int index, Inline value) {
    _inlines[index] = value;
  }

  @override
  Inline operator [](int index) => _inlines[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  @override
  void add(Inline value) => _inlines.add(value);

  @override
  void addAll(Iterable<Inline> all) => _inlines.addAll(all);

  // Used in parsing.
  bool get _containsLink {
    _cachedContainsLink = _cachedContainsLink ??
        any(_isContainsLink);

    return _cachedContainsLink;
  }

  static bool _isContainsLink(Inline inline) {
    if (inline is Emph) {
      assert(inline.contents is Inlines);
      final Inlines contents = inline.contents;
      return contents._containsLink;
    } else if (inline is Strong) {
      assert(inline.contents is Inlines);
      final Inlines contents = inline.contents;
      return contents._containsLink;
    } else if (inline is Strikeout) {
      assert(inline.contents is Inlines);
      final Inlines contents = inline.contents;
      return contents._containsLink;
    } else if (inline is Subscript) {
      assert(inline.contents is Inlines);
      final Inlines contents = inline.contents;
      return contents._containsLink;
    } else if (inline is Superscript) {
      assert(inline.contents is Inlines);
      final Inlines contents = inline.contents;
      return contents._containsLink;
    } else if (inline is Image) {
      assert(inline.label is Inlines);
      final Inlines label = inline.label;
      return label._containsLink;
    } else if (inline is Link) {
      return true;
    }

    return false;
  }
}
