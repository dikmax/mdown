library mdown.html_writer;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/visitor.dart';
import 'package:mdown/options.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/ast/enums.dart';

final RegExp _urlEncodeRegExp = RegExp(r'%[0-9a-fA-F]{2}');
final RegExp _htmlEntityRegExp = RegExp(
    r'&(?:#x[a-f0-9]{1,8}|#[0-9]{1,8}|[a-z][a-z0-9]{1,31});',
    caseSensitive: false);

String _urlEncode(String url) {
  final String result = url.splitMapJoin(_urlEncodeRegExp,
      onMatch: (Match m) => m.group(0), onNonMatch: Uri.encodeFull);
  return result.splitMapJoin(_htmlEntityRegExp,
      onMatch: (Match m) => m.group(0), onNonMatch: _htmlEscape);
}

RegExp _forbiddenTagsRegExp = RegExp(
    r'<(title|textarea|style|xmp|iframe|noembed|noframes|script|plaintext)',
    caseSensitive: false);

String _tagFilter(String contents) => contents.replaceAllMapped(
    _forbiddenTagsRegExp, (Match match) => '&lt;${match[1]}');

String _htmlEscape(String str) {
  final List<int> charCodes = <int>[];
  final int length = str.length;
  for (int i = 0; i < length; ++i) {
    final int codeUnit = str.codeUnitAt(i);
    switch (codeUnit) {
      case lessThanCodeUnit:
        charCodes
          ..add(ampersandCodeUnit)
          ..add(smallLCharCode)
          ..add(smallTCharCode)
          ..add(semicolonCodeUnit);
        break;

      case greaterThanCodeUnit:
        charCodes
          ..add(ampersandCodeUnit)
          ..add(smallGCharCode)
          ..add(smallTCharCode)
          ..add(semicolonCodeUnit);
        break;

      case doubleQuoteCodeUnit:
        charCodes
          ..add(ampersandCodeUnit)
          ..add(smallQCharCode)
          ..add(smallUCharCode)
          ..add(smallOCharCode)
          ..add(smallTCharCode)
          ..add(semicolonCodeUnit);
        break;

      case ampersandCodeUnit:
        charCodes
          ..add(ampersandCodeUnit)
          ..add(smallACharCode)
          ..add(smallMCharCode)
          ..add(smallPCharCode)
          ..add(semicolonCodeUnit);
        break;

      default:
        charCodes.add(codeUnit);
    }
  }
  return String.fromCharCodes(charCodes);
}

class _InfoStringVisitor extends SimpleAstVisitor<String> {
  @override
  String visitInfoString(InfoString node) {
    if (node.language == '') {
      return '';
    }
    return ' class="language-${_htmlEscape(node.language)}"';
  }
}

final _InfoStringVisitor _infoStringVisitor = _InfoStringVisitor();

class _IdAttributesVisitor extends SimpleAstVisitor<String> {
  @override
  String visitIdentifierAttribute(IdentifierAttribute node) =>
      ' id=\"${node.identifier}\"';

  @override
  String visitExtendedAttributes(ExtendedAttributes node) {
    String result = '';
    for (final Attribute attribute in node.attributes) {
      final String id = attribute.accept(this);
      if (id != null) {
        result += id;
      }
    }

    return result;
  }
}

final _IdAttributesVisitor _idAttributesVisitor = _IdAttributesVisitor();

class _ClassAttributesVisitor extends SimpleAstVisitor<String> {
  @override
  String visitClassAttribute(ClassAttribute node) => node.className;

  @override
  String visitExtendedAttributes(ExtendedAttributes node) {
    final List<String> result = <String>[];
    for (final Attribute attribute in node.attributes) {
      final String className = attribute.accept(this);
      if (className != null) {
        result.add(className);
      }
    }

    return result.isNotEmpty ? ' class="${result.join(' ')}"' : '';
  }
}

_ClassAttributesVisitor _classAttributesVisitor = _ClassAttributesVisitor();

class _KeyValueAttributesVisitor extends SimpleAstVisitor<String> {
  @override
  String visitKeyValueAttribute(KeyValueAttribute node) =>
      ' ${node.key}="${node.value}"';

  @override
  String visitExtendedAttributes(ExtendedAttributes node) {
    String result = '';
    for (final Attribute attribute in node.attributes) {
      final String id = attribute.accept(this);
      if (id != null) {
        result += id;
      }
    }

    return result;
  }
}

_KeyValueAttributesVisitor _keyValueAttributesVisitor =
    _KeyValueAttributesVisitor();

class _ImageLabelVisitor extends GeneralizingAstVisitor<void> {
  final StringBuffer _sb = StringBuffer();

  String get result => _sb.toString();

  @override
  void visitCode(Code node) {
    _sb.write(node.contents);
  }

  @override
  void visitCompositeInline(CompositeInline node) {
    node.contents.accept(this);
  }

  @override
  void visitHardLineBreak(HardLineBreak node) {
    _sb.write(' ');
  }

  @override
  void visitHtmlRawInline(HtmlRawInline node) {
    _sb.write(node.contents);
  }

  @override
  void visitImage(Image node) {
    node.contents?.accept(this);
  }

  @override
  void visitLink(Link node) {
    node.contents?.accept(this);
  }

  @override
  void visitNonBreakableSpace(NonBreakableSpace node) {
    _sb.write('\u{a0}');
  }

  @override
  void visitSmartChar(SmartChar node) {
    switch (node.type) {
      case SmartCharType.ellipsis:
        _sb.write('\u{2026}');
        break;

      case SmartCharType.mdash:
        _sb.write('\u{2014}');
        break;

      case SmartCharType.ndash:
        _sb.write('\u{2013}');
        break;

      case SmartCharType.singleOpenQuote:
        _sb.write('\u{2018}');
        break;

      case SmartCharType.singleCloseQuote:
      case SmartCharType.apostrophe:
        _sb.write('\u{2019}');
        break;

      case SmartCharType.doubleOpenQuote:
        _sb.write('\u{201c}');
        break;

      case SmartCharType.doubleCloseQuote:
        _sb.write('\u{201d}');
        break;
    }
  }

  @override
  void visitSpace(Space node) {
    _sb.write(' ' * node.amount);
  }

  @override
  void visitStr(Str node) {
    _sb.write(node.contents);
  }

  @override
  void visitTab(Tab node) {
    _sb.write('\t' * node.amount);
  }

  @override
  void visitTexMath(TexMath node) {
    _sb.write(node.contents);
  }
}

class _Visitor extends GeneralizingAstVisitor<void> {
  _Visitor(this._options);

  final StringBuffer _sb = StringBuffer();

  final Options _options;

  String get result => _sb.toString();

  void _writeBlocks(Iterable<BlockNode> nodes, {bool tight = false}) {
    final Iterator<BlockNode> iterator = nodes.iterator;

    if (iterator.moveNext()) {
      final BlockNode block = iterator.current;
      if (tight) {
        // TODO(dikmax): use separate Visitor.
        if (block is Para) {
          block.contents.accept(this);
        } else {
          _sb.writeln();
          block.accept(this);
        }
      } else {
        block.accept(this);
      }
      while (iterator.moveNext()) {
        if (tight) {
          _sb.writeln();
        }
        final BlockNode block = iterator.current;
        if (tight && block is Para) {
          block.contents.accept(this);
        } else {
          block.accept(this);
        }
      }
    }
  }

  @override
  void visitBlockquote(Blockquote node) {
    _sb.write('<blockquote>\n');
    _writeBlocks(node.contents);
    _sb.write('</blockquote>\n');
  }

  @override
  void visitCode(Code node) {
    _sb.write('<code');
    node.attributes?.accept(this);
    _sb..write('>')..write(_htmlEscape(node.contents))..write('</code>');
  }

  @override
  void visitCodeBlock(CodeBlock node) {
    _sb.write('<pre');
    node.attributes?.accept(this);
    _sb
      ..write('><code')
      ..write(node.attributes?.accept(_infoStringVisitor) ?? '')
      ..write('>');
    for (final String line in node.contents) {
      _sb.writeln(_htmlEscape(line));
    }
    _sb.write('</code></pre>\n');
  }

  @override
  void visitDocument(Document node) {
    _writeBlocks(node.contents);
  }

  @override
  void visitEmphasis(Emphasis node) {
    _sb.write('<em>');
    node.contents.accept(this);
    _sb.write('</em>');
  }

  @override
  void visitExtendedAttributes(ExtendedAttributes node) {
    _sb
      ..write(node.accept(_idAttributesVisitor))
      ..write(node.accept(_classAttributesVisitor))
      ..write(node.accept(_keyValueAttributesVisitor));
  }

  @override
  void visitHardLineBreak(HardLineBreak node) {
    _sb.write('<br/>\n');
  }

  @override
  void visitHeading(Heading node) {
    _sb..write('<h')..write(node.level);
    node.attributes?.accept(this);
    _sb.write('>');
    node.contents?.accept(this);
    _sb..write('</h')..write(node.level)..write('>\n');
  }

  @override
  void visitHtmlRawBlock(HtmlRawBlock node) {
    _sb.write(_options.tagFilter ? _tagFilter(node.contents) : node.contents);
  }

  @override
  void visitHtmlRawInline(HtmlRawInline node) {
    _sb.write(_options.tagFilter ? _tagFilter(node.contents) : node.contents);
  }

  @override
  void visitImage(Image node) {
    _sb..write('<img src="')..write(_urlEncode(node?.link))..write('" alt="');

    final _ImageLabelVisitor innerVisitor = _ImageLabelVisitor();
    node.contents.accept(innerVisitor);

    _sb..write(_htmlEscape(innerVisitor.result))..write('"');
    if (node.title != null) {
      _sb..write(' title="')..write(_htmlEscape(node.title))..write('"');
    }
    node.attributes?.accept(this);
    _sb.write(' />');
  }

  @override
  void visitLink(Link node) {
    _sb..write('<a href="')..write(_urlEncode(node.link))..write('"');
    if (node.title != null) {
      _sb..write(' title="')..write(_htmlEscape(node.title))..write('"');
    }
    node.attributes?.accept(this);
    _sb.write('>');
    node.contents?.accept(this);
    _sb.write('</a>');
  }

  @override
  void visitLinkReference(LinkReference node);

  @override
  void visitListItem(ListItem node) {
    if (node.parent is ListBlock) {
      final ListBlock listBlock = node.parent;
      if (listBlock.tight) {
        _sb.write('<li>');
        _writeBlocks(node.contents, tight: true);
        _sb.write('</li>\n');
      } else {
        if (node.contents.isEmpty) {
          _sb.write('<li></li>\n');
        } else {
          _sb.write('<li>\n');
          _writeBlocks(node.contents, tight: false);
          _sb.write('</li>\n');
        }
      }
    }
  }

  @override
  void visitNonBreakableSpace(NonBreakableSpace node) {
    _sb.write('\u{a0}');
  }

  @override
  void visitOrderedList(OrderedList node) {
    _sb.write('<ol');
    if (node.startIndex != 1) {
      _sb.write(' start="${node.startIndex}"');
    }
    _sb.write('>\n');
    node.visitChildren(this);
    _sb.write('</ol>\n');
  }

  @override
  void visitPara(Para node) {
    _sb.write('<p>');
    node.visitChildren(this);
    _sb.write('</p>\n');
  }

  @override
  void visitSmartChar(SmartChar node) {
    switch (node.type) {
      case SmartCharType.ellipsis:
        _sb.write('\u{2026}');
        break;

      case SmartCharType.mdash:
        _sb.write('\u{2014}');
        break;

      case SmartCharType.ndash:
        _sb.write('\u{2013}');
        break;

      case SmartCharType.singleOpenQuote:
        _sb.write('\u{2018}');
        break;

      case SmartCharType.singleCloseQuote:
      case SmartCharType.apostrophe:
        _sb.write('\u{2019}');
        break;

      case SmartCharType.doubleOpenQuote:
        _sb.write('\u{201c}');
        break;

      case SmartCharType.doubleCloseQuote:
        _sb.write('\u{201d}');
        break;
    }
  }

  @override
  void visitSpace(Space node) {
    _sb.write(' ' * node.amount);
  }

  @override
  void visitStr(Str node) {
    _sb.write(_htmlEscape(node.contents));
  }

  @override
  void visitStrikeout(Strikeout node) {
    _sb.write('<del>');
    node.contents.accept(this);
    _sb.write('</del>');
  }

  @override
  void visitSubscript(Subscript node) {
    _sb.write('<sub>');
    node.contents.accept(this);
    _sb.write('</sub>');
  }

  @override
  void visitSuperscript(Superscript node) {
    _sb.write('<sup>');
    node.contents.accept(this);
    _sb.write('</sup>');
  }

  @override
  void visitStrong(Strong node) {
    _sb.write('<strong>');
    node.contents.accept(this);
    _sb.write('</strong>');
  }

  @override
  void visitTab(Tab node) {
    _sb.write('\t' * node.amount);
  }

  @override
  void visitTable(Table node) {
    _sb.write('<table>');
    final int alignmentLength = node.alignment.length;
    if (node.headers != null) {
      _sb.write('<thead><tr>');
      final int length = node.headers.length;
      for (int i = 0; i < length; i += 1) {
        _sb.write('<th');
        if (i < alignmentLength) {
          _sb.write(alignmentToStyleString(node.alignment[i]));
        }
        _sb.write('>');
        node.headers[i].accept(this);
        _sb.write('</th>');
      }
      _sb.write('</tr></thead>');
    }
    _sb.write('<tbody>');
    for (final TableRow row in node.contents) {
      _sb.write('<tr>');
      final int length = row.contents.length;
      for (int i = 0; i < length; i += 1) {
        _sb.write('<td');
        if (i < alignmentLength) {
          _sb.write(alignmentToStyleString(node.alignment[i]));
        }
        _sb.write('>');
        row.contents[i].accept(this);
        _sb.write('</td>');
      }
      _sb.write('</tr>');
    }
    _sb.write('</tbody></table>\n');
  }

  @override
  void visitTableCell(TableCell node) {
    if (node.contents.length == 1 && node.contents.single is Para) {
      final Para para = node.contents.single;
      para.contents.accept(this);
    } else {
      node.contents.accept(this);
    }
  }

  @override
  void visitTexMathDisplay(TexMathDisplay node) {
    _sb
      ..write('<span class="')
      ..write(_options.displayTexMathClasses.join(' '))
      ..write(r'">\[')
      ..write(_htmlEscape(node.contents))
      ..write(r'\]</span>');
  }

  @override
  void visitTexMathInline(TexMathInline node) {
    _sb
      ..write('<span class="')
      ..write(_options.inlineTexMathClasses.join(' '))
      ..write(r'">\(')
      ..write(_htmlEscape(node.contents))
      ..write(r'\)</span>');
  }

  @override
  void visitTexRawBlock(TexRawBlock node) {
    _sb.write(_htmlEscape(node.contents));
  }

  @override
  void visitThematicBreak(ThematicBreak node) {
    _sb.write('<hr/>\n');
  }

  @override
  void visitUnorderedList(UnorderedList node) {
    _sb.write('<ul>\n');
    node.visitChildren(this);
    _sb.write('</ul>\n');
  }
}

/// Html writer
class HtmlWriter {
  /// Constructor
  const HtmlWriter(this._options);

  final Options _options;

  /// Renders document to string
  String write(Document document) {
    final _Visitor visitor = _Visitor(_options);
    document.accept(visitor);
    return visitor.result;
  }

  /// Predefined html writer with CommonMark default settings
  static const HtmlWriter commonmark = HtmlWriter(Options.commonmark);

  /// Predefined html writer with strict settings
  static const HtmlWriter strict = HtmlWriter(Options.strict);

  /// Predefined html writer with default settings
  static const HtmlWriter defaults = HtmlWriter(Options.defaults);
}
