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
                     {bool tight: false, String unorderedListChar: "*"}) {
    Block prevBlock = null;

    return blocks.map((Block block) {
      Block _b = prevBlock;
      prevBlock = block;
      if (block is Para) {
        return writePara(block);
      } else if (block is Header) {
        return writeHeader(block);
      } else if (block is HorizontalRule) {
        return writeHorizontalRule(block, unorderedListChar);
      } else if (block is CodeBlock) {
        String result = '';
        if (_b is ListBlock) {
          result = '\n';
        }
        return result + writeCodeBlock(block);
      } else if (block is Blockquote) {
        return writeBlockquote(block);
      } else if (block is RawBlock) {
        return block.contents + "\n";
      } else if (block is UnorderedList) {
        return writeUnorderedList(block, prevBlock: _b);
      } else if (block is OrderedList) {
        return writeOrderedList(block, prevBlock: _b);
      }

      throw new UnimplementedError(block.toString());
    }).join(tight ? "" : "\n");
  }

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

  String writeUnorderedList(UnorderedList list, {Block prevBlock: null}) {
    String result = "";
    if (prevBlock is UnorderedList && prevBlock.bulletType == list.bulletType) {
      result += "\n";
    }

    Iterable<String> items = list.items.map((ListItem listItem) {
      String pad;
      String contents = writeBlocks(listItem.contents, tight: list.tight, unorderedListChar: list.bulletType.char);

      return contents.splitMapJoin("\n", onNonMatch: (String str) {
        if (pad == null) {
          String marker = list.bulletType.char + " ";
          pad = " " * marker.length;
          return marker + str;
        } else if (str != "") {
          return pad + str;
        }
        return str;
      });
    });

    return result + items.join(list.tight ? "" : "\n");
  }

  String writeOrderedList(OrderedList list, {Block prevBlock: null}) {
    String result = "";
    if (prevBlock is OrderedList && prevBlock.indexSeparator == list.indexSeparator) {
      result += "\n";
    }
    int index = list.startIndex;
    Iterable<String> items = list.items.map((ListItem listItem) {
      String pad;
      String contents = writeBlocks(listItem.contents, tight: list.tight);
      return contents.splitMapJoin("\n", onNonMatch: (String str) {
        if (pad == null) {
          String marker = index.toString() + list.indexSeparator.char + " ";
          pad = " " * marker.length;
          return marker + str;
        } else if (str != "") {
          return pad + str;
        }
        return str;
      });
    });

    return result + items.join(list.tight ? "" : "\n");
  }

  String writeInlines(Iterable<Inline> inlines, {String prevEmph, String prevStrong}) {
    if (inlines.length == 1 && prevEmph != null) {
      if (inlines.first is Emph) {
        return writeEmph(inlines.first, delimiter: prevEmph == "*" ? "_" : "*");
      }
      if (inlines.first is Strong) {
        return writeStrong(inlines.first, delimiter: prevEmph == "*" ? "_" : "*");
      }
    }
    StringBuffer result = new StringBuffer();
    Iterator<Inline> it = inlines.iterator;
    int i = 0;
    int last = inlines.length - 1;
    while(it.moveNext()) {
      Inline inline = it.current;
      if (inline is Str) {
        result.write(escapeString(inline.contents));
      } else if (inline is Space) {
        result.write(' ');
      } else if (inline is NonBreakableSpace) {
        result.write('&nbsp;');
      } else if (inline is LineBreak) {
        result.write('\\\n');
      } else if (inline is Emph) {
        result.write(writeEmph(inline));
      } else if (inline is Strong) {
        result.write(writeStrong(inline));
      } else if (inline is Link) {
        result.write(writeLink(inline));
      } else if (inline is Image) {
        result.write(writeImage(inline));
      } else if (inline is Code) {
        result.write(writeCodeInline(inline));
      } else if (inline is RawInline) {
        result.write(inline.contents);
      } else {
        throw new UnimplementedError(inline.toString());
      }

      ++i;
    }

    return result.toString();
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

  String writeEmph(Emph emph, {String delimiter: "*"}) {
    return '${delimiter}${writeInlines(emph.contents, prevEmph: delimiter)}${delimiter}';
  }

  String writeStrong(Strong strong, {String delimiter: "*"}) {
    String delimiterString = delimiter * 2;
    return '${delimiterString}${writeInlines(strong.contents, prevStrong: delimiter)}${delimiterString}';
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
