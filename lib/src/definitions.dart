part of markdown;

// Class system is inspired by Pandoc

const _iterableEquality = const IterableEquality();
const _mapEquality = const MapEquality();
const _deepEquality = const DeepCollectionEquality();


class Document {
  Iterable<Block> contents;

  Document(this.contents);

  String toString() => "Document $contents";

  bool operator== (obj) => obj is Document &&
    _iterableEquality.equals(contents, obj.contents);
}


abstract class Attr {

}


class EmptyAttr extends Attr {
  static final EmptyAttr _instance = new EmptyAttr._internal();

  factory EmptyAttr() {
    return _instance;
  }

  EmptyAttr._internal();

  String toString() => "EmptyAttr";

  bool operator== (obj) => obj is EmptyAttr;
}


class InfoString extends Attr {
  String language;

  InfoString(this.language);

  String toString() => "InfoString($language)";

  bool operator== (obj) => obj is InfoString &&
    language == obj.language;
}


// Blocks

abstract class Block {

}


class HorizontalRule extends Block {
  static final HorizontalRule _instance = new HorizontalRule._internal();

  factory HorizontalRule() {
    return _instance;
  }

  HorizontalRule._internal();

  String toString() => "HorizontalRule";

  bool operator== (obj) => obj is HorizontalRule;
}


abstract class Header extends Block {
  int level;
  Iterable<Inline> contents;

  Header(this.level, this.contents);
}


class AtxHeader extends Header {
  AtxHeader(int level, Iterable<Inline> contents) : super(level, contents);

  String toString() => "AtxHeader $level $contents";

  bool operator== (obj) => obj is AtxHeader &&
    level == obj.level &&
    _iterableEquality.equals(contents, obj.contents);
}


class SetextHeader extends Header {
  SetextHeader(int level, Iterable<Inline> contents) : super(level, contents);

  String toString() => "SetextHeader $level $contents";

  bool operator== (obj) => obj is SetextHeader &&
    level == obj.level &&
    _iterableEquality.equals(contents, obj.contents);
}


abstract class CodeBlock extends Block {
  String contents;
  Attr attributes;

  CodeBlock(this.contents, this.attributes);
}


class IndentedCodeBlock extends CodeBlock {
  IndentedCodeBlock(String contents) : super(contents, new EmptyAttr());

  String toString() => "IndentedCodeBlock $contents";

  bool operator== (obj) => obj is IndentedCodeBlock &&
    contents == obj.contents;
}


class FencedCodeBlock extends CodeBlock {
  FencedCodeBlock(String contents, Attr attributes) : super(contents, attributes);

  String toString() => "FencedCodeBlock $attributes $contents";

  bool operator== (obj) => obj is FencedCodeBlock &&
    contents == obj.contents &&
    attributes == obj.attributes;
}


abstract class RawBlock extends Block {
  String contents;

  RawBlock(this.contents);
}


class HtmlRawBlock extends RawBlock {
  HtmlRawBlock(String contents) : super(contents);

  String toString() => "HtmlRawBlock $contents";

  bool operator== (obj) => obj is HtmlRawBlock &&
    contents == obj.contents;
}

// Inlines

abstract class Inline {

}


class Str extends Inline {
  String contents;

  Str(this.contents);

  String toString() => 'Str "$contents"';

  bool operator== (obj) => obj is Str &&
    contents == obj.str;
}


class Space extends Inline {
  static final Space _instance = new Space._internal();

  factory Space() {
    return _instance;
  }

  Space._internal();

  String toString() => "Space";

  bool operator== (obj) => obj is Space;
}


class NonBreakableSpace extends Inline {
  static final NonBreakableSpace _instance = new NonBreakableSpace._internal();

  factory NonBreakableSpace() {
    return _instance;
  }

  NonBreakableSpace._internal();

  String toString() => "NonBreakableSpace";

  bool operator== (obj) => obj is NonBreakableSpace;
}


class LineBreak extends Inline {
  static final LineBreak _instance = new LineBreak._internal();

  factory LineBreak() {
    return _instance;
  }

  LineBreak._internal();

  String toString() => "LineBreak";

  bool operator== (obj) => obj is LineBreak;
}
