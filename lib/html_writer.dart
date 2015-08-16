library md_proc.html_writer;

import 'definitions.dart';
import 'options.dart';

class _HtmlBuilder extends StringBuffer {

  Options _options;

  _HtmlBuilder(this._options) : super();


  void writeDocument(Document document) {
    writeBlocks(document.contents);
    write("\n");
  }


  // Blocks

  bool _firstInline = false;

  void writeBlocks(Iterable<Block> blocks, {bool tight: false}) {
    Iterator<Block> it = blocks.iterator;

    bool first = true;
    while (it.moveNext()) {
      Block block = it.current;
      if (first) {
        first = false;
        if (tight && block is! Para) {
          write("\n");
        }
      } else {
        write("\n");
      }

      _firstInline = true;
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

    if (tight && blocks.length > 0 && blocks.last is! Para) {
      write("\n");
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
    if (list.tight) {
      for (ListItem item in list.items) {
        write("<li>");
        writeBlocks(item.contents, tight: true);
        write("</li>\n");
      }
    } else {
      for (ListItem item in list.items) {
        if (item.contents.length == 0) {
          write('<li></li>\n');
        } else {
          write("<li>\n");
          writeBlocks(item.contents, tight: false);
          write("\n</li>\n");
        }
      }
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
      } else if (inline is Tab) {
        write('\t');
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
      } else if (inline is Strikeout) {
        writeStrikeout(inline, stripped: stripped);
      } else if (inline is Subscript) {
        writeSubscript(inline, stripped: stripped);
      } else if (inline is Superscript) {
        writeSuperscript(inline, stripped: stripped);
      } else if (inline is Link) {
        writeLink(inline, stripped: stripped);
      } else if (inline is Image) {
        writeImage(inline, stripped: stripped);
      } else if (inline is Code) {
        writeCodeInline(inline, stripped: stripped);
      } else if (inline is SmartChar) {
        if (inline is Ellipsis) {
          write('\u{2026}');
        } else if (inline is MDash) {
          write('\u{2014}');
        } else if (inline is NDash) {
          write('\u{2013}');
        } else {
          throw new UnimplementedError(inline.toString());
        }
      } else if (inline is SmartQuote) {
        writeSmartQuote(inline, stripped: stripped);
      } else if (inline is RawInline) {
        write(inline.contents);
      } else {
        throw new UnimplementedError(inline.toString());
      }

      _firstInline = false;
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


  void writeStrikeout(Strikeout strikeout, {bool stripped: false}) {
    if (!stripped) {
      write('<del>');
    }
    writeInlines(strikeout.contents, stripped: stripped);
    if (!stripped) {
      write('</del>');
    }
  }


  void writeSubscript(Subscript subscript, {bool stripped: false}) {
    if (!stripped) {
      write('<sub>');
    }
    writeInlines(subscript.contents, stripped: stripped);
    if (!stripped) {
      write('</sub>');
    }
  }


  void writeSuperscript(Superscript superscript, {bool stripped: false}) {
    if (!stripped) {
      write('<sup>');
    }
    writeInlines(superscript.contents, stripped: stripped);
    if (!stripped) {
      write('</sup>');
    }
  }


  void writeSmartQuote(SmartQuote quote, {bool stripped: false}) {
    // TODO different quotation styles
    if (quote.open && quote.close) {
      write(quote.single ? '\u{2018}' : '\u{201c}');
      writeInlines(quote.contents, stripped: stripped);
      write(quote.single ? '\u{2019}' : '\u{201d}');
    } else {
      if (!quote.single && quote.open && _firstInline) {
        // If double quote is first char in inline then it can be opening.
        write('\u{201c}');
      } else {
        // Single quote have no contents and always closing.
        write(quote.single ? '\u{2019}' : '\u{201d}');
      }
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
      _HtmlBuilder builder = new _HtmlBuilder(_options);
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

  Options _options;

  HtmlWriter(this._options);

  String write(Document document) {
    _HtmlBuilder builder = new _HtmlBuilder(_options);
    builder.writeDocument(document);
    return builder.toString();
  }

  static HtmlWriter commonmark = new HtmlWriter(Options.commonmark);
  static HtmlWriter strict = new HtmlWriter(Options.strict);
  static HtmlWriter defaults = new HtmlWriter(Options.defaults);
}
