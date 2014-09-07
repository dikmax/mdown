library markdown.htmlWriter;

import 'markdown.dart';

String write(Document document) => writeBlocks(document.blocks);

String writeAttributes(Attr attr) => (attr.id == '' ? '' : ' id="${attr.id}"') + // TODO escaping
  (attr.classes.length > 0 ? ' class="${attr.classes.join(' ')}"' : '') +
  _writeAttr(attr.attributes);

String _writeAttr(Map<String, String> attr) {
  List<String> res = [];
  attr.forEach((k, v) {
    res.add(' $k="$v"'); // TODO escaping
  });
  return res.join();
}

// TODO ListNumberDelim
// TODO ListNumberStyle
// TODO ListAttributes (start, numberStyle, numberDelim)

String writeBlocks(Iterable<Block> blocks) => blocks.map((Block block) {
  if (block is Plain) {
    return writePlain(block);
  } else if (block is Para) {
    return writePara(block);
  } else if (block is CodeBlock) {
    return writeCodeBlock(block);
  } else if (block is BulletList) {
    return writeBulletList(block);
  } else if (block is Header) {
    return writeHeader(block);
  } else if (block is HorizontalRule) {
    return '<hr/>\n';
  }
  throw new UnimplementedError(block.toString());
}).join();

String writePlain(Plain plain) => writeInlines(plain.inlines);

String writePara(Para para) => "<p>${writeInlines(para.inlines)}</p>\n";

String writeCodeBlock(CodeBlock codeBlock) => "<pre${writeAttributes(codeBlock.attr)}><code>${codeBlock.code}</code></pre>\n";

// TODO writeRawBlock(format, data)
// TODO writeBlockQuote(blocks)
// TODO writeOrderedList(attributes, items)

String writeListItem(Iterable<Block> blocks) => "<li>${writeBlocks(blocks)}</li>\n";
String writeBulletList(BulletList list) => "<ul>\n" + list.items.map(writeListItem).join() + "</ul>\n";

// TODO writeDefinition(term, definition)
// TODO writeDefinitionList(items)

String writeHeader(Header header) => "<h${header.level}${writeAttributes(header.attributes)}>${writeInlines(header.inlines)}</h${header.level}>\n";

// TODO writeDiv(attributes, blocks)

String writeInlines(Iterable<Inline> inlines) => inlines.map((Inline inline) {
  if (inline is Str) {
    return writeStr(inline);
  } else if (inline is Emph) {
    return writeEmph(inline);
  } else if (inline is Strong) {
    return writeStrong(inline);
  } else if (inline is Strikeout) {
    return writeStrikeout(inline);
  } else if (inline is Superscript) {
    return writeSuperscript(inline);
  } else if (inline is Subscript) {
    return writeSubscript(inline);
  } else if (inline is Code) {
    return writeCode(inline);
  } else if (inline is Space) {
    return ' ';
  } else if (inline is NonBreakableSpace) {
    return '&nbsp;';
  } else if (inline is LineBreak) {
    return '<br/>';
  }
  throw new UnimplementedError(inline.toString());
}).join();

String writeStr(Str str) => str.str;

String writeEmph(Emph emph) => '<em>${writeInlines(emph.inlines)}</em>';

String writeStrong(Strong strong) => '<strong>${writeInlines(strong.inlines)}</strong>';

String writeStrikeout(Strikeout strikeout) => '<s>${writeInlines(strikeout.inlines)}</s>';

String writeSuperscript(Superscript superscript) => '<sup>${writeInlines(superscript.inlines)}</sup>';

String writeSubscript(Subscript subscript) => '<sub>${writeInlines(subscript.inlines)}</sub>';


// TODO writeQuoted(type, inlines)
// TODO writeCitation(id, prefix, suffix, mode, noteNum, hash)
// TODO writeCite(citations, inlines)

String writeCode(Code code) => "<code${writeAttributes(code.attributes)}>${code.code}</code>";

// TODO writeMath(type, string)
// TODO writeRawInline(format, data)
// TODO writeTarget(url, title)
// TODO writeLink(target, inlines)
// TODO writeImage(target, inlines)
// TODO writeNote(blocks)
// TODO writeSpan(attributes, inlines)
