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


class Target {
  String link;
  String title;

  Target(this.link, this.title);

  String toString() => 'Target "${link}" ${title == null ? "null" : "\"${title}\""}';
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
  Inlines contents;

  Header(this.level, this.contents);
}


class AtxHeader extends Header {
  AtxHeader(int level, Inlines contents) : super(level, contents);

  String toString() => "AtxHeader $level $contents";

  bool operator== (obj) => obj is AtxHeader &&
    level == obj.level &&
    _iterableEquality.equals(contents, obj.contents);
}


class SetextHeader extends Header {
  SetextHeader(int level, Inlines contents) : super(level, contents);

  String toString() => "SetextHeader $level $contents";

  bool operator== (obj) => obj is SetextHeader &&
    level == obj.level &&
    _iterableEquality.equals(contents, obj.contents);
}


class FenceType {
  static const FenceType BacktickFence = const FenceType._(0, "BacktickFence");
  static const FenceType TildeFence = const FenceType._(1, "TildeFence");

  final int value;
  final String name;

  const FenceType._(this.value, this.name);

  String toString() => name;

  bool operator== (obj) => obj is FenceType &&
    value == obj.value;
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
  FenceType fenceType;
  int fenceSize;
  FencedCodeBlock(String contents, this.fenceType, this.fenceSize, Attr attributes) : super(contents, attributes);

  String toString() => "FencedCodeBlock $attributes $contents";

  bool operator== (obj) => obj is FencedCodeBlock &&
    contents == obj.contents &&
    attributes == obj.attributes &&
    fenceType == obj.fenceType &&
    fenceSize == obj.fenceSize;
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


class Blockquote extends Block {
  Iterable<Block> contents;

  Blockquote(this.contents);

  String toString() => "Blockquote $contents";

  bool operator== (obj) => obj is Blockquote &&
    _iterableEquality.equals(contents, obj.contents);
}

class ListItem {
  Iterable<Block> contents;

  ListItem(this.contents);

  String toString() => "ListItem $contents";

  bool operator== (obj) => obj is ListItem &&
    _iterableEquality.equals(contents, obj.contents);
}


class BulletType {
  static const BulletType MinusBullet = const BulletType._(0, "MinusBullet");
  static const BulletType PlusBullet = const BulletType._(1, "PlusBullet");
  static const BulletType StarBullet = const BulletType._(2, "StarBullet");

  final int value;
  final String name;

  const BulletType._(this.value, this.name);

  static BulletType fromChar(markerChar) {
    BulletType type;
    switch(markerChar) {
      case '+':
        type = BulletType.PlusBullet;
        break;

      case '-':
        type = BulletType.MinusBullet;
        break;

      case '*':
        type = BulletType.StarBullet;
        break;

      default:
        assert(false);
        type = BulletType.PlusBullet;
    }

    return type;
  }

  String toString() => name;

  bool operator== (obj) => obj is BulletType &&
    value == obj.value;
}


class IndexSeparator {
  static const IndexSeparator DotSeparator = const IndexSeparator._(0, "DotSeparator");
  static const IndexSeparator ParenthesisSeparator = const IndexSeparator._(1, "ParenthesisSeparator");

  final int value;
  final String name;

  const IndexSeparator._(this.value, this.name);

  static IndexSeparator fromChar(String indexSeparator) {
    IndexSeparator separator;
    switch(indexSeparator) {
      case '.':
        separator = IndexSeparator.DotSeparator;
        break;

      case ')':
        separator = IndexSeparator.ParenthesisSeparator;
        break;

      default:
        assert(false);
        separator = IndexSeparator.DotSeparator;
    }

    return separator;
  }

  String toString() => name;

  bool operator== (obj) => obj is IndexSeparator &&
    value == obj.value;
}

// List class name is already taken by dart
abstract class ListBlock extends Block {
  Iterable<ListItem> items;

  ListBlock(this.items);
}


class UnorderedList extends ListBlock {
  BulletType bulletType;

  UnorderedList(items, this.bulletType) : super(items);

  String toString() => "UnorderedList $bulletType $items";

  bool operator== (obj) => obj is UnorderedList &&
    bulletType == obj.bulletType &&
    _iterableEquality(items, obj.items);
}


class OrderedList extends ListBlock {
  IndexSeparator indexSeparator;
  int startIndex;

  OrderedList(items, this.indexSeparator, this.startIndex) : super(items);

  String toString() => "OrderedList start=$startIndex $indexSeparator $items";

  bool operator== (obj) => obj is OrderedList &&
    indexSeparator == obj.indexSeparator &&
    startIndex == obj.startIndex &&
    _iterableEquality(items, obj.items);
}


class Para extends Block {
  Inlines contents;

  Para(this.contents);

  String toString() => "Para $contents";

  bool operator== (obj) => obj is Para &&
    _iterableEquality.equals(contents, obj.contents);
}


class Plain extends Block {
  Inlines contents;

  Plain(this.contents);

  String toString() => "Plain $contents";

  bool operator== (obj) => obj is Para &&
    _iterableEquality.equals(contents, obj.contents);
}


// Inlines

class Inlines extends ListBase<Inline> {
  List _inlines = new List();

  int get length => _inlines.length;

  void set length(int length) {
    _inlines.length = length;
  }

  void operator[]=(int index, Inline value) {
    _inlines[index] = value;
  }

  Inline operator [](int index) => _inlines[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  void add(Inline value) => _inlines.add(value);

  void addAll(Iterable<Inline> all) => _inlines.addAll(all);
}


abstract class Inline {

}


class Str extends Inline {
  String contents;

  Str(this.contents);

  String toString() => 'Str "$contents"';

  bool operator== (obj) => obj is Str &&
    contents == obj.contents;
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
