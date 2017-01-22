library mdown.html_writer;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/visitor.dart';
import 'package:mdown/options.dart';
import 'package:mdown/src/code_units.dart';

final RegExp _urlEncodeRegExp = new RegExp(r'%[0-9a-fA-F]{2}');
final RegExp _htmlEntityRegExp = new RegExp(
    r'&(?:#x[a-f0-9]{1,8}|#[0-9]{1,8}|[a-z][a-z0-9]{1,31});',
    caseSensitive: false);

String _urlEncode(String url) {
  String result = url.splitMapJoin(_urlEncodeRegExp,
      onMatch: (Match m) => m.group(0),
      onNonMatch: (String s) => Uri.encodeFull(s));
  result = result.splitMapJoin(_htmlEntityRegExp,
      onMatch: (Match m) => m.group(0),
      onNonMatch: (String s) => _htmlEscape(s));
  return result;
}

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
  return new String.fromCharCodes(charCodes);
}

class _InfoStringVisitor extends SimpleAstVisitor<String> {
  @override
  String visitInfoString(InfoString node) {
    if (node.language == "") {
      return "";
    }
    return ' class="language-${_htmlEscape(node.language)}"';
  }
}

final _InfoStringVisitor _infoStringVisitor = new _InfoStringVisitor();

class _IdAttributesVisitor extends SimpleAstVisitor<String> {
  @override
  String visitIdentifierAttribute(IdentifierAttribute node) {
    return ' id=\"${node.identifier}\"';
  }

  @override
  String visitExtendedAttributes(ExtendedAttributes node) {
    String result = '';
    for (Attribute attribute in node.attributes) {
      final String id = attribute.accept(this);
      if (id != null) {
        result += id;
      }
    }

    return result;
  }
}

final _IdAttributesVisitor _idAttributesVisitor = new _IdAttributesVisitor();

class _ClassAttributesVisitor extends SimpleAstVisitor<String> {
  @override
  String visitClassAttribute(ClassAttribute node) {
    return node.className;
  }

  @override
  String visitExtendedAttributes(ExtendedAttributes node) {
    final List<String> result = <String>[];
    for (Attribute attribute in node.attributes) {
      final String className = attribute.accept(this);
      if (className != null) {
        result.add(className);
      }
    }

    return result.isNotEmpty ? ' class="${result.join(' ')}"' : '';
  }
}

_ClassAttributesVisitor _classAttributesVisitor = new _ClassAttributesVisitor();

class _KeyValueAttributesVisitor extends SimpleAstVisitor<String> {
  @override
  String visitKeyValueAttribute(KeyValueAttribute node) {
    return ' ${node.key}="${node.value}"';
  }

  @override
  String visitExtendedAttributes(ExtendedAttributes node) {
    String result = '';
    for (Attribute attribute in node.attributes) {
      final String id = attribute.accept(this);
      if (id != null) {
        result += id;
      }
    }

    return result;
  }
}

_KeyValueAttributesVisitor _keyValueAttributesVisitor =
    new _KeyValueAttributesVisitor();

class _ImageLabelVisitor extends GeneralizingAstVisitor<Null> {
  final StringBuffer _sb = new StringBuffer();

  String get result => _sb.toString();

  @override
  Null visitCode(Code node) {
    _sb.write(node.contents);
    return null;
  }

  @override
  Null visitCompositeInline(CompositeInline node) {
    node.contents.accept(this);
    return null;
  }

  @override
  Null visitHardLineBreak(HardLineBreak node) {
    _sb.write(" ");
    return null;
  }

  @override
  Null visitHtmlRawInline(HtmlRawInline node) {
    _sb.write(node.contents);
    return null;
  }

  @override
  Null visitImage(Image node) {
    node.contents?.accept(this);
    return null;
  }

  @override
  Null visitLink(Link node) {
    node.contents?.accept(this);
    return null;
  }

  @override
  Null visitNonBreakableSpace(NonBreakableSpace node) {
    _sb.write('\u{a0}');
    return null;
  }

  @override
  Null visitSmartChar(SmartChar node) {
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

    return null;
  }

  @override
  Null visitSpace(Space node) {
    _sb.write(" " * node.amount);
    return null;
  }

  @override
  Null visitStr(Str node) {
    _sb.write(node.contents);
    return null;
  }

  @override
  Null visitTab(Tab node) {
    _sb.write("\t" * node.amount);
    return null;
  }

  @override
  Null visitTexMath(TexMath node) {
    _sb.write(node.contents);
    return null;
  }
}

class _Visitor extends GeneralizingAstVisitor<Null> {
  final StringBuffer _sb = new StringBuffer();

  final Options _options;

  _Visitor(this._options);

  String get result => _sb.toString();

  void _writeBlocks(Iterable<BlockNode> nodes, {bool tight: false}) {
    final Iterator<BlockNode> iterator = nodes.iterator;

    if (iterator.moveNext()) {
      final BlockNode block = iterator.current;
      if (tight) {
        // TODO use separate Visitor.
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
        _sb.writeln();
        final BlockNode block = iterator.current;
        if (tight && block is Para) {
          block.contents.accept(this);
        } else {
          block.accept(this);
        }
      }
    }

    if (tight && nodes.isNotEmpty && nodes.last is! Para) {
      _sb.writeln();
    }
  }

  @override
  Null visitBlockquote(Blockquote node) {
    _sb.write('<blockquote>\n');
    _writeBlocks(node.contents);
    _sb.write('\n</blockquote>');

    return null;
  }

  @override
  Null visitCode(Code node) {
    _sb.write("<code");
    node.attributes?.accept(this);
    _sb..write(">")..write(_htmlEscape(node.contents))..write("</code>");
    return null;
  }

  @override
  Null visitCodeBlock(CodeBlock node) {
    _sb.write("<pre");
    node.attributes?.accept(this);
    _sb
      ..write("><code")
      ..write(node.attributes?.accept(_infoStringVisitor) ?? '')
      ..write(">");
    for (String line in node.contents) {
      _sb.writeln(_htmlEscape(line));
    }
    _sb.write("</code></pre>");
    return null;
  }

  @override
  Null visitDocument(Document node) {
    _writeBlocks(node.contents);
    return null;
  }

  @override
  Null visitEmphasis(Emphasis node) {
    _sb.write("<em>");
    node.contents.accept(this);
    _sb.write("</em>");
    return null;
  }

  @override
  Null visitExtendedAttributes(ExtendedAttributes node) {
    _sb.write(node.accept(_idAttributesVisitor));
    _sb.write(node.accept(_classAttributesVisitor));
    _sb.write(node.accept(_keyValueAttributesVisitor));
    return null;
  }

  @override
  Null visitHardLineBreak(HardLineBreak node) {
    _sb.write("<br/>\n");
    return null;
  }

  @override
  Null visitHeading(Heading node) {
    _sb..write("<h")..write(node.level);
    node.attributes?.accept(this);
    _sb.write(">");
    node.contents?.accept(this);
    _sb..write("</h")..write(node.level)..write('>');
    return null;
  }

  @override
  Null visitHtmlRawBlock(HtmlRawBlock node) {
    _sb.write(node.contents);
    return null;
  }

  @override
  Null visitHtmlRawInline(HtmlRawInline node) {
    _sb.write(node.contents);
    return null;
  }

  @override
  Null visitImage(Image node) {
    _sb.write('<img src="');
    _sb.write(_urlEncode(node?.link));
    _sb.write('" alt="');

    final _ImageLabelVisitor innerVisitor = new _ImageLabelVisitor();
    node.contents.accept(innerVisitor);

    _sb..write(_htmlEscape(innerVisitor.result))..write('"');
    if (node.title != null) {
      _sb..write(' title="')..write(_htmlEscape(node.title))..write('"');
    }
    node.attributes?.accept(this);
    _sb.write(" />");
    return null;
  }

  @override
  Null visitLink(Link node) {
    _sb..write('<a href="')..write(_urlEncode(node.link))..write('"');
    if (node.title != null) {
      _sb..write(' title="')..write(_htmlEscape(node.title))..write('"');
    }
    node.attributes?.accept(this);
    _sb.write('>');
    node.contents?.accept(this);
    _sb.write('</a>');

    return null;
  }

  @override
  Null visitLinkReference(LinkReference node) => null;

  @override
  Null visitListItem(ListItem node) {
    if (node.parent is ListBlock) {
      final ListBlock listBlock = node.parent;
      if (listBlock.tight) {
        _sb.write("<li>");
        _writeBlocks(node.contents, tight: true);
        _sb.write("</li>\n");
      } else {
        if (node.contents.isEmpty) {
          _sb.write('<li></li>\n');
        } else {
          _sb.write('<li>\n');
          _writeBlocks(node.contents, tight: false);
          _sb.write('\n</li>\n');
        }
      }
    }
    return null;
  }

  @override
  Null visitNonBreakableSpace(NonBreakableSpace node) {
    _sb.write('\u{a0}');
    return null;
  }

  @override
  Null visitOrderedList(OrderedList node) {
    _sb.write("<ol");
    if (node.startIndex != 1) {
      _sb.write(' start="${node.startIndex}"');
    }
    _sb.write(">\n");
    node.visitChildren(this);
    _sb.write("</ol>");

    return null;
  }

  @override
  Null visitPara(Para node) {
    _sb.write("<p>");
    node.visitChildren(this);
    _sb.write("</p>");
    return null;
  }

  @override
  Null visitSmartChar(SmartChar node) {
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

    return null;
  }

  @override
  Null visitSpace(Space node) {
    _sb.write(" " * node.amount);
    return null;
  }

  @override
  Null visitStr(Str node) {
    _sb.write(_htmlEscape(node.contents));
    return null;
  }

  @override
  Null visitStrikeout(Strikeout node) {
    _sb.write('<del>');
    node.contents.accept(this);
    _sb.write('</del>');
    return null;
  }

  @override
  Null visitSubscript(Subscript node) {
    _sb.write("<sub>");
    node.contents.accept(this);
    _sb.write("</sub>");
    return null;
  }

  @override
  Null visitSuperscript(Superscript node) {
    _sb.write("<sup>");
    node.contents.accept(this);
    _sb.write("</sup>");
    return null;
  }

  @override
  Null visitStrong(Strong node) {
    _sb.write("<strong>");
    node.contents.accept(this);
    _sb.write("</strong>");
    return null;
  }

  @override
  Null visitTab(Tab node) {
    _sb.write("\t" * node.amount);
    return null;
  }

  @override
  Null visitTexMathDisplay(TexMathDisplay node) {
    _sb
      ..write('<span class="')
      ..write(_options.displayTexMathClasses.join(' '))
      ..write(r'">\[')
      ..write(_htmlEscape(node.contents))
      ..write(r'\]</span>');
    return null;
  }

  @override
  Null visitTexMathInline(TexMathInline node) {
    _sb
      ..write('<span class="')
      ..write(_options.inlineTexMathClasses.join(' '))
      ..write(r'">\(')
      ..write(_htmlEscape(node.contents))
      ..write(r'\)</span>');

    return null;
  }

  @override
  Null visitTexRawBlock(TexRawBlock node) {
    _sb.write(_htmlEscape(node.contents));
    return null;
  }

  @override
  Null visitThematicBreak(ThematicBreak node) {
    _sb.write("<hr/>");
    return null;
  }

  @override
  Null visitUnorderedList(UnorderedList node) {
    _sb.write("<ul>\n");
    node.visitChildren(this);
    _sb.write("</ul>");

    return null;
  }
}

/// Html writer
class HtmlWriter {
  final Options _options;

  /// Constructor
  HtmlWriter(this._options);

  /// Renders document to string
  String write(Document document) {
    final _Visitor visitor = new _Visitor(_options);
    document.accept(visitor);
    return visitor.result;
  }

  /// Predefined html writer with CommonMark default settings
  static HtmlWriter commonmark = new HtmlWriter(Options.commonmark);

  /// Predefined html writer with strict settings
  static HtmlWriter strict = new HtmlWriter(Options.strict);

  /// Predefined html writer with default settings
  static HtmlWriter defaults = new HtmlWriter(Options.defaults);
}
