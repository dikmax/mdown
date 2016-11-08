library md_proc.html_writer;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/options.dart';

class _HtmlBuilder extends StringBuffer {
  Options _options;

  _HtmlBuilder(this._options) : super();

  void writeDocument(Document document) {
    writeBlocks(document.contents);
    write("\n");
  }

  // Blocks

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

      if (block is Para) {
        if (tight) {
          writeInlines(block.contents);
        } else {
          writePara(block);
        }
      } else if (block is Heading) {
        writeHeader(block);
      } else if (block is ThematicBreak) {
        write('<hr/>');
      } else if (block is CodeBlock) {
        writeCodeBlock(block);
      } else if (block is Blockquote) {
        writeBlockquote(block);
      } else if (block is TexRawBlock) {
        writeTexRawBlock(block);
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

  void writeTexRawBlock(TexRawBlock texRawBlock) {
    write(htmlEscape(texRawBlock.contents));
  }

  void writeHeader(Heading header) {
    write("<h");
    write(header.level);
    write(">");
    writeInlines(header.contents);
    write("</h");
    write(header.level);
    write(">");
  }

  void writeCodeBlock(CodeBlock codeBlock) {
    write("<pre");
    if (codeBlock.attributes is Attributes) {
      writeAttributes(codeBlock.attributes);
    }
    write("><code");
    if (codeBlock.attributes is InfoString) {
      InfoString attr = codeBlock.attributes;
      if (attr.language == "") {
        return;
      }
      write(' class="language-');
      write(htmlEscape(attr.language));
      write('"');
    }
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

  void writeAttributes(Attributes attr) {
    if (attr.identifier != null) {
      write(' id="');
      write(htmlEscape(attr.identifier));
      write('"');
    }
    if (attr.classes != null && attr.classes.length > 0) {
      write(' class="');
      write(attr.classes.map(htmlEscape).join(' '));
      write('"');
    }
    List<String> keys = attr.attributes.keys.toList(growable: false);
    keys.sort();
    keys.forEach((String key) {
      attr.attributes[key].forEach((String value) {
        write(' ');
        write(htmlEscape(key));
        write('="');
        write(htmlEscape(value));
        write('"');
      });
    });
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
        } else if (inline is SingleOpenQuote) {
          write('\u{2018}');
        } else if (inline is SingleCloseQuote || inline is Apostrophe) {
          write('\u{2019}');
        } else if (inline is DoubleOpenQuote) {
          write('\u{201c}');
        } else if (inline is DoubleCloseQuote) {
          write('\u{201d}');
        } else {
          throw new UnimplementedError(inline.toString());
        }
      } else if (inline is RawInline) {
        write(inline.contents);
      } else if (inline is TexMathInline) {
        writeTexMathInline(inline, stripped: stripped);
      } else if (inline is TexMathDisplay) {
        writeTexMathDisplay(inline, stripped: stripped);
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

  void writeTexMathInline(TexMathInline texMathInline, {bool stripped: false}) {
    if (!stripped) {
      write('<span class="');
      write(_options.inlineTexMathClasses.join(' '));
      write('">');
    }
    write(r'\(');
    write(texMathInline.contents);
    write(r'\)');
    if (!stripped) {
      write('</span>');
    }
  }

  void writeTexMathDisplay(TexMathDisplay texMathDisplay,
      {bool stripped: false}) {
    if (!stripped) {
      write('<span class="');
      write(_options.displayTexMathClasses.join(' '));
      write('">');
    }
    write(r'\[');
    write(texMathDisplay.contents);
    write(r'\]');
    if (!stripped) {
      write('</span>');
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
  // TODO HashMap.
  Map<String, String> _escape = <String, String>{
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "&": "&amp;"
  };

  String htmlEscape(String str) => str.replaceAllMapped(
      _escapedChars, (Match match) => _escape[match.group(0)]);

  RegExp _urlEncode = new RegExp(r'%[0-9a-fA-F]{2}');
  RegExp _htmlEntity = new RegExp(
      r'&(?:#x[a-f0-9]{1,8}|#[0-9]{1,8}|[a-z][a-z0-9]{1,31});',
      caseSensitive: false);

  String urlEncode(String url) {
    url = url.splitMapJoin(_urlEncode,
        onMatch: (Match m) => m.group(0),
        onNonMatch: (String s) => Uri.encodeFull(s));
    url = url.splitMapJoin(_htmlEntity,
        onMatch: (Match m) => m.group(0),
        onNonMatch: (String s) => htmlEscape(s));
    return url;
  }
}

/// Html writer
class HtmlWriter {
  Options _options;

  /// Constructor
  HtmlWriter(this._options);

  /// Renders document to string
  String write(Document document) {
    _HtmlBuilder builder = new _HtmlBuilder(_options);
    builder.writeDocument(document);
    return builder.toString();
  }

  /// Predefined html writer with CommonMark default settings
  static HtmlWriter commonmark = new HtmlWriter(Options.commonmark);

  /// Predefined html writer with strict settings
  static HtmlWriter strict = new HtmlWriter(Options.strict);

  /// Predefined html writer with default settings
  static HtmlWriter defaults = new HtmlWriter(Options.defaults);
}
