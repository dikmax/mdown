library markdown.htmlWriter;

import 'markdown.dart';

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
String writeBlocks(Iterable<Block> blocks) => blocks.map((Block block) {
  if (block is HorizontalRule) {
    return '<hr/>';
  } else if (block is Header) {
    return writeHeader(block);
  } else if (block is CodeBlock) {
    return writeCodeBlock(block);
  } else if (block is RawBlock) {
    return block.contents;
  } else if (block is Para) {
    return writePara(block);
  }
  throw new UnimplementedError(block.toString());
}).join('\n');

String writeHeader(Header header) => "<h${header.level}>${writeInlines(header.contents)}</h${header.level}>";

String writeCodeBlock(CodeBlock codeBlock) => "<pre><code${writeAttributes(codeBlock.attributes)}>" +
  "${codeBlock.contents}</code></pre>";

String writePara(Para para) => "<p>${writeInlines(para.contents)}</p>";

// Inlines
String writeInlines(Iterable<Inline> inlines) {
  // TODO remove raw check
  if (inlines.raw != null) {
    return inlines.raw;
  }
  return inlines.map((Inline inline) {
    if (inline is Str) {
      return inline.contents;
    } else if (inline is Space) {
      return ' ';
    } else if (inline is NonBreakableSpace) {
      return '&nbsp;';
    } else if (inline is LineBreak) {
      return '<br/>';
    }
    throw new UnimplementedError(inline.toString());
  }).join();
}
