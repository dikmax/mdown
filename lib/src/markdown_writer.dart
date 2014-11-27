library md_proc.html_writer;

import 'definitions.dart';

// TODO make all members private
class MarkdownWriter {
  Map<String, Target> _references;
  String write(Document document) {
    _references = <String, Target>{};
    var blocks = writeBlocks(document.contents) + "\n\n";
    return blocks + _writeReferences();
  }

  String writeBlocks(Iterable<Block> blocks,
                     {bool tight: false, String unorderedListChar: "*"}) => blocks.map((Block block) {
    if (block is Para) {
      return writePara(block);
    } else if (block is Header) {
      return writeHeader(block);
    } else if (block is HorizontalRule) {
      return writeHorizontalRule(block, unorderedListChar);
    } else if (block is CodeBlock) {
      return writeCodeBlock(block);
    } else if (block is Blockquote) {
      return writeBlockquote(block);
    } else if (block is RawBlock) {
      return block.contents + "\n";
    } else if (block is UnorderedList) {
      return writeUnorderedList(block);
    } else if (block is OrderedList) {
      return writeOrderedList(block);
    }

    throw new UnimplementedError(block.toString());
  }).join(tight ? "" : "\n");

  String writeHorizontalRule(HorizontalRule hRule, [String unorderedListChar = "*"]) {
    if (unorderedListChar == "-") {
      return '*' * 10;
    }
    return '-' * 10;
  }

  String writePara(Para para) {
    return writeInlines(para.contents) + "\n";
  }

  String writeBlockquote(Blockquote blockquote) {
    String contents = writeBlocks(blockquote.contents);
    if (contents.endsWith('\n')) {
      contents = contents.substring(0, contents.length - 1);
    }
    return contents.splitMapJoin("\n", onNonMatch: (String str) => "> $str") + "\n";
  }

  String writeHeader(Header header) {
    String inlines = writeInlines(header.contents);
    if (header is SetextHeader && header.level == 2) {
      return inlines + "\n" + (header.level == 1 ? '=' : '-') * inlines.length + "\n";
    }
    return "#" * header.level + " " + inlines + "\n";
  }

  String writeCodeBlock(CodeBlock codeBlock) {
    if (codeBlock is FencedCodeBlock) {
      String fence = (codeBlock.fenceType == FenceType.BacktickFence ? '`' : '~') * codeBlock.fenceSize;
      String result = fence;
      if (codeBlock.attributes is InfoString) {
        result += ' ${codeBlock.attributes.language}';
      }
      result += '\n${codeBlock.contents}${fence}\n';
      return result;
    }
    // Indented code block
    return codeBlock.contents.splitMapJoin("\n", onNonMatch: (str) => str == "" ? str : "    " + str);
  }

  String writeUnorderedList(UnorderedList list) {
    String result = "";
    list.items.forEach((ListItem listItem) {
      String pad;
      String contents = writeBlocks(listItem.contents, tight: list.tight, unorderedListChar: list.bulletType.char);
      contents = contents.splitMapJoin("\n", onNonMatch: (String str) {
        if (pad == null) {
          String marker = list.bulletType.char + " ";
          pad = " " * marker.length;
          return marker + str;
        } else if (str != "") {
          return pad + str;
        }
        return str;
      });
      if (!list.tight) {
        contents += '\n';
      }
      result += contents;
    });
    if (!list.tight) {
      result += '\n';
    }
    return result;
  }

  String writeOrderedList(OrderedList list) {
    String result = "";
    int index = list.startIndex;
    list.items.forEach((ListItem listItem) {
      String pad;
      String contents = writeBlocks(listItem.contents, tight: list.tight);
      contents = contents.splitMapJoin("\n", onNonMatch: (String str) {
        if (pad == null) {
          String marker = index.toString() + list.indexSeparator.char + " ";
          pad = " " * marker.length;
          return marker + str;
        } else if (str != "") {
          return pad + str;
        }
        return str;
      });
      if (!list.tight) {
        contents += '\n';
      }
      result += contents;
    });
    if (!list.tight) {
      result += '\n';
    }
    return result;
  }

  String writeInlines(Iterable<Inline> inlines) {
    return inlines.map((Inline inline) {
      if (inline is Str) {
        return escapeString(inline.contents);
      } else if (inline is Space) {
        return ' ';
      } else if (inline is NonBreakableSpace) {
        return '&nbsp;';
      } else if (inline is LineBreak) {
        return '\\\n';
      } else if (inline is Emph) {
        return writeEmph(inline);
      } else if (inline is Strong) {
        return writeStrong(inline);
      } else if (inline is Link) {
        return writeLink(inline);
      } else if (inline is Image) {
        return writeImage(inline);
      } else if (inline is Code) {
        return writeCodeInline(inline);
      } else if (inline is RawInline) {
        return inline.contents;
      }

      throw new UnimplementedError(inline.toString());
    }).join();
  }

  RegExp escapedChars = new RegExp(r'[!\"#\$%&' r"'()*+,-./:;<=>?@\[\\\]^_`{|}~]");
  String escapeString(String str) => str.replaceAllMapped(escapedChars, (Match m) => r"\" + m.group(0));

  String writeCodeInline(Code code) {
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
    return fence + contents + fence;
  }

  String writeEmph(Emph emph) {
    return '*${writeInlines(emph.contents)}*';
  }

  String writeStrong(Strong strong) {
    return '**${writeInlines(strong.contents)}**';
  }

  String writeLink(Link link) {
    String inlines = writeInlines(link.label);
    if (link is InlineLink) {
      return '[${inlines}](${_writeTarget(link.target)})';
    }
    if (link is ReferenceLink) {
      _references[link.reference] = link.target;
      return '[${inlines}]' + (inlines.toUpperCase() != link.reference.toUpperCase() ? '[${link.reference}]' : '');
    }

    // Autolink
    if (link.label.length > 0 && link.label[0] is Str) {
      return '<' + link.label[0].contents + '>';
    }
    return '<' + link.target.link + '>';
  }

  String writeImage(Image image) {
    return '![${writeInlines(image.label)}](${_writeTarget(image.target)})';
  }

  String _writeReferences() {
    String result = "";
    _references.forEach((String ref, Target target) {
      result += '[$ref]: ${_writeTarget(target)}\n';
    });

    return result;
  }

  String _writeTarget(Target target) {
    String result;

    if (target.link.contains(' ') && !target.link.contains(r'[<>]')) {
      result = '<' + target.link + '>';
    } else {
      result = escapeString(target.link);
    }

    if (target.title != null) {
      result += ' "${escapeString(target.title)}"';
    }
    return result;

  }


  static MarkdownWriter DEFAULT = new MarkdownWriter();
}
