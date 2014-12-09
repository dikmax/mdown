library md_proc.markdown_writer;

import 'dart:math';
import 'definitions.dart';

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


class _NotCheckedPart extends _InlinePart {
  RegExp escapedChars = new RegExp(r'[!\"#\$%&' r"'()*+,-./:;<=>?@\[\\\]^_`{|}~]");
  String escapeString(String str) => str.replaceAllMapped(escapedChars, (Match m) => r"\" + m.group(0));

  _NotCheckedPart(String content) : super(content);

  RegExp _notHeaderRegExp1 = new RegExp(r"^( {0,3})(#{1,6})$", multiLine: true);
  RegExp _notHeaderRegExp2 = new RegExp(r"^( {0,3})(#{1,6} )", multiLine: true);
  RegExp _headerRegExp = new RegExp(r" (#+ *)$");
  String smartEscape(_InlinePart before, _InlinePart after, {bool isHeader: false}) {
    if (!isHeader) {
      content = content.replaceAllMapped(_notHeaderRegExp1, (Match m) => m.group(1) + r"\" + m.group(2));
      content = content.replaceAllMapped(_notHeaderRegExp2, (Match m) => m.group(1) + r"\" + m.group(2));
    } else {
      content = content.replaceAllMapped(_headerRegExp, (Match m) => r" \" + m.group(1));
    }

    return content;
  }

  String toString() {
    return escapeString(content);
  }
}


class _InlineRenderer {
  List<_InlinePart> parts;
  Map<String, Target> _references;


  _InlineRenderer(this._references) : parts = <_InlinePart>[];


  void write(String str, [bool checked = true]) {
    if (parts.length == 0) {
      parts.add(checked ? new _CheckedPart(str) : new _NotCheckedPart(str));
      return;
    }
    if (checked && parts.last is _CheckedPart || !checked && parts.last is _NotCheckedPart) {
      parts.last.content += str;
      return;
    }
    parts.add(checked ? new _CheckedPart(str) : new _NotCheckedPart(str));
  }

  void writeInlines(Iterable<Inline> inlines, {String prevEmph}) {
    if (inlines.length == 1 && prevEmph != null) {
      if (inlines.first is Emph) {
        writeEmph(inlines.first, delimiter: prevEmph == "*" ? "_" : "*");
        return;
      }
      if (inlines.first is Strong) {
        writeStrong(inlines.first, delimiter: prevEmph == "*" ? "_" : "*");
        return;
      }
    }

    Iterator<Inline> it = inlines.iterator;
    while(it.moveNext()) {
      Inline inline = it.current;
      if (inline is Str) {
        write(inline.contents, false);
      } else if (inline is Space) {
        write(' ', false);
      } else if (inline is NonBreakableSpace) {
        write('&nbsp;');
      } else if (inline is LineBreak) {
        write('\\\n');
      } else if (inline is Emph) {
        writeEmph(inline);
      } else if (inline is Strong) {
        writeStrong(inline);
      } else if (inline is Link) {
        writeLink(inline);
      } else if (inline is Image) {
        writeImage(inline);
      } else if (inline is Code) {
        writeCodeInline(inline);
      } else if (inline is RawInline) {
        write(inline.contents);
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

  void writeEmph(Emph emph, {String delimiter: "*"}) {
    write(delimiter);
    writeInlines(emph.contents, prevEmph: delimiter);
    write(delimiter);
  }

  void writeStrong(Strong strong, {String delimiter: "*"}) {
    String delimiterString = delimiter * 2;
    write(delimiterString);
    writeInlines(strong.contents);
    write(delimiterString);
  }

  void writeLink(Link link) {
    if (link is InlineLink) {
      write('[');
      writeInlines(link.label);
      write('](');
      writeTarget(link.target);
      write(')');
      return;
    }

    if (link is ReferenceLink) {
      _references[link.reference] = link.target;
      _MarkdownBuilder builder = new _MarkdownBuilder(_references);
      builder.writeInlines(link.label);
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
      write(link.label[0].contents);
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

  void writeTarget(Target target) {
    String result;

    if (target.link.contains(' ') && !target.link.contains(r'[<>]')) {
      write('<' + target.link + '>');
    } else {
      write(target.link, false);
    }

    if (target.title != null) {
      write(' "');
      write(target.title, false);
      write('"');
    }
  }

  String toString({bool isHeader: false}) {
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

    while(current != null) {
      if (current is _NotCheckedPart) {
        buffer.write(current.smartEscape(prev, next, isHeader: isHeader));
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


  _MarkdownBuilder(this._references) : super();


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
        write("\n");
      } else if (block is UnorderedList) {
        writeUnorderedList(block, prevBlock: _b);
      } else if (block is OrderedList) {
        writeOrderedList(block, prevBlock: _b);
      } else {
        throw new UnimplementedError(block.toString());
      }
    }
  }


  void writeHorizontalRule(HorizontalRule hRule, [String unorderedListChar = "*"]) {
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
    _MarkdownBuilder inner = new _MarkdownBuilder(_references);
    inner.writeBlocks(blockquote.contents);
    String contents = inner.toString();
    if (contents.endsWith('\n')) {
      contents = contents.substring(0, contents.length - 1);
    }
    write(contents.splitMapJoin("\n", onNonMatch: (String str) => "> $str") + "\n");
  }


  void writeHeader(Header header) {
    // TODO throw exception in case of multiline header ? Or replace with space
    if (header is SetextHeader && header.level <= 2) {
      _InlineRenderer inner = new _InlineRenderer(_references);
      inner.writeInlines(header.contents);
      String inlines = inner.toString();
      write(inlines);
      write("\n");
      write((header.level == 1 ? '=' : '-') * inlines.length + "\n");
      return;
    }
    write("#" * header.level + " ");
    writeInlines(header.contents, isHeader: true);
    write("\n");
  }


  void writeCodeBlock(CodeBlock codeBlock) {
    if (codeBlock is FencedCodeBlock) {
      String fence = (codeBlock.fenceType == FenceType.BacktickFence ? '`' : '~') * codeBlock.fenceSize;
      write(fence);
      if (codeBlock.attributes is InfoString) {
        write(' ${codeBlock.attributes.language}');
      }
      write("\n");
      write(codeBlock.contents);
      write(fence);
      write('\n');
      return;
    }

    // Indented code block
    write(codeBlock.contents.splitMapJoin("\n", onNonMatch: (str) => str == "" ? str : "    " + str));
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
      _MarkdownBuilder builder = new _MarkdownBuilder(_references);
      builder.writeBlocks(listItem.contents, tight: list.tight, unorderedListChar: list.bulletType.char);
      String contents = builder.toString();
      String marker = list.bulletType.char + " ";
      String pad;

      write(marker);

      write(contents.splitMapJoin("\n", onNonMatch: (String str) {
        if (pad == null) { // First
          pad = " " * marker.length;
          return str;
        } else if (str != "") {
          return pad + str;
        }
        return str;
      }));
    }
  }


  void writeOrderedList(OrderedList list, {Block prevBlock: null}) {
    if (prevBlock is OrderedList && prevBlock.indexSeparator == list.indexSeparator) {
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
      _MarkdownBuilder builder = new _MarkdownBuilder(_references);
      builder.writeBlocks(listItem.contents, tight: list.tight);
      String contents = builder.toString();
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
      ++index;
    }
  }

  void writeInlines(Iterable<Inline> inlines, {bool isHeader: false}) {
    _InlineRenderer renderer = new _InlineRenderer(_references);
    renderer.writeInlines(inlines);
    write(renderer.toString(isHeader: isHeader));
  }

  void writeReferences() {
    if (_references.length > 0) {
      write("\n\n");

      _references.forEach((String ref, Target target) {
        write('[');
        write(ref);
        write(']: ');
        _InlineRenderer renderer = new _InlineRenderer(_references);
        renderer.writeTarget(target);
        write(renderer);
        write('\n');
      });
    }
  }
}


class MarkdownWriter {
  String write(Document document) {
    _MarkdownBuilder builder = new _MarkdownBuilder(<String, Target>{});
    builder.writeDocument(document);

    return builder.toString();
  }

  static MarkdownWriter DEFAULT = new MarkdownWriter();
}
