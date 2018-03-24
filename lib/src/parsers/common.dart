library mdown.src.parsers.common;

import 'dart:collection';

import 'package:mdown/entities.dart';
import 'package:mdown/src/bit_set.dart';
import 'package:mdown/src/code_units.dart';

/// List of all escapable characters
const String escapable = "!\"#\$%&'()*+,-./:;<=>?@[\\]^_`{|}~";

/// Cache of codes set.
Set<int> _escapableCodesSet;

/// Getter for set of escapable codes.
Set<int> get escapableCodes => _escapableCodesSet ??= new BitSet(256)
  ..addAll(escapable.split('').map((String s) => s.codeUnitAt(0)));

/// RegExp for testing 6th rule of html parsing. See CommonMark spec.
final Pattern htmlBlock6Test = new RegExp(
  r'</?([a-zA-Z1-6]+)(?:\s|/?>|$)',
);

/// List of block html tags.
final Set<String> blockTags = new HashSet<String>.from(<String>[
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

/// RegExp for parsing html tag name
const String htmlTagName = '[A-Za-z][A-Za-z0-9-]*';

/// RegExp for parsing html attribute name
const String htmlAttributeName = '[a-zA-Z_:][a-zA-Z0-9:._-]*';

/// RegExp for parsing html unquoted attribute value
const String htmlUnquotedValue = "[^\"'=<>`\\x00-\\x20]+";

/// RegExp for parsing html single-quoted attribute value
const String htmlSingleQuotedValue = "'[^']*'";

/// RegExp for parsing html double-quoted attribute value
const String htmlDoubleQuotedValue = '"[^"]*"';

/// RegExp for parsing html attribute value
const String htmlAttributeValue =
    '(?:$htmlUnquotedValue|$htmlSingleQuotedValue|$htmlDoubleQuotedValue)';

/// RegExp for parsing html attribute value by specification
/// (with `=`)
const String htmlAttributeValueSpec = '(?:\\s*=\\s*$htmlAttributeValue)';

/// RegExp for parsing html attribute
const String htmlAttribute =
    '(?:\\s+$htmlAttributeName$htmlAttributeValueSpec?)';

/// RegExp for parsing html open tag
const String htmlOpenTag = '<$htmlTagName$htmlAttribute*\\s*/?>';

/// RegExp for parsing html close tag
const String htmlCloseTag = '</$htmlTagName\\s*>';

final RegExp _clashSpaceRegExp = new RegExp('[ \t\r\n]+');

/// Removes indent from line
String removeIndent(String line, int amount,
    {bool allowLess, int startIndent = 0}) {
  String result = line;
  int offset = 0;
  int indent = startIndent;
  while (offset < amount && offset < result.length) {
    final int code = result.codeUnitAt(offset);
    if (code == tabCodeUnit) {
      result = result.replaceFirst(
          '\t', ' ' * (4 - (indent & 3))); // (4 - startIndent % 4)
    } else if (code == spaceCodeUnit) {
      ++offset;
      ++indent;
    } else {
      break;
    }
  }
  if (offset >= amount || allowLess) {
    return result.substring(offset);
  }
  return null;
}

/// Trim string and replace multiple spaces with one.
String trimAndReplaceSpaces(String s) =>
    s.trim().replaceAll(_clashSpaceRegExp, ' ');

/// Normalize link or image reference name
String normalizeReference(String s) => trimAndReplaceSpaces(s).toUpperCase();

/// Escape RegExp
final RegExp escapeRegExp = new RegExp(r'\\([!"#$%&'
    "'"
    r'()*+,\-./:;<=>?@\[\\\]^_`{|}~])');

/// Entity RegExp
final RegExp entityRegExp = new RegExp(
    '&(?:#[xX]([A-Fa-f0-9]{1,8})|#([0-9]{1,8})|([A-Za-z][A-Za-z0-9]{1,31}));');

/// Regexp for finding escapes and references.
final RegExp unescapeUnreferenceRegExp =
    new RegExp(escapeRegExp.pattern + '|' + entityRegExp.pattern);

/// RegExp for unescaped reference
final RegExp unescapeUnrefereceTest = new RegExp(r'[\\&]');

/// Unescapes (`\!` -> `!`) and unreferences (`&amp;` -> `&`) string.
String unescapeAndUnreference(String s) {
  if (unescapeUnrefereceTest.hasMatch(s)) {
    return s.replaceAllMapped(
        unescapeUnreferenceRegExp, _unescapeUnreferenceReplacement);
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

/// Returns new offset without indent.
int skipIndent(String text, int offset) {
  int off = offset;

  // First char
  int codeUnit = text.codeUnitAt(off);
  if (codeUnit != spaceCodeUnit) {
    return off;
  }

  final int length = text.length;
  off++;
  if (off == length) {
    return -1;
  }

  // Second char
  codeUnit = text.codeUnitAt(off);
  if (codeUnit != spaceCodeUnit) {
    return off;
  }

  off++;
  if (off == length) {
    return -1;
  }

  // Third char
  codeUnit = text.codeUnitAt(off);
  if (codeUnit != spaceCodeUnit) {
    return off;
  }

  off++;
  if (off == length) {
    return -1;
  }

  // Fourth char
  return off;
}

/// Gets first non-indent char.
int getBlockFirstChar(String text, int offset) {
  final int nonIndentOffset = skipIndent(text, offset);

  return nonIndentOffset != -1 ? text.codeUnitAt(nonIndentOffset) : -1;
}

/// Trims string left (only tabs and spaces)
String trimLeft(String text) {
  int offset = 0;
  final int length = text.length;

  while (offset < length) {
    final int codeUnit = text.codeUnitAt(offset);
    if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
      return offset == 0 ? text : text.substring(offset);
    }

    offset++;
  }

  return '';
}

/// Checks if string consist of only whitespaces.
bool isOnlyWhitespace(String text) {
  int offset = 0;
  final int length = text.length;

  while (offset < length) {
    final int codeUnit = text.codeUnitAt(offset);
    if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
      return false;
    }

    offset++;
  }

  return true;
}
