library md_proc.html_writer;

import 'definitions.dart';

class _HtmlBuilder extends StringBuffer {

  _HtmlBuilder() : super();


  void writeDocument(Document document) {
    writeBlocks(document.contents);
    write("\n");
  }


  // Blocks

  void writeBlocks(Iterable<Block> blocks, {bool tight: false}) {
    Iterator<Block> it = blocks.iterator;

    bool first = true;
    while (it.moveNext()) {
      if (first) {
        first = false;
      } else {
        write("\n");
      }
      Block block = it.current;

      if (block is Para) {
        if (tight) {
          writeInlines(block.contents);
        } else {
          writePara(block);
        }
      } else if (block is Header) {
        writeHeader(block);
      } else if (block is HorizontalRule) {
        write('<hr/>');
      } else if (block is CodeBlock) {
        writeCodeBlock(block);
      } else if (block is Blockquote) {
        writeBlockquote(block);
      } else if (block is RawBlock) {
        write(block.contents);
      } else if (block is UnorderedList) {
        writeUnorderedList(block);
      } else if (block is OrderedList) {
        writeOrderedList(block);
      } else {
        throw new UnimplementedError(block.toString());
      }
    }
  }


  void writeBlockquote(Blockquote blockquote) {
    write("<blockquote>\n");
    writeBlocks(blockquote.contents);
    write("\n</blockquote>");
  }


  void writeHeader(Header header) {
    write("<h");
    write(header.level);
    write(">");
    writeInlines(header.contents);
    write("</h");
    write(header.level);
    write(">");
  }


  void writeCodeBlock(CodeBlock codeBlock) {
    write("<pre><code");
    writeAttributes(codeBlock.attributes);
    write(">");
    write(htmlEscape(codeBlock.contents));
    write("</code></pre>");
  }

  void writeListItems(ListBlock list) {
    for (ListItem item in list.items) {
      write("<li>");
      writeBlocks(item.contents, tight: list.tight);
      write("</li>\n");
    }
  }

  void writeUnorderedList(UnorderedList list) {
    write("<ul>\n");
    writeListItems(list);
    write("</ul>");
  }


  void writeOrderedList(OrderedList list) {
    write("<ol");
    if (list.startIndex != 1) {
      write(' start="');
      write(list.startIndex);
      write('"');
    }
    write(">\n");
    writeListItems(list);
    write("</ol>");
  }

  void writePara(Para para) {
    write("<p>");
    writeInlines(para.contents);
    write("</p>");
  }


  // Attributes

  void writeAttributes(Attr attr) {
    if (attr is EmptyAttr) {
      return;
    } else if (attr is InfoString) {
      if (attr.language == "") {
        return;
      }
      write(' class="language-');
      write(attr.language);
      write('"');
    } else {
      throw new UnimplementedError(attr.toString());
    }
  }


  // Inlines

  void writeInlines(Iterable<Inline> inlines, {bool stripped: false}) {
    for (Inline inline in inlines) {
      if (inline is Str) {
        write(htmlEscape(inline.contents));
      } else if (inline is Space) {
        write(' ');
      } else if (inline is NonBreakableSpace) {
        write('\u{a0}');
      } else if (inline is LineBreak) {
        if (stripped) {
          write(' ');
        } else {
          write('<br/>\n');
        }
      } else if (inline is Emph) {
        writeEmph(inline, stripped: stripped);
      } else if (inline is Strong) {
        writeStrong(inline, stripped: stripped);
      } else if (inline is Link) {
        writeLink(inline, stripped: stripped);
      } else if (inline is Image) {
        writeImage(inline, stripped: stripped);
      } else if (inline is Code) {
        writeCodeInline(inline, stripped: stripped);
      } else if (inline is RawInline) {
        write(inline.contents);
      } else {
        throw new UnimplementedError(inline.toString());
      }
    }
  }


  void writeCodeInline(Code code, {bool stripped: false}) {
    if (!stripped) {
      write('<code>');
    }
    write(htmlEscape(code.contents));
    if (!stripped) {
      write('</code>');
    }
  }


  void writeEmph(Emph emph, {bool stripped: false}) {
    if (!stripped) {
      write('<em>');
    }
    writeInlines(emph.contents, stripped: stripped);
    if (!stripped) {
      write('</em>');
    }
  }


  void writeStrong(Strong strong, {bool stripped: false}) {
    if (!stripped) {
      write('<strong>');
    }
    writeInlines(strong.contents, stripped: stripped);
    if (!stripped) {
      write('</strong>');
    }
  }


  void writeLink(Link link, {bool stripped: false}) {
    if (!stripped) {
      write('<a href="');
      write(urlEncode(link.target.link));
      write('"');
      if (link.target.title != null) {
        write(' title="');
        write(htmlEscape(link.target.title));
        write('"');
      }
      write('>');
    }
    writeInlines(link.label, stripped: stripped);
    if (!stripped) {
      write('</a>');
    }
  }


  void writeImage(Image image, {bool stripped: false}) {
    if (!stripped) {
      write('<img src="');
      write(urlEncode(image.target.link));
      write('" alt="');
      _HtmlBuilder builder = new _HtmlBuilder();
      builder.writeInlines(image.label, stripped: true);
      write(htmlEscape(builder.toString()));
      write('"');
      if (image.target.title != null) {
        write(' title="');
        write(htmlEscape(image.target.title));
        write('"');
      }
      write(" />");
    } else {
      writeInlines(image.label, stripped: true);
    }
  }


  // Escaping

  RegExp _escapedChars = new RegExp(r'[<>&"]');
  Map<String, String> _escape = <String, String>{
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "&": "&amp;"
  };

  String htmlEscape(String str) => str.replaceAllMapped(_escapedChars, (Match match) => _escape[match.group(0)]);


  RegExp _urlEncode = new RegExp(r'%[0-9a-fA-F]{2}');
  RegExp _htmlEntity = new RegExp(r'&(?:#x[a-f0-9]{1,8}|#[0-9]{1,8}|[a-z][a-z0-9]{1,31});', caseSensitive: false);

  String urlEncode(String url) {
    url = url.splitMapJoin(_urlEncode, onMatch: (Match m) => m.group(0), onNonMatch: (String s) => Uri.encodeFull(s));
    url = url.splitMapJoin(_htmlEntity, onMatch: (Match m) => m.group(0), onNonMatch: (String s) => htmlEscape(s));
    return url;
  }
}


class HtmlWriter {

  String write(Document document) {
    _HtmlBuilder builder = new _HtmlBuilder();
    builder.writeDocument(document);
    return builder.toString();
  }


  static HtmlWriter DEFAULT = new HtmlWriter();
}
