library md_proc.definitions;

import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

// Class system is inspired by Pandoc

const IterableEquality _iterableEquality = const IterableEquality();
const MapEquality _mapEquality = const MapEquality();
const DeepCollectionEquality _deepEquality = const DeepCollectionEquality();

class Document {
  Iterable<Block> contents;

  Document(this.contents);

  String toString() => "Document $contents";

  bool operator ==(dynamic obj) =>
      obj is Document && _iterableEquality.equals(contents, obj.contents);

  int get hashCode => contents.hashCode;
}

abstract class Attr {}

class EmptyAttr extends Attr {
  static final EmptyAttr _instance = new EmptyAttr._internal();

  factory EmptyAttr() {
    return _instance;
  }

  EmptyAttr._internal();

  String toString() => "EmptyAttr";

  bool operator ==(dynamic obj) => obj is EmptyAttr;

  int get hashCode => 0;
}

class InfoString extends Attr {
  String language;

  InfoString(this.language);

  String toString() => "InfoString($language)";

  bool operator ==(dynamic obj) =>
      obj is InfoString && language == obj.language;

  int get hashCode => language.hashCode;
}

// TODO link type: with or without <>
// TODO title delimiters ", ' or ()
class Target {
  String link;
  String title;

  Target(this.link, this.title);

  String toString() =>
      'Target "$link" ${title == null ? "null" : "\"$title\""}';

  bool operator ==(dynamic obj) =>
      obj is Target && link == obj.link && title == obj.title;

  int get hashCode => hash2(link, title);
}

// Blocks

abstract class Block {}

// TODO char type, distance between chars, chars count
class HorizontalRule extends Block {
  static final HorizontalRule _instance = new HorizontalRule._internal();

  factory HorizontalRule() {
    return _instance;
  }

  HorizontalRule._internal();

  String toString() => "HorizontalRule";

  bool operator ==(dynamic obj) => obj is HorizontalRule;

  int get hashCode => 0;
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

  bool operator ==(dynamic obj) => obj is AtxHeader &&
      level == obj.level &&
      _iterableEquality.equals(contents, obj.contents);

  int get hashCode => hash2(level, contents);
}

class SetextHeader extends Header {
  SetextHeader(int level, Inlines contents) : super(level, contents);
  SetextHeader.h1(Inlines contents) : super(1, contents);
  SetextHeader.h2(Inlines contents) : super(2, contents);

  String toString() => "SetextHeader $level $contents";

  bool operator ==(dynamic obj) => obj is SetextHeader &&
      level == obj.level &&
      _iterableEquality.equals(contents, obj.contents);

  int get hashCode => hash2(level, contents);
}

class FenceType {
  static const FenceType backtick = const FenceType._(0, "backtick");
  static const FenceType tilde = const FenceType._(1, "tilde");

  final int value;
  final String name;

  const FenceType._(this.value, this.name);

  String toString() => name;

  bool operator ==(dynamic obj) => obj is FenceType && value == obj.value;

  int get hashCode => value.hashCode;
}

abstract class CodeBlock extends Block {
  String contents;
  Attr attributes;

  CodeBlock(this.contents, this.attributes);
}

class IndentedCodeBlock extends CodeBlock {
  IndentedCodeBlock(String contents) : super(contents, new EmptyAttr());

  String toString() => "IndentedCodeBlock $contents";

  bool operator ==(dynamic obj) =>
      obj is IndentedCodeBlock && contents == obj.contents;

  int get hashCode => contents.hashCode;
}

class FencedCodeBlock extends CodeBlock {
  FenceType fenceType;
  int fenceSize;
  FencedCodeBlock(String contents,
      {this.fenceType: FenceType.backtick, this.fenceSize: 3, Attr attributes})
      : super(contents, attributes == null ? new EmptyAttr() : attributes);

  String toString() => "FencedCodeBlock $attributes $contents";

  bool operator ==(dynamic obj) => obj is FencedCodeBlock &&
      contents == obj.contents &&
      attributes == obj.attributes &&
      fenceType == obj.fenceType &&
      fenceSize == obj.fenceSize;

  int get hashCode => hash4(contents, attributes, fenceType, fenceSize);
}

abstract class RawBlock extends Block {
  String contents;

  RawBlock(this.contents);
}

class HtmlRawBlock extends RawBlock {
  HtmlRawBlock(String contents) : super(contents);

  String toString() => "HtmlRawBlock $contents";

  bool operator ==(dynamic obj) =>
      obj is HtmlRawBlock && contents == obj.contents;

  int get hashCode => contents.hashCode;
}

class Blockquote extends Block {
  Iterable<Block> contents;

  Blockquote(this.contents);

  String toString() => "Blockquote $contents";

  bool operator ==(dynamic obj) =>
      obj is Blockquote && _iterableEquality.equals(contents, obj.contents);

  int get hashCode => contents.hashCode;
}

class ListItem {
  Iterable<Block> contents;

  ListItem(this.contents);

  String toString() => "ListItem $contents";

  bool operator ==(dynamic obj) =>
      obj is ListItem && _iterableEquality.equals(contents, obj.contents);

  int get hashCode => contents.hashCode;
}

class BulletType {
  static const BulletType minus = const BulletType._(0, "minus", "-");
  static const BulletType plus = const BulletType._(1, "plus", "+");
  static const BulletType star = const BulletType._(2, "star", "*");

  final int value;
  final String name;
  final String char;

  const BulletType._(this.value, this.name, this.char);

  static BulletType fromChar(String markerChar) {
    BulletType type;
    switch (markerChar) {
      case '+':
        type = BulletType.plus;
        break;

      case '-':
        type = BulletType.minus;
        break;

      case '*':
        type = BulletType.star;
        break;

      default:
        assert(false);
        type = BulletType.plus;
    }

    return type;
  }

  String toString() => name;

  bool operator ==(dynamic obj) => obj is BulletType && value == obj.value;

  int get hashCode => value.hashCode;
}

class IndexSeparator {
  static const IndexSeparator dot = const IndexSeparator._(0, "dot", ".");
  static const IndexSeparator parenthesis =
      const IndexSeparator._(1, "parenthesis", ")");

  final int value;
  final String name;
  final String char;

  const IndexSeparator._(this.value, this.name, this.char);

  static IndexSeparator fromChar(String indexSeparator) {
    IndexSeparator separator;
    switch (indexSeparator) {
      case '.':
        separator = IndexSeparator.dot;
        break;

      case ')':
        separator = IndexSeparator.parenthesis;
        break;

      default:
        assert(false);
        separator = IndexSeparator.dot;
    }

    return separator;
  }

  String toString() => name;

  bool operator ==(dynamic obj) => obj is IndexSeparator && value == obj.value;

  int get hashCode => value.hashCode;
}

// List class name is already taken by dart
abstract class ListBlock extends Block {
  bool tight;
  Iterable<ListItem> items;

  ListBlock(this.items, this.tight);
}

class UnorderedList extends ListBlock {
  BulletType bulletType;

  UnorderedList(Iterable<ListItem> items,
      {this.bulletType: BulletType.minus, bool tight: false})
      : super(items, tight);

  String toString() => "UnorderedList $bulletType $items";

  bool operator ==(dynamic obj) => obj is UnorderedList &&
      bulletType == obj.bulletType &&
      tight == obj.tight &&
      _iterableEquality.equals(items, obj.items);

  int get hashCode => hash3(bulletType, tight, items);
}

class OrderedList extends ListBlock {
  IndexSeparator indexSeparator;
  int startIndex;

  OrderedList(Iterable<ListItem> items,
      {bool tight: false,
      this.indexSeparator: IndexSeparator.dot,
      this.startIndex: 1})
      : super(items, tight);

  String toString() => "OrderedList start=$startIndex $indexSeparator $items";

  bool operator ==(dynamic obj) => obj is OrderedList &&
      indexSeparator == obj.indexSeparator &&
      tight == obj.tight &&
      startIndex == obj.startIndex &&
      _iterableEquality.equals(items, obj.items);

  int get hashCode => hash4(indexSeparator, tight, startIndex, items);
}

class Para extends Block {
  Inlines contents;

  Para(this.contents);

  String toString() => "Para $contents";

  bool operator ==(dynamic obj) =>
      obj is Para && _iterableEquality.equals(contents, obj.contents);

  int get hashCode => contents.hashCode;
}

// Inlines

class Inlines extends ListBase<Inline> {
  List<Inline> _inlines = new List<Inline>();

  Inlines();

  Inlines.from(Iterable<Inline> inlines)
      : _inlines = new List<Inline>.from(inlines);

  int get length => _inlines.length;

  void set length(int length) {
    _inlines.length = length;
  }

  void operator []=(int index, Inline value) {
    _inlines[index] = value;
  }

  Inline operator [](int index) => _inlines[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  void add(Inline value) => _inlines.add(value);

  void addAll(Iterable<Inline> all) => _inlines.addAll(all);
}

abstract class Inline {}

class Str extends Inline {
  String contents;

  Str(this.contents);

  String toString() => 'Str "$contents"';

  bool operator ==(dynamic obj) => obj is Str && contents == obj.contents;

  int get hashCode => contents.hashCode;
}

class Space extends Inline {
  static final Space _instance = new Space._internal();

  factory Space() {
    return _instance;
  }

  Space._internal();

  String toString() => "Space";

  bool operator ==(dynamic obj) => obj is Space;

  int get hashCode => 0;
}

class Tab extends Inline {
  static final Tab _instance = new Tab._internal();

  factory Tab() {
    return _instance;
  }

  Tab._internal();

  String toString() => "Tab";

  bool operator ==(dynamic obj) => obj is Tab;

  int get hashCode => 0;
}

class NonBreakableSpace extends Inline {
  static final NonBreakableSpace _instance = new NonBreakableSpace._internal();

  factory NonBreakableSpace() {
    return _instance;
  }

  NonBreakableSpace._internal();

  String toString() => "NonBreakableSpace";

  bool operator ==(dynamic obj) => obj is NonBreakableSpace;

  int get hashCode => 0;
}

class LineBreak extends Inline {
  static final LineBreak _instance = new LineBreak._internal();

  factory LineBreak() {
    return _instance;
  }

  LineBreak._internal();

  String toString() => "LineBreak";

  bool operator ==(dynamic obj) => obj is LineBreak;

  int get hashCode => 0;
}

abstract class SmartChar extends Inline {}

class MDash extends SmartChar {
  static final MDash _instance = new MDash._internal();

  factory MDash() {
    return _instance;
  }

  MDash._internal();

  String toString() => "MDash";

  bool operator ==(dynamic obj) => obj is MDash;

  int get hashCode => 0;
}

class NDash extends SmartChar {
  static final NDash _instance = new NDash._internal();

  factory NDash() {
    return _instance;
  }

  NDash._internal();

  String toString() => "NDash";

  bool operator ==(dynamic obj) => obj is NDash;

  int get hashCode => 0;
}

class Ellipsis extends SmartChar {
  static final Ellipsis _instance = new Ellipsis._internal();

  factory Ellipsis() {
    return _instance;
  }

  Ellipsis._internal();

  String toString() => "Ellipsis";

  bool operator ==(dynamic obj) => obj is Ellipsis;

  int get hashCode => 0;
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

  bool operator ==(dynamic obj) => obj is SmartQuote &&
      single == obj.single &&
      open == obj.open &&
      close == obj.close &&
      _iterableEquality.equals(contents, obj.contents);

  int get hashCode => hash4(single, open, close, contents);
}

class Code extends Inline {
  String contents;
  int fenceSize;

  Code(this.contents, {this.fenceSize: 1});

  String toString() => 'Code "$contents"';

  bool operator ==(dynamic obj) =>
      obj is Code && contents == obj.contents && fenceSize == obj.fenceSize;

  int get hashCode => hash2(contents, fenceSize);
}

class Emph extends Inline {
  Inlines contents;

  Emph(this.contents);

  String toString() => 'Emph $contents';

  bool operator ==(dynamic obj) =>
      obj is Emph && _iterableEquality.equals(contents, obj.contents);

  int get hashCode => contents.hashCode;
}

class Strong extends Inline {
  Inlines contents;

  Strong(this.contents);

  String toString() => 'Strong $contents';

  bool operator ==(dynamic obj) =>
      obj is Strong && _iterableEquality.equals(contents, obj.contents);

  int get hashCode => contents.hashCode;
}

class Strikeout extends Inline {
  Inlines contents;

  Strikeout(this.contents);

  String toString() => 'Strikeout $contents';

  bool operator ==(dynamic obj) =>
      obj is Strikeout && _iterableEquality.equals(contents, obj.contents);

  int get hashCode => contents.hashCode;
}

class Subscript extends Inline {
  Inlines contents;

  Subscript(this.contents);

  String toString() => 'Subscript $contents';

  bool operator ==(dynamic obj) =>
      obj is Subscript && _iterableEquality.equals(contents, obj.contents);

  int get hashCode => contents.hashCode;
}

class Superscript extends Inline {
  Inlines contents;

  Superscript(this.contents);

  String toString() => 'Superscript $contents';

  bool operator ==(dynamic obj) =>
      obj is Superscript && _iterableEquality.equals(contents, obj.contents);

  int get hashCode => contents.hashCode;
}

abstract class Link extends Inline {
  Inlines label;
  Target target;

  Link(this.label, this.target);
}

class InlineLink extends Link {
  InlineLink(Inlines label, Target target) : super(label, target);

  String toString() => 'InlineLink $label ($target)';

  bool operator ==(dynamic obj) => obj is InlineLink &&
      target == obj.target &&
      _iterableEquality.equals(label, obj.label);

  int get hashCode => hash2(target, label);
}

class ReferenceLink extends Link {
  String reference;

  ReferenceLink(this.reference, Inlines label, Target target)
      : super(label, target);

  String toString() => 'ReferenceLink[$reference] $label ($target)';

  bool operator ==(dynamic obj) => obj is ReferenceLink &&
      reference == obj.reference &&
      target == obj.target &&
      _iterableEquality.equals(label, obj.label);

  int get hashCode => hash3(reference, target, label);
}

class Autolink extends Link {
  Autolink(String link)
      : super(new Inlines.from([new Str(link)]), new Target(link, null));
  Autolink.email(String email)
      : super(new Inlines.from([new Str(email)]),
            new Target("mailto:" + email, null));

  String toString() => 'Autolink (${target.link})';

  bool operator ==(dynamic obj) => obj is Autolink && target == obj.target;

  int get hashCode => target.hashCode;
}

abstract class Image extends Inline {
  Inlines label;
  Target target;

  Image(this.label, this.target);
}

class InlineImage extends Image {
  InlineImage(Inlines label, Target target) : super(label, target);

  String toString() => 'InlineImage $label ($target)';

  bool operator ==(dynamic obj) => obj is InlineImage &&
      target == obj.target &&
      _iterableEquality.equals(label, obj.label);

  int get hashCode => hash2(target, label);
}

class ReferenceImage extends Image {
  String reference;

  ReferenceImage(this.reference, Inlines label, Target target)
      : super(label, target);

  String toString() => 'ReferenceImage[$reference] $label ($target)';

  bool operator ==(dynamic obj) => obj is ReferenceImage &&
      reference == obj.reference &&
      target == obj.target &&
      _iterableEquality.equals(label, obj.label);

  int get hashCode => hash3(reference, target, label);
}

abstract class RawInline extends Inline {
  String contents;

  RawInline(this.contents);
}

class HtmlRawInline extends RawInline {
  HtmlRawInline(String contents) : super(contents);

  String toString() => "HtmlRawInline $contents";

  bool operator ==(dynamic obj) =>
      obj is HtmlRawInline && contents == obj.contents;

  int get hashCode => contents.hashCode;
}

abstract class TexMath extends Inline {
  String contents;

  TexMath(this.contents);
}

class TexMathInline extends TexMath {
  TexMathInline(String contents) : super(contents);

  String toString() => "TexMathInline $contents";

  bool operator ==(dynamic obj) =>
      obj is TexMathInline && contents == obj.contents;

  int get hashCode => contents.hashCode;
}

class TexMathDisplay extends TexMath {
  TexMathDisplay(String contents) : super(contents);

  String toString() => "TexMathDisplay $contents";

  bool operator ==(dynamic obj) =>
      obj is TexMathDisplay && contents == obj.contents;

  int get hashCode => contents.hashCode;
}
