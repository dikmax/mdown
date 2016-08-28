part of md_proc.src.parsers;

final RegExp ANY_LINE = new RegExp(r'.*$');
final RegExp EMPTY_LINE = new RegExp(r'^[ \t]*$');
final RegExp WHITESPACE_CHAR = new RegExp('[ \t]');

const String ESCAPABLE = "!\"#\$%&'()*+,-./:;<=>?@[\\]^_`{|}~";
final Set<int> ESCAPABLE_CODES =
    new Set<int>.from(ESCAPABLE.split('').map((String s) => s.codeUnitAt(0)));

// TODO move to paragraph file
final RegExp _ATX_HEADING_TEST = new RegExp('^ {0,3}(#{1,6})(?:[ \t]|\$)');
final RegExp _BLOCKQUOTE_SIMPLE_TEST = new RegExp(r'^ {0,3}>');
final RegExp _LIST_SIMPLE_TEST = new RegExp(r'^ {0,3}([+\-*]|1[.)])( |$)');
final RegExp _FENCED_CODE_START_TEST =
    new RegExp('^( {0,3})(?:(`{3,})([^`]*)|(~{3,})([^~]*))\$');
final RegExp _THEMATIC_BREAK_TEST = new RegExp(
    '^( {0,3})((?:\\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,})\$');

final RegExp _HTML_BLOCK_1_TEST =
    new RegExp(r' {0,3}<(?:script|pre|style)(?:\s|>|$)', caseSensitive: false);
final RegExp _HTML_BLOCK_2_TEST = new RegExp(r' {0,3}<!--');
final RegExp _HTML_BLOCK_3_TEST = new RegExp(r' {0,3}<\?');
final RegExp _HTML_BLOCK_4_TEST = new RegExp(r' {0,3}<!');
final RegExp _HTML_BLOCK_5_TEST = new RegExp(r' {0,3}<!\[CDATA\[');
final RegExp _HTML_BLOCK_6_TEST = new RegExp(
    r' {0,3}</?(?:address|article|aside|base|basefont|blockquote|body|caption|center|col|colgroup|dd|details|dialog|dir|div|dl|dt|fieldset|figcaption|figure|footer|form|frame|frameset|h1|head|header|hr|html|iframe|legend|li|link|main|menu|menuitem|meta|nav|noframes|ol|optgroup|option|p|param|section|source|title|summary|table|tbody|td|tfoot|th|thead|title|tr|track|ul)(?:\s|/?>|$)',
    caseSensitive: false);

const String HTML_TAGNAME = '[A-Za-z][A-Za-z0-9-]*';
const String HTML_ATTRIBUTENAME = '[a-zA-Z_:][a-zA-Z0-9:._-]*';
const String HTML_UNQUOTEDVALUE = "[^\"'=<>`\\x00-\\x20]+";
const String HTML_SINGLEQUOTEDVALUE = "'[^']*'";
const String HTML_DOUBLEQUOTEDVALUE = '"[^"]*"';
const String HTML_ATTRIBUTEVALUE = "(?:" +
    HTML_UNQUOTEDVALUE +
    "|" +
    HTML_SINGLEQUOTEDVALUE +
    "|" +
    HTML_DOUBLEQUOTEDVALUE +
    ")";
const String HTML_ATTRIBUTEVALUESPEC =
    "(?:" + "\\s*=" + "\\s*" + HTML_ATTRIBUTEVALUE + ")";
const String HTML_ATTRIBUTE =
    "(?:" + "\\s+" + HTML_ATTRIBUTENAME + HTML_ATTRIBUTEVALUESPEC + "?)";
const String HTML_OPENTAG =
    "<" + HTML_TAGNAME + HTML_ATTRIBUTE + "*" + "\\s*/?>";
const String HTML_CLOSETAG = "</" + HTML_TAGNAME + "\\s*>";

final RegExp _CLASH_SPACE_REGEXP = new RegExp('[ \t\r\n]+');
final RegExp _trimLeftRegExp = new RegExp('^[ \t]*');

// Char codes
const int _TAB_CODE_UNIT = 9;
const int _NEWLINE_CODE_UNIT = 10;
const int _CARRIAGE_RETURN_CODE_UNIT = 13;
const int _SPACE_CODE_UNIT = 32;
const int _EXCLAMATION_MARK_CODE_UNIT = 33;
const int _DOUBLE_QUOTE_CODE_UNIT = 34;
const int _SHARP_CODE_UNIT = 35;
const int _AMPERSAND_CODE_UNIT = 38;
const int _SINGLE_QUOTE_CODE_UNIT = 39;
const int _OPEN_PAREN_CODE_UNIT = 40;
const int _CLOSE_PAREN_CODE_UNIT = 41;
const int _STAR_CODE_UNIT = 42;
const int _PLUS_CODE_UNIT = 43;
const int _MINUS_CODE_UNIT = 45;
const int _DOT_CODE_UNIT = 46;
const int _ZERO_CODE_UNIT = 48;
const int _NINE_CODE_UNIT = 57;
const int _LESS_THAN_CODE_UNIT = 60;
const int _EQUAL_CODE_UNIT = 61;
const int _GREATER_THAN_CODE_UNIT = 62;
const int _OPEN_BRACKET_CODE_UNIT = 91;
const int _SLASH_CODE_UNIT = 92;
const int _CLOSE_BRACKET_CODE_UNIT = 93;
const int _UNDERSCORE_CODE_UNIT = 95;
const int _BACKTICK_CODE_UNIT = 96;
const int _TILDE_CODE_UNIT = 126;
const int _NBSP_CODE_UNIT = 160;

String _removeIndent(String line, int amount, bool allowLess,
    [int startIndent = 0]) {
  int offset = 0;
  while (offset < amount && offset < line.length) {
    int code = line.codeUnitAt(offset);
    if (code == _TAB_CODE_UNIT) {
      line = line.replaceFirst(
          '\t', ' ' * (4 - (startIndent & 3))); // (4 - startIndent % 4)
    } else if (code == _SPACE_CODE_UNIT) {
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
  return s.trim().replaceAll(_CLASH_SPACE_REGEXP, ' ');
}

final RegExp _ESCAPE_REGEXP =
    new RegExp(r'\\([!"#$%&' + "'" + r'()*+,\-./:;<=>?@\[\\\]^_`{|}~])');

final RegExp _ENTITY_REGEXP = new RegExp(
    '&(?:#[xX]([A-Fa-f0-9]{1,8})|#([0-9]{1,8})|([A-Za-z][A-Za-z0-9]{1,31}));');

final RegExp _UNESCAPE_UNREFERENCE_REGEXP =
    new RegExp(_ESCAPE_REGEXP.pattern + '|' + _ENTITY_REGEXP.pattern);

final RegExp _TEST_UNESCAPE_AND_UNREFERENCE = new RegExp(r'[\\&]');

String unescapeAndUnreference(String s) {
  if (_TEST_UNESCAPE_AND_UNREFERENCE.hasMatch(s)) {
    return s.replaceAllMapped(_UNESCAPE_UNREFERENCE_REGEXP, (Match match) {
      if (match[1] != null) {
        // Escape
        return match[1];
      }
      if (match[4] != null) {
        // Named entity
        String str = htmlEntities[match[4]];
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
    });
  } else {
    return s;
  }
}

bool fastBlockTest(String text, int offset, int charCodeUnit) {
  // First char
  int codeUnit = text.codeUnitAt(offset);
  if (codeUnit == charCodeUnit) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  int length = text.length;
  offset++;
  if (offset == length) {
    return false;
  }

  // Second char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit == charCodeUnit) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  offset++;
  if (offset == length) {
    return false;
  }

  // Third char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit == charCodeUnit) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  offset++;
  if (offset == length) {
    return false;
  }

  // Fourth char
  codeUnit = text.codeUnitAt(offset);
  return codeUnit == charCodeUnit;
}

bool fastBlockTest2(
    String text, int offset, int charCodeUnit1, int charCodeUnit2) {
  // First char
  int codeUnit = text.codeUnitAt(offset);
  if (codeUnit == charCodeUnit1 || codeUnit == charCodeUnit2) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  int length = text.length;
  offset++;
  if (offset == length) {
    return false;
  }

  // Second char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit == charCodeUnit1 || codeUnit == charCodeUnit2) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  offset++;
  if (offset == length) {
    return false;
  }

  // Third char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit == charCodeUnit1 || codeUnit == charCodeUnit2) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  offset++;
  if (offset == length) {
    return false;
  }

  // Fourth char
  codeUnit = text.codeUnitAt(offset);
  return codeUnit == charCodeUnit1 || codeUnit == charCodeUnit2;
}

bool fastBlockTest3(String text, int offset, int charCodeUnit1,
    int charCodeUnit2, int charCodeUnit3) {
  // First char
  int codeUnit = text.codeUnitAt(offset);
  if (codeUnit == charCodeUnit1 ||
      codeUnit == charCodeUnit2 ||
      codeUnit == charCodeUnit3) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  int length = text.length;
  offset++;
  if (offset == length) {
    return false;
  }

  // Second char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit == charCodeUnit1 ||
      codeUnit == charCodeUnit2 ||
      codeUnit == charCodeUnit3) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  offset++;
  if (offset == length) {
    return false;
  }

  // Third char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit == charCodeUnit1 ||
      codeUnit == charCodeUnit2 ||
      codeUnit == charCodeUnit3) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  offset++;
  if (offset == length) {
    return false;
  }

  // Fourth char
  codeUnit = text.codeUnitAt(offset);
  return codeUnit == charCodeUnit1 ||
      codeUnit == charCodeUnit2 ||
      codeUnit == charCodeUnit3;
}

bool fastListTest(String text, int offset) {
  // First char
  int codeUnit = text.codeUnitAt(offset);

  if (codeUnit == _MINUS_CODE_UNIT ||
      codeUnit == _STAR_CODE_UNIT ||
      codeUnit == _PLUS_CODE_UNIT ||
      codeUnit == _GREATER_THAN_CODE_UNIT ||
      (codeUnit >= _ZERO_CODE_UNIT && codeUnit <= _NINE_CODE_UNIT)) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  int length = text.length;
  offset++;
  if (offset == length) {
    return false;
  }

  // Second char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit == _MINUS_CODE_UNIT ||
      codeUnit == _STAR_CODE_UNIT ||
      codeUnit == _PLUS_CODE_UNIT ||
      codeUnit == _GREATER_THAN_CODE_UNIT ||
      (codeUnit >= _ZERO_CODE_UNIT && codeUnit <= _NINE_CODE_UNIT)) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  offset++;
  if (offset == length) {
    return false;
  }

  // Third char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit == _MINUS_CODE_UNIT ||
      codeUnit == _STAR_CODE_UNIT ||
      codeUnit == _PLUS_CODE_UNIT ||
      codeUnit == _GREATER_THAN_CODE_UNIT ||
      (codeUnit >= _ZERO_CODE_UNIT && codeUnit <= _NINE_CODE_UNIT)) {
    return true;
  } else if (codeUnit != _SPACE_CODE_UNIT) {
    return false;
  }

  offset++;
  if (offset == length) {
    return false;
  }

  // Fourth char
  codeUnit = text.codeUnitAt(offset);
  return codeUnit == _MINUS_CODE_UNIT ||
      codeUnit == _STAR_CODE_UNIT ||
      codeUnit == _PLUS_CODE_UNIT ||
      codeUnit == _GREATER_THAN_CODE_UNIT ||
      (codeUnit >= _ZERO_CODE_UNIT && codeUnit <= _NINE_CODE_UNIT);
}

int _getBlockFirstChar(String text, int offset) {
  // First char
  int codeUnit = text.codeUnitAt(offset);
  if (codeUnit != _SPACE_CODE_UNIT) {
    return codeUnit;
  }

  int length = text.length;
  offset++;
  if (offset == length) {
    return -1;
  }

  // Second char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit != _SPACE_CODE_UNIT) {
    return codeUnit;
  }

  offset++;
  if (offset == length) {
    return -1;
  }

  // Third char
  codeUnit = text.codeUnitAt(offset);
  if (codeUnit != _SPACE_CODE_UNIT) {
    return codeUnit;
  }

  offset++;
  if (offset == length) {
    return -1;
  }

  // Fourth char
  return text.codeUnitAt(offset);
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
    if (_cachedContainsLink == null) {
      _cachedContainsLink = any((Inline inline) {
        if (inline is Emph) {
          assert(inline.contents is Inlines);
          Inlines contents = inline.contents;
          return contents._containsLink;
        } else if (inline is Strong) {
          assert(inline.contents is Inlines);
          Inlines contents = inline.contents;
          return contents._containsLink;
        } else if (inline is Strikeout) {
          assert(inline.contents is Inlines);
          Inlines contents = inline.contents;
          return contents._containsLink;
        } else if (inline is Subscript) {
          assert(inline.contents is Inlines);
          Inlines contents = inline.contents;
          return contents._containsLink;
        } else if (inline is Superscript) {
          assert(inline.contents is Inlines);
          Inlines contents = inline.contents;
          return contents._containsLink;
        } else if (inline is Image) {
          assert(inline.label is Inlines);
          Inlines label = inline.label;
          return label._containsLink;
        } else if (inline is Link) {
          return true;
        }

        return false;
      });
    }

    return _cachedContainsLink;
  }
}
