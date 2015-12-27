library md_proc.markdown_writer;

import 'definitions.dart';
import 'markdown_parser.dart';
import 'options.dart';

abstract class _InlinePart {
  String content;

  _InlinePart(this.content);
}

class _CheckedPart extends _InlinePart {
  _CheckedPart(String content) : super(content);

  String toString() {
    return content;
  }
}

class _InlineTypes {
  bool code = false;
  bool emphOrString = false;
  bool inlineLink = false;
  bool referenceLink = false;
  bool autoLink = false;
  bool image = false;
  bool rawHtml = false;
}

class _EscapeContext {
  final bool escapeStar;
  final bool escapeUnderscore;
  final bool escapeParens;
  final bool escapeQuot;
  final bool escapeSpace;
  final bool isHeader;
  final bool isLabel;

  const _EscapeContext(
      {this.escapeStar: false,
      this.escapeUnderscore: false,
      this.escapeParens: false,
      this.escapeQuot: false,
      this.escapeSpace: false,
      this.isHeader: false,
      this.isLabel: false});

  _EscapeContext copy(
      {bool escapeStar,
      bool escapeUnderscore,
      bool escapeParens,
      bool escapeQuot,
      bool escapeSpace,
      bool isHeader,
      bool isLabel}) {
    return new _EscapeContext(
        escapeStar: escapeStar != null ? escapeStar : this.escapeStar,
        escapeUnderscore:
            escapeUnderscore != null ? escapeUnderscore : this.escapeUnderscore,
        escapeParens: escapeParens != null ? escapeParens : this.escapeParens,
        escapeQuot: escapeQuot != null ? escapeQuot : this.escapeQuot,
        escapeSpace: escapeSpace != null ? escapeSpace : this.escapeSpace,
        isHeader: isHeader != null ? isHeader : this.isHeader,
        isLabel: isLabel != null ? isLabel : this.isLabel);
  }

  static const _EscapeContext empty = const _EscapeContext();
}

class _NotCheckedPart extends _InlinePart {
  RegExp escapedChars =
      new RegExp(r'[!\"#\$%&' r"'()*+,-./:;<=>?@\[\\\]^_`{|}~]");
  String escapeString(String str) =>
      str.replaceAllMapped(escapedChars, (Match m) => r"\" + m.group(0));

  _EscapeContext context;
  Options _options;
  CommonMarkParser _parser;

  _NotCheckedPart(String content, this._options,
      [this.context = _EscapeContext.empty])
      : super(content) {
    _parser = new CommonMarkParser(_options, {});
  }

  RegExp _notHeaderRegExp1 = new RegExp(r"^( {0,3})(#{1,6})$", multiLine: true);
  RegExp _notHeaderRegExp2 = new RegExp(r"^( {0,3})(#{1,6} )", multiLine: true);
  RegExp _atxHeaderRegExp = new RegExp(r" (#+ *)$");
  RegExp _setExtHeaderRegExp = new RegExp("^(.*\n {0,3})(=+|-+)( *(\$|\n))");
  RegExp _horizontalRuleRegExp = new RegExp(
      r'^( {0,3})((- *){3,}|(_ *){3,}|(\* *){3,})$',
      multiLine: true);

  RegExp _blockquoteRegExp = new RegExp(r"^( {0,3})>( |$)", multiLine: true);
  RegExp _unorderedListRegExp =
      new RegExp(r"^( {0,3})([+\-*])( |$)", multiLine: true);
  RegExp _orderedListRegExp =
      new RegExp(r"^( {0,3}\d+)([.\)])( |$)", multiLine: true);
  RegExp _fencedTildeCodeRegExp =
      new RegExp(r"^( {0,3})(~{3,})", multiLine: true);
  RegExp _linkReferenceRegExp =
      new RegExp(r"^( {0,3})(\[.*\]:)", multiLine: true);

  RegExp _htmlRegExp = new RegExp(r"[<>]");
  RegExp _codeRegExp = new RegExp(r"`+");
  RegExp _emphOrStringRegExp = new RegExp(r"[_*]");
  RegExp _imageRegExp = new RegExp(r"!\[");
  RegExp _linkRegExp = new RegExp(r"\[");

  String smartEscape(_InlinePart before, _InlinePart after) {
    String replaceChars = r"\\"; // All backslashes should be escaped by default

    if (context.escapeStar) {
      replaceChars += "*";
    }
    if (context.escapeUnderscore) {
      replaceChars += "_";
    }
    if (context.escapeParens) {
      replaceChars += "()";
    }
    if (_options.smartPunctuation) {
      replaceChars += '"\'';
    } else if (context.escapeQuot) {
      replaceChars += '"';
    }
    if (context.isLabel) {
      replaceChars += r"\[\]";
    }
    if (context.escapeSpace) {
      replaceChars += " ";
    }
    if (_options.subscript) {
      replaceChars += '~';
    }
    if (_options.superscript) {
      replaceChars += '^';
    }

    content = content.replaceAllMapped(
        new RegExp("[" + replaceChars + "]"), (Match m) => r"\" + m.group(0));

    if (_options.smartPunctuation) {
      content = content.replaceAllMapped(new RegExp(r"(\.\.\.|-{2,3})"),
          (Match m) {
        String val = m.group(0);
        if (val == '...' || val == '--') {
          return r"\" + val;
        } else if (val == '---') {
          return r"\-\-\-";
        }
        return val;
      });
    }

    if (_options.strikeout) {
      content = content.replaceAll("~~", r"\~~");
    }

    if (!context.isHeader) {
      content = content.replaceAllMapped(
          _notHeaderRegExp1, (Match m) => m.group(1) + r"\" + m.group(2));
      content = content.replaceAllMapped(
          _notHeaderRegExp2, (Match m) => m.group(1) + r"\" + m.group(2));

      content = content.replaceAllMapped(
          _horizontalRuleRegExp, (Match m) => m.group(1) + r"\" + m.group(2));
      content = content.replaceAllMapped(_setExtHeaderRegExp,
          (Match m) => m.group(1) + r"\" + m.group(2) + m.group(3));
    } else {
      content = content.replaceAllMapped(
          _atxHeaderRegExp, (Match m) => r" \" + m.group(1));
    }

    // Parsing inline code to detect what should be escaped

    bool test = true;
    while (test) {
      test = false;

      Inlines parsed = _parser.inlines.parse(content);
      _InlineTypes types = new _InlineTypes();
      detectInlines(parsed, types);

      // TODO add tests for inner escaping
      if (types.code) {
        content = content.replaceAllMapped(
            _codeRegExp, (Match m) => r"\" + m.group(0));
        test = true;
      }
      if (types.emphOrString) {
        content = content.replaceAllMapped(
            _emphOrStringRegExp, (Match m) => r"\" + m.group(0));
      }
      if (types.image) {
        content = content.replaceAllMapped(
            _imageRegExp, (Match m) => r"\" + m.group(0));
      }
      if (types.referenceLink || types.inlineLink) {
        content = content.replaceAllMapped(
            _linkRegExp, (Match m) => r"\" + m.group(0));
      }
      if (types.rawHtml || types.autoLink) {
        content = content.replaceAllMapped(
            _htmlRegExp, (Match m) => r"\" + m.group(0));
        test = true;
      }
    }

    // If ! followed by checked part starting with [, then ! should be escaped, or we'll get image instead of link
    if (after is _CheckedPart &&
        after.content.startsWith("[") &&
        content.endsWith("!")) {
      content = content.substring(0, content.length - 1) + r"\!";
    }

    // Some of these could be escaped by inlines, so put it here.
    content = content.replaceAllMapped(
        _blockquoteRegExp, (Match m) => m.group(1) + r"\>" + m.group(2));
    content = content.replaceAllMapped(_unorderedListRegExp,
        (Match m) => m.group(1) + r"\" + m.group(2) + m.group(3));
    content = content.replaceAllMapped(_orderedListRegExp,
        (Match m) => m.group(1) + r"\" + m.group(2) + m.group(3));
    content = content.replaceAllMapped(
        _fencedTildeCodeRegExp, (Match m) => m.group(1) + r"\" + m.group(2));
    content = content.replaceAllMapped(
        _linkReferenceRegExp, (Match m) => m.group(1) + r"\" + m.group(2));

    return content;
  }

  void detectInlines(Iterable<Inline> inlines, _InlineTypes types) {
    inlines.forEach((Inline inline) {
      if (inline is Code) {
        types.code = true;
      } else if (inline is Emph) {
        types.emphOrString = true;
        detectInlines(inline.contents, types);
      } else if (inline is Strong) {
        types.emphOrString = true;
        detectInlines(inline.contents, types);
      } else if (inline is InlineLink) {
        types.inlineLink = true;
        detectInlines(inline.label, types);
      } else if (inline is ReferenceLink) {
        types.referenceLink = true;
        detectInlines(inline.label, types);
      } else if (inline is Autolink) {
        types.autoLink = true;
      } else if (inline is InlineImage) {
        types.image = true;
        types.inlineLink = true;
        detectInlines(inline.label, types);
      } else if (inline is ReferenceImage) {
        types.image = true;
        types.referenceLink = true;
        detectInlines(inline.label, types);
      } else if (inline is HtmlRawInline) {
        types.rawHtml = true;
      }
    });
  }

  String toString() {
    return escapeString(content);
  }
}

class _InlineRenderer {
  List<_InlinePart> parts;
  Map<String, Target> _references;
  Options _options;

  _InlineRenderer(this._references, this._options) : parts = <_InlinePart>[];

  /// If context == null then token doesn't require escaping
  void write(String str, [_EscapeContext context]) {
    if (parts.length == 0) {
      parts.add(context == null
          ? new _CheckedPart(str)
          : new _NotCheckedPart(str, _options, context));
      return;
    }
    if (context == null && parts.last is _CheckedPart) {
      parts.last.content += str;
      return;
    } else if (context != null && parts.last is _NotCheckedPart) {
      _NotCheckedPart last = parts.last;
      if (context == last.context) {
        last.content += str;
        return;
      }
    }
    parts.add(context == null
        ? new _CheckedPart(str)
        : new _NotCheckedPart(str, _options, context));
  }

  void writeInlines(Iterable<Inline> inlines,
      {String prevEmph, _EscapeContext context: _EscapeContext.empty}) {
    if (inlines.length == 1 && prevEmph != null) {
      if (inlines.first is Emph) {
        writeEmph(inlines.first,
            delimiter: prevEmph == "*" ? "_" : "*", context: context);
        return;
      }
      if (inlines.first is Strong) {
        writeStrong(inlines.first,
            delimiter: prevEmph == "*" ? "_" : "*", context: context);
        return;
      }
    }

    Iterator<Inline> it = inlines.iterator;
    while (it.moveNext()) {
      Inline inline = it.current;
      if (inline is Str) {
        String contents = inline.contents;
        write(contents, context);
      } else if (inline is Space) {
        write(' ', context);
      } else if (inline is NonBreakableSpace) {
        write('&nbsp;');
      } else if (inline is Tab) {
        write('\t');
      } else if (inline is LineBreak) {
        write('\\\n');
      } else if (inline is Emph) {
        writeEmph(inline, context: context);
      } else if (inline is Strong) {
        writeStrong(inline, context: context);
      } else if (inline is Link) {
        writeLink(inline);
      } else if (inline is Image) {
        writeImage(inline);
      } else if (inline is Code) {
        writeCodeInline(inline);
      } else if (inline is SmartChar) {
        if (inline is Ellipsis) {
          write('...');
        } else if (inline is MDash) {
          write('---');
        } else if (inline is NDash) {
          write('--');
        } else {
          throw new UnimplementedError(inline.toString());
        }
      } else if (inline is SmartQuote) {
        writeSmartQuote(inline, context: context);
      } else if (inline is Strikeout) {
        writeStrikeout(inline, context: context);
      } else if (inline is Subscript) {
        writeSubscript(inline, context: context);
      } else if (inline is Superscript) {
        writeSuperscript(inline, context: context);
      } else if (inline is RawInline) {
        write(inline.contents);
      } else if (inline is TexMathInline) {
        writeTexMathInline(inline, context: context);
      } else if (inline is TexMathDisplay) {
        writeTexMathDisplay(inline, context: context);
      } else {
        throw new UnimplementedError(inline.toString());
      }
    }
  }

  void writeCodeInline(Code code) {
    String fence = '`' * code.fenceSize;
    String contents = code.contents;
    if (contents == '') {
      contents = ' ';
    } else {
      if (contents.startsWith('`')) {
        contents = ' ' + contents;
      }
      if (contents.endsWith('`')) {
        contents += ' ';
      }
    }
    write(fence);
    write(contents);
    write(fence);
  }

  void writeEmph(Emph emph,
      {String delimiter: "*", _EscapeContext context: _EscapeContext.empty}) {
    if (delimiter == "*" && !context.escapeStar) {
      context = context.copy(escapeStar: true);
    } else if (delimiter == "_" && !context.escapeUnderscore) {
      context = context.copy(escapeUnderscore: true);
    }

    write(delimiter);
    writeInlines(emph.contents, prevEmph: delimiter, context: context);
    write(delimiter);
  }

  void writeStrong(Strong strong,
      {String delimiter: "*", _EscapeContext context: _EscapeContext.empty}) {
    if (delimiter == "*" && !context.escapeStar) {
      context = context.copy(escapeStar: true);
    } else if (delimiter == "_" && !context.escapeUnderscore) {
      context = context.copy(escapeUnderscore: true);
    }

    String delimiterString = delimiter * 2;
    write(delimiterString);
    writeInlines(strong.contents, context: context);
    write(delimiterString);
  }

  void writeSmartQuote(SmartQuote quote,
      {_EscapeContext context: _EscapeContext.empty}) {
    if (quote.open) {
      write(quote.single ? "'" : '"');
    }
    writeInlines(quote.contents, context: context);
    if (quote.close) {
      write(quote.single ? "'" : '"');
    }
  }

  void writeStrikeout(Strikeout strikeout,
      {_EscapeContext context: _EscapeContext.empty}) {
    write("~~");
    writeInlines(strikeout.contents, context: context);
    write("~~");
  }

  void writeSubscript(Subscript subscript,
      {_EscapeContext context: _EscapeContext.empty}) {
    write("~");
    writeInlines(subscript.contents, context: context.copy(escapeSpace: true));
    write("~");
  }

  void writeSuperscript(Superscript superscript,
      {_EscapeContext context: _EscapeContext.empty}) {
    write("^");
    writeInlines(superscript.contents,
        context: context.copy(escapeSpace: true));
    write("^");
  }

  void writeTexMathInline(TexMathInline texMathInline,
      {_EscapeContext context: _EscapeContext.empty}) {
    if (_options.texMathDollars) {
      write(r"$");
      write(texMathInline.contents.replaceAll(r'$', r'\$'));
      write(r"$");
    } else if (_options.texMathDoubleBackslash) {
      write(r"\\(");
      write(texMathInline.contents);
      write(r"\\)");
    } else if (_options.texMathSingleBackslash) {
      write(r"\(");
      write(texMathInline.contents);
      write(r"\)");
    } else {
      throw new UnsupportedError("No TEX math extensions enabled");
    }
  }

  void writeTexMathDisplay(TexMathDisplay texMathDisplay,
      {_EscapeContext context: _EscapeContext.empty}) {
    if (_options.texMathDollars) {
      write(r"$$");
      write(texMathDisplay.contents);
      write(r"$$");
    } else if (_options.texMathDoubleBackslash) {
      write(r"\\[");
      write(texMathDisplay.contents);
      write(r"\\]");
    } else if (_options.texMathSingleBackslash) {
      write(r"\[");
      write(texMathDisplay.contents);
      write(r"\]");
    } else {
      throw new UnsupportedError("No TEX math extensions enabled");
    }
  }

  void writeLink(Link link) {
    if (link is InlineLink) {
      write('[');
      _InlineRenderer renderer = new _InlineRenderer(_references, _options);
      renderer.writeInlines(link.label,
          context: new _EscapeContext(isLabel: true));
      write(renderer.toString());
      write('](');
      writeTarget(link.target);
      write(')');
      return;
    }

    if (link is ReferenceLink) {
      _references[link.reference] = link.target;
      _MarkdownBuilder builder = new _MarkdownBuilder(_references, _options);

      builder.writeInlines(link.label,
          context: new _EscapeContext(isLabel: true));
      String inlines = builder.toString();
      write('[');
      write(inlines);
      write(']');
      if (inlines.toUpperCase() != link.reference.toUpperCase()) {
        write('[');
        write(link.reference);
        write(']');
      }
      return;
    }

    // Autolink
    write('<');
    if (link.label.length > 0 && link.label[0] is Str) {
      Str labelContents = link.label[0];
      write(labelContents.contents);
    } else {
      write(link.target.link);
    }
    write('>');
  }

  void writeImage(Image image) {
    // TODO reference images
    write('![');
    writeInlines(image.label);
    write('](');
    writeTarget(image.target);
    write(')');
  }

  RegExp htmlEntity = new RegExp(r"&[0-9a-zA-Z]+;");

  void writeTarget(Target target, {bool isInline: false}) {
    String link = target.link;
    if (link.contains(htmlEntity)) {
      link = link.replaceAll("<", "&lt;").replaceAll(">", "&gt;");
      write('<' + link + '>');
    } else if (link.contains(' ') && !link.contains(r'[<>]')) {
      write('<' + link + '>');
    } else {
      write(link, new _EscapeContext(escapeParens: true));
    }

    if (target.title != null) {
      write(' "');
      write(target.title, new _EscapeContext(escapeQuot: true));
      write('"');
    }
  }

  String toString() {
    StringBuffer buffer = new StringBuffer();
    Iterator<_InlinePart> it = parts.iterator;
    _InlinePart prev = null;
    if (!it.moveNext()) {
      return '';
    }
    _InlinePart current = it.current;
    _InlinePart next = null;
    if (it.moveNext()) {
      next = it.current;
    }

    while (current != null) {
      if (current is _NotCheckedPart) {
        buffer.write(current.smartEscape(prev, next));
      } else {
        buffer.write(current);
      }

      prev = current;
      current = next;
      if (it.moveNext()) {
        next = it.current;
      } else {
        next = null;
      }
    }

    return buffer.toString();
  }
}

class _MarkdownBuilder extends StringBuffer {
  Map<String, Target> _references;

  Options _options;

  _MarkdownBuilder(this._references, this._options) : super();

  void writeDocument(Document document) {
    writeBlocks(document.contents);
    writeReferences();
  }

  void writeBlocks(Iterable<Block> blocks,
      {bool tight: false, String unorderedListChar: "*"}) {
    Block prevBlock = null;
    Iterator<Block> it = blocks.iterator;
    bool first = true;
    while (it.moveNext()) {
      if (first) {
        first = false;
      } else if (!tight) {
        write("\n");
      }

      Block block = it.current;
      Block _b = prevBlock;
      prevBlock = block;

      if (block is Para) {
        writePara(block);
      } else if (block is Header) {
        writeHeader(block);
      } else if (block is HorizontalRule) {
        writeHorizontalRule(block, unorderedListChar);
      } else if (block is CodeBlock) {
        if (_b is ListBlock) {
          write('\n');
        }
        writeCodeBlock(block);
      } else if (block is Blockquote) {
        writeBlockquote(block);
      } else if (block is RawBlock) {
        write(block.contents);
        if (!tight) {
          write("\n");
        }
      } else if (block is UnorderedList) {
        writeUnorderedList(block, prevBlock: _b);
      } else if (block is OrderedList) {
        writeOrderedList(block, prevBlock: _b);
      } else {
        throw new UnimplementedError(block.toString());
      }
    }
  }

  void writeHorizontalRule(HorizontalRule hRule,
      [String unorderedListChar = "*"]) {
    if (unorderedListChar == "-") {
      write('*' * 10);
    } else {
      write('-' * 10);
    }
  }

  void writePara(Para para) {
    writeInlines(para.contents);
    write("\n");
  }

  void writeBlockquote(Blockquote blockquote) {
    _MarkdownBuilder inner = new _MarkdownBuilder(_references, _options);
    inner.writeBlocks(blockquote.contents);
    String contents = inner.toString();
    if (contents.endsWith('\n')) {
      contents = contents.substring(0, contents.length - 1);
    }
    write(contents.splitMapJoin("\n", onNonMatch: (String str) => "> $str") +
        "\n");
  }

  void writeHeader(Header header) {
    // TODO throw exception in case of multiline header ? Or replace with space
    if (header is SetextHeader && header.level <= 2) {
      _InlineRenderer inner = new _InlineRenderer(_references, _options);
      inner.writeInlines(header.contents);
      String inlines = inner.toString();
      write(inlines);
      write("\n");
      write((header.level == 1 ? '=' : '-') * inlines.length + "\n");
      return;
    }
    write("#" * header.level + " ");
    writeInlines(header.contents, context: new _EscapeContext(isHeader: true));
    write("\n");
  }

  void writeCodeBlock(CodeBlock codeBlock) {
    if (codeBlock is FencedCodeBlock) {
      String fence = (codeBlock.fenceType == FenceType.backtick ? '`' : '~') *
          codeBlock.fenceSize;
      write(fence);
      if (codeBlock.attributes is InfoString) {
        InfoString attributes = codeBlock.attributes;
        write(' ${attributes.language}');
      }
      write("\n");
      write(codeBlock.contents);
      write(fence);
      write('\n');
      return;
    }

    // Indented code block
    write(codeBlock.contents.splitMapJoin("\n",
        onNonMatch: (String str) => str == "" ? str : "    " + str));
  }

  void writeUnorderedList(UnorderedList list, {Block prevBlock: null}) {
    if (prevBlock is UnorderedList && prevBlock.bulletType == list.bulletType) {
      write("\n");
    }

    Iterator<ListItem> it = list.items.iterator;
    bool first = true;
    bool tight = list.tight;
    while (it.moveNext()) {
      if (first) {
        first = false;
      } else if (!tight) {
        write("\n");
      }

      ListItem listItem = it.current;
      _MarkdownBuilder builder = new _MarkdownBuilder(_references, _options);
      builder.writeBlocks(listItem.contents,
          tight: list.tight, unorderedListChar: list.bulletType.char);
      String contents = builder.toString();
      String marker = list.bulletType.char;
      String pad;

      write(marker);

      if (contents.length == 0) {
        write("\n");
      } else {
        write(" ");

        write(contents.splitMapJoin("\n", onNonMatch: (String str) {
          if (pad == null) {
            // First
            pad = " " * (marker.length + 1);
            return str;
          } else if (str != "") {
            return pad + str;
          }
          return str;
        }));
      }
    }
  }

  void writeOrderedList(OrderedList list, {Block prevBlock: null}) {
    if (prevBlock is OrderedList &&
        prevBlock.indexSeparator == list.indexSeparator) {
      write("\n");
    }
    int index = list.startIndex;
    Iterator<ListItem> it = list.items.iterator;
    bool first = true;
    bool tight = list.tight;
    while (it.moveNext()) {
      if (first) {
        first = false;
      } else if (!tight) {
        write("\n");
      }

      ListItem listItem = it.current;
      _MarkdownBuilder builder = new _MarkdownBuilder(_references, _options);
      builder.writeBlocks(listItem.contents, tight: list.tight);
      String contents = builder.toString();

      if (contents.length == 0) {
        write(index.toString() + list.indexSeparator.char);
        write("\n");
      } else {
        String pad;
        write(contents.splitMapJoin("\n", onNonMatch: (String str) {
          if (pad == null) {
            String marker = index.toString() + list.indexSeparator.char + " ";
            pad = " " * marker.length;
            return marker + str;
          } else if (str != "") {
            return pad + str;
          }
          return str;
        }));
      }
      ++index;
    }
  }

  void writeInlines(Iterable<Inline> inlines,
      {_EscapeContext context: _EscapeContext.empty}) {
    _InlineRenderer renderer = new _InlineRenderer(_references, _options);
    renderer.writeInlines(inlines, context: context);
    write(renderer.toString());
  }

  void writeReferences() {
    if (_references.length > 0) {
      write("\n\n");

      _references.forEach((String ref, Target target) {
        write('[');
        write(ref);
        write(']: ');
        _InlineRenderer renderer = new _InlineRenderer(_references, _options);
        renderer.writeTarget(target);
        write(renderer);
        write('\n');
      });
    }
  }
}

class MarkdownWriter {
  final Options _options;

  const MarkdownWriter(this._options);

  String write(Document document) {
    _MarkdownBuilder builder =
        new _MarkdownBuilder(<String, Target>{}, _options);
    builder.writeDocument(document);

    return builder.toString();
  }

  static const MarkdownWriter commonmark =
      const MarkdownWriter(Options.commonmark);
  static const MarkdownWriter strict = const MarkdownWriter(Options.strict);
  static const MarkdownWriter defaults = const MarkdownWriter(Options.defaults);
}
