library md_proc.definitions;

import 'dart:collection';
import 'package:collection/collection.dart';

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


// TODO link type: with or without <>
// TODO title delimiters ", ' or ()
class Target {
  String link;
  String title;

  Target(this.link, this.title);

  String toString() => 'Target "${link}" ${title == null ? "null" : "\"${title}\""}';

  bool operator== (obj) => obj is Target &&
    link == obj.link && title == obj.title;
}


// Blocks

abstract class Block {

}


// TODO char type, distace between chars, chars count
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
  AtxHeader.h1(Inlines contents) : super(1, contents);
  AtxHeader.h2(Inlines contents) : super(2, contents);
  AtxHeader.h3(Inlines contents) : super(3, contents);
  AtxHeader.h4(Inlines contents) : super(4, contents);
  AtxHeader.h5(Inlines contents) : super(5, contents);
  AtxHeader.h6(Inlines contents) : super(6, contents);

  String toString() => "AtxHeader $level $contents";

  bool operator== (obj) => obj is AtxHeader &&
    level == obj.level &&
    _iterableEquality.equals(contents, obj.contents);
}


class SetextHeader extends Header {
  SetextHeader(int level, Inlines contents) : super(level, contents);
  SetextHeader.h1(Inlines contents) : super(1, contents);
  SetextHeader.h2(Inlines contents) : super(2, contents);

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
  FencedCodeBlock(String contents, {this.fenceType: FenceType.BacktickFence, this.fenceSize: 3, Attr attributes})
    : super(contents, attributes == null ? new EmptyAttr() : attributes);

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
  static const BulletType MinusBullet = const BulletType._(0, "MinusBullet", "-");
  static const BulletType PlusBullet = const BulletType._(1, "PlusBullet", "+");
  static const BulletType StarBullet = const BulletType._(2, "StarBullet", "*");

  final int value;
  final String name;
  final String char;

  const BulletType._(this.value, this.name, this.char);

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
  static const IndexSeparator DotSeparator = const IndexSeparator._(0, "DotSeparator", ".");
  static const IndexSeparator ParenthesisSeparator = const IndexSeparator._(1, "ParenthesisSeparator", ")");

  final int value;
  final String name;
  final String char;

  const IndexSeparator._(this.value, this.name, this.char);

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
  bool tight;
  Iterable<ListItem> items;

  ListBlock(this.items, this.tight);
}


class UnorderedList extends ListBlock {
  BulletType bulletType;

  UnorderedList(Iterable<ListItem> items, {this.bulletType: BulletType.MinusBullet, bool tight: false})
    : super(items, tight);

  String toString() => "UnorderedList $bulletType $items";

  bool operator== (obj) => obj is UnorderedList &&
    bulletType == obj.bulletType &&
    tight == obj.tight &&
    _iterableEquality.equals(items, obj.items);
}


class OrderedList extends ListBlock {
  IndexSeparator indexSeparator;
  int startIndex;

  OrderedList(Iterable<ListItem> items, {bool tight: false,
      this.indexSeparator: IndexSeparator.DotSeparator, this.startIndex: 1}) : super(items, tight);

  String toString() => "OrderedList start=$startIndex $indexSeparator $items";

  bool operator== (obj) => obj is OrderedList &&
    indexSeparator == obj.indexSeparator &&
    tight == obj.tight &&
    startIndex == obj.startIndex &&
    _iterableEquality.equals(items, obj.items);
}


class Para extends Block {
  Inlines contents;

  Para(this.contents);

  String toString() => "Para $contents";

  bool operator== (obj) => obj is Para &&
    _iterableEquality.equals(contents, obj.contents);
}


// Inlines

class Inlines extends ListBase<Inline> {
  List<Inline> _inlines = new List<Inline>();

  Inlines();

  Inlines.from(Iterable<Inlines> inlines) : _inlines = new List<Inline>.from(inlines);

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


abstract class SmartChar extends Inline {

}


class MDash extends SmartChar {
  static final MDash _instance = new MDash._internal();
  
  factory MDash() {
    return _instance;
  }
  
  MDash._internal();
  
  String toString() => "MDash";
  
  bool operator== (obj) => obj is MDash;
}


class NDash extends SmartChar {
  static final NDash _instance = new NDash._internal();
  
  factory NDash() {
    return _instance;
  }
  
  NDash._internal();
  
  String toString() => "NDash";
  
  bool operator== (obj) => obj is NDash;
}


class Ellipsis extends SmartChar {
  static final Ellipsis _instance = new Ellipsis._internal();
  
  factory Ellipsis() {
    return _instance;
  }
  
  Ellipsis._internal();
  
  String toString() => "Ellipsis";
  
  bool operator== (obj) => obj is Ellipsis;
}


class SmartQuote extends Inline {
  bool single;
  bool open;
  bool close;

  Inlines contents;

  SmartQuote(this.contents, {this.single, this.open: true, this.close: true});

  String toString() => 'SmartQuote ' +
    (single
      ? "${open ? "'" : ""}$contents${close ? "'" : ""}"
      : "${open ? '"' : ""}$contents${close ? '"' : ""}");

  bool operator== (obj) => obj is SmartQuote &&
    single == obj.single &&
    open == obj.open &&
    close == obj.close &&
    _iterableEquality.equals(contents, obj.contents);
}


class Code extends Inline {
  String contents;
  int fenceSize;

  Code(this.contents, {this.fenceSize: 1});

  String toString() => 'Code "$contents"';

  bool operator== (obj) => obj is Code &&
    contents == obj.contents &&
    fenceSize == obj.fenceSize;
}


class Emph extends Inline {
  Inlines contents;

  Emph(this.contents);

  String toString() => 'Emph $contents';

  bool operator== (obj) => obj is Emph &&
    _iterableEquality.equals(contents, obj.contents);
}


class Strong extends Inline {
  Inlines contents;

  Strong(this.contents);

  String toString() => 'Strong $contents';

  bool operator== (obj) => obj is Strong &&
    _iterableEquality.equals(contents, obj.contents);
}


abstract class Link extends Inline {
  Inlines label;
  Target target;

  Link(this.label, this.target);
}


class InlineLink extends Link {
  InlineLink(Inlines label, Target target) : super(label, target);

  String toString() => 'InlineLink $label ($target)';

  bool operator== (obj) => obj is InlineLink &&
    target == obj.target &&
    _iterableEquality.equals(label, obj.label);
}


class ReferenceLink extends Link {
  String reference;

  ReferenceLink(this.reference, Inlines label, Target target) : super(label, target);

  String toString() => 'ReferenceLink[$reference] $label ($target)';

  bool operator== (obj) => obj is ReferenceLink &&
    reference == obj.reference &&
    target == obj.target &&
    _iterableEquality.equals(label, obj.label);
}


class Autolink extends Link {
  Autolink(String link) : super(new Inlines.from([new Str(link)]), new Target(link, null));
  Autolink.email(String email) : super(new Inlines.from([new Str(email)]), new Target("mailto:" + email, null));

  String toString() => 'Autolink (${target.link})';

  bool operator== (obj) => obj is Autolink &&
    target == obj.target;
}


abstract class Image extends Inline {
  Inlines label;
  Target target;

  Image(this.label, this.target);
}


class InlineImage extends Image {
  InlineImage(Inlines label, Target target) : super(label, target);

  String toString() => 'InlineImage $label ($target)';

  bool operator== (obj) => obj is InlineImage &&
    target == obj.target &&
    _iterableEquality.equals(label, obj.label);
}


class ReferenceImage extends Image {
  String reference;

  ReferenceImage(this.reference, Inlines label, Target target) : super(label, target);

  String toString() => 'ReferenceImage[$reference] $label ($target)';

  bool operator== (obj) => obj is ReferenceImage &&
    reference == obj.reference &&
    target == obj.target &&
    _iterableEquality.equals(label, obj.label);
}


abstract class RawInline extends Inline {
  String contents;

  RawInline(this.contents);
}


class HtmlRawInline extends RawInline {
  HtmlRawInline(String contents) : super(contents);

  String toString() => "HtmlRawInline $contents";

  bool operator== (obj) => obj is HtmlRawInline &&
    contents == obj.contents;
}
