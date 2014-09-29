library markdown.htmlWriter;

import 'markdown.dart';
import 'dart:convert';

RegExp _escapedChars = new RegExp(r'[<>&"]');
Map<String, String> _escape = <String, String>{
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "&": "&amp;"
};
String htmlEscape(String str) => str.replaceAllMapped(_escapedChars, (Match match) => _escape[match.group(0)]);

String write(Document document) => writeBlocks(document.contents);

String writeAttributes(Attr attr) {
  if (attr is EmptyAttr) {
    return '';
  } else if (attr is InfoString) {
    if (attr.language == "") {
      return '';
    }
    return ' class="language-${attr.language}"';
  }
  throw new UnimplementedError(attr.toString());
}

// Blocks
String writeBlocks(Iterable<Block> blocks) => writeBlocks_(blocks).map((item) => item + "\n").join();

String writeBlocksTight(Iterable<Block> blocks) => writeBlocks_(blocks).join('\n');

Iterable<String> writeBlocks_(Iterable<Block> blocks) => blocks.map((Block block) {
  if (block is Para) {
    return writePara(block);
  } else if (block is Plain) {
    return writePlain(block);
  } else if (block is Header) {
    return writeHeader(block);
  } else if (block is HorizontalRule) {
    return '<hr/>';
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
});

String writeBlockquote(Blockquote blockquote) => "<blockquote>\n${writeBlocks(blockquote.contents)}</blockquote>";

String writeHeader(Header header) => "<h${header.level}>${writeInlines(header.contents)}</h${header.level}>";

String writeCodeBlock(CodeBlock codeBlock) => "<pre><code${writeAttributes(codeBlock.attributes)}>" +
  "${htmlEscape(codeBlock.contents)}</code></pre>";

String writeListItems(Iterable<ListItem> items) => items.map((ListItem item) => "<li>${writeBlocksTight(item.contents).trim()}</li>\n").join();
String writeUnorderedList(UnorderedList list) => "<ul>\n${writeListItems(list.items)}</ul>";
String writeOrderedList(OrderedList list) => "<ol${list.startIndex != 1 ? ' start="${list.startIndex}"' : ''}>\n${writeListItems(list.items)}</ol>";

String writePara(Para para) => "<p>${writeInlines(para.contents)}</p>";
String writePlain(Plain plain) => writeInlines(plain.contents);

// Inlines
String writeInlines(Iterable<Inline> inlines) {
  return inlines.map((Inline inline) {
    if (inline is Str) {
      return htmlEscape(inline.contents);
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
  return '<code>${htmlEscape(code.contents)}</code>';
}

String writeEmph(Emph emph) {
  return '<em>${writeInlines(emph.contents)}</em>';
}

String writeStrong(Strong strong) {
  return '<strong>${writeInlines(strong.contents)}</strong>';
}

String writeLink(Link link) {
  return '<a href="${Uri.encodeFull(htmlEscape(link.target.link))}"' +
    (link.target.title != null ? ' title="${htmlEscape(link.target.title)}"' : '') +
    ">${writeInlines(link.label)}</a>";
}

String writeImage(Image image) {
  return '<img src="${Uri.encodeFull(htmlEscape(image.target.link))}" alt="${htmlEscape(writeInlines(image.label))}"' +
  (image.target.title != null ? ' title="${htmlEscape(image.target.title)}"' : '') +
  " />";
}