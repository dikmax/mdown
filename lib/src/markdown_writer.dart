library md_proc.html_writer;

import 'definitions.dart';

class MarkdownWriter {
  String write(Document document) => writeBlocks(document.contents);

  String writeBlocks(Iterable<Block> blocks) => blocks.map((Block block) {
    if (block is Para) {
      return writePara(block);
    } else if (block is Plain) {
      return writeInlines(block.contents);
    } else if (block is Header) {
      return writeHeader(block);
    } else if (block is HorizontalRule) {
      return writeHorizontalRule(block);
    } else if (block is CodeBlock) {
      return writeCodeBlock(block);
    } else if (block is Blockquote) {
      return writeBlockquote(block);
    } else if (block is RawBlock) {
      return block.contents;
    } else if (block is UnorderedList) {
      return writeUnorderedList(block);
    } else if (block is OrderedList) {
      return writeOrderedList(block);
    }

    throw new UnimplementedError(block.toString());
  }).join("\n\n");

  String writeHorizontalRule(HorizontalRule hRule) {
    return '-' * 10;
  }

  String writePara(Para para) {
    return writeInlines(para.contents);
  }

  String writeBlockquote(Blockquote blockquote) => "> ${writeBlocks(blockquote.contents)}";

  String writeHeader(Header header) {
    String inlines = writeInlines(header.contents);
    if (header is SetextHeader && header.level == 2) {
      return inlines + "\n" + (header.level == 1 ? '=' : '-') * inlines.length;
    }
    return "#" * header.level + " " + inlines;
  }

  String writeCodeBlock(CodeBlock codeBlock) => "```\n" + codeBlock.contents + "```\n";

  String writeListItems(Iterable<ListItem> items) => items.map((ListItem item) =>
    "* " + writeBlocks(item.contents)).join();
  String writeUnorderedList(UnorderedList list) => "${writeListItems(list.items)}";
  String writeOrderedList(OrderedList list) => "${writeListItems(list.items)}";

  String writeInlines(Iterable<Inline> inlines) {
    return inlines.map((Inline inline) {
      if (inline is Str) {
        return inline.contents;
      } else if (inline is Space) {
        return ' ';
      } else if (inline is NonBreakableSpace) {
        return '&nbsp;';
      } else if (inline is LineBreak) {
        return '<br/>\n';
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

  String writeCodeInline(Code code) {
    return '`'*code.fenceSize + code.contents + '`'*code.fenceSize;
  }

  String writeEmph(Emph emph) {
    return '*${writeInlines(emph.contents)}*';
  }

  String writeStrong(Strong strong) {
    return '**${writeInlines(strong.contents)}**';
  }

  String writeLink(Link link) {
    return '[${writeInlines(link.label)}](${link.target.link})';
  }

  String writeImage(Image image) {
    return '![${writeInlines(image.label)}](${image.target.link})';
  }

  static MarkdownWriter DEFAULT = new MarkdownWriter();
}
