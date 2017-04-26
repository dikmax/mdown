library mdown.src.parsers.common;

import 'dart:collection';

import 'package:mdown/entities.dart';
import 'package:mdown/src/bit_set.dart';
import 'package:mdown/src/code_units.dart';

const String escapable = "!\"#\$%&'()*+,-./:;<=>?@[\\]^_`{|}~";
Set<int> _escapableCodesSet;

Set<int> get escapableCodes {
  if (_escapableCodesSet == null) {
    _escapableCodesSet = new BitSet(256);
    _escapableCodesSet
        .addAll(escapable.split('').map((String s) => s.codeUnitAt(0)));
  }

  return _escapableCodesSet;
}

final Pattern htmlBlock6Test = new RegExp(
  r'</?([a-zA-Z1-6]+)(?:\s|/?>|$)',
);
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

const String htmlTagName = '[A-Za-z][A-Za-z0-9-]*';
const String htmlAttributeName = '[a-zA-Z_:][a-zA-Z0-9:._-]*';
const String htmlUnquotedValue = "[^\"'=<>`\\x00-\\x20]+";
const String htmlSingleQuotedValue = "'[^']*'";
const String htmlDoubleQuotedValue = '"[^"]*"';
const String htmlAttributeValue = "(?:" +
    htmlUnquotedValue +
    "|" +
    htmlSingleQuotedValue +
    "|" +
    htmlDoubleQuotedValue +
    ")";
const String htmlAttributeValueSpec =
    "(?:" + "\\s*=" + "\\s*" + htmlAttributeValue + ")";
const String htmlAttribute =
    "(?:" + "\\s+" + htmlAttributeName + htmlAttributeValueSpec + "?)";
const String htmlOpenTag = "<" + htmlTagName + htmlAttribute + "*" + "\\s*/?>";
const String htmlCloseTag = "</" + htmlTagName + "\\s*>";

final RegExp _clashSpaceRegExp = new RegExp('[ \t\r\n]+');

String removeIndent(String line, int amount, bool allowLess,
    [int startIndent = 0]) {
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

String trimAndReplaceSpaces(String s) =>
    s.trim().replaceAll(_clashSpaceRegExp, ' ');

String normalizeReference(String s) => trimAndReplaceSpaces(s).toUpperCase();

final RegExp escapeRegExp =
    new RegExp(r'\\([!"#$%&' + "'" + r'()*+,\-./:;<=>?@\[\\\]^_`{|}~])');

final RegExp entityRegExp = new RegExp(
    '&(?:#[xX]([A-Fa-f0-9]{1,8})|#([0-9]{1,8})|([A-Za-z][A-Za-z0-9]{1,31}));');

final RegExp unescapeUnreferenceRegExp =
    new RegExp(escapeRegExp.pattern + '|' + entityRegExp.pattern);

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

int getBlockFirstChar(String text, int offset) {
  final int nonIndentOffset = skipIndent(text, offset);

  return nonIndentOffset != -1 ? text.codeUnitAt(nonIndentOffset) : -1;
}

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
