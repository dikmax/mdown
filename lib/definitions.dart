library md_proc.definitions;

import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

// Class system is inspired by Pandoc

const IterableEquality<dynamic> _iterableEquality =
    const IterableEquality<dynamic>();
const MapEquality<dynamic, dynamic> _mapEquality =
    const MapEquality<dynamic, dynamic>();
const DeepCollectionEquality _deepEquality = const DeepCollectionEquality();

/// Main document object
class Document {
  /// Documents contents
  Iterable<Block> contents;

  /// constructor
  Document(this.contents);

  @override
  String toString() => "Document $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is Document && _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => contents.hashCode;
}

/// Abstract attribute
abstract class Attr {}

/// Empty atttibute
class EmptyAttr extends Attr {
  static final EmptyAttr _instance = new EmptyAttr._internal();

  /// constructor
  factory EmptyAttr() {
    return _instance;
  }

  EmptyAttr._internal();

  @override
  String toString() => "EmptyAttr";

  @override
  bool operator ==(dynamic obj) => obj is EmptyAttr;

  @override
  int get hashCode => 0;
}

/// Infostring attribute
class InfoString extends Attr {
  /// Language attribuge
  String language;

  /// constructor
  InfoString(this.language);

  @override
  String toString() => "InfoString($language)";

  @override
  bool operator ==(dynamic obj) =>
      obj is InfoString && language == obj.language;

  @override
  int get hashCode => language.hashCode;
}

// TODO link type: with or without <>
// TODO title delimiters ", ' or ()
/// Image or link target
class Target {
  /// Target link
  String link;

  /// Target link title
  String title;

  /// Constructor
  Target(this.link, this.title);

  @override
  String toString() =>
      'Target "$link" ${title == null ? "null" : "\"$title\""}';

  @override
  bool operator ==(dynamic obj) =>
      obj is Target && link == obj.link && title == obj.title;

  @override
  int get hashCode => hash2(link, title);
}

// Blocks

/// Abstract block
abstract class Block {}

// TODO char type, distance between chars, chars count
/// Horizontal rule block
class HorizontalRule extends Block {
  static final HorizontalRule _instance = new HorizontalRule._internal();

  /// Constructor
  factory HorizontalRule() {
    return _instance;
  }

  HorizontalRule._internal();

  @override
  String toString() => "HorizontalRule";

  @override
  bool operator ==(dynamic obj) => obj is HorizontalRule;

  @override
  int get hashCode => 0;
}

/// Abstract heading
abstract class Heading extends Block {
  /// Heading level 1—6
  int level;

  /// Heading contents
  Inlines contents;

  /// constructor
  Heading(this.level, this.contents);
}

/// ATX heading block
class AtxHeading extends Heading {
  /// constructor
  AtxHeading(int level, Inlines contents) : super(level, contents);

  /// H1 constructor
  AtxHeading.h1(Inlines contents) : super(1, contents);

  /// H2 constructor
  AtxHeading.h2(Inlines contents) : super(2, contents);

  /// H3 constructor
  AtxHeading.h3(Inlines contents) : super(3, contents);

  /// H4 constructor
  AtxHeading.h4(Inlines contents) : super(4, contents);

  /// H5 constructor
  AtxHeading.h5(Inlines contents) : super(5, contents);

  /// H6 constructor
  AtxHeading.h6(Inlines contents) : super(6, contents);

  @override
  String toString() => "AtxHeading $level $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is AtxHeading &&
      level == obj.level &&
      _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => hash2(level, contents);
}

/// Setext heading block
class SetextHeading extends Heading {
  /// constructor
  SetextHeading(int level, Inlines contents) : super(level, contents);

  /// H1 constructor
  SetextHeading.h1(Inlines contents) : super(1, contents);

  /// H2 constructor
  SetextHeading.h2(Inlines contents) : super(2, contents);

  @override
  String toString() => "SetextHeading $level $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is SetextHeading &&
      level == obj.level &&
      _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => hash2(level, contents);
}

/// Fence type for fenced code block
class FenceType {
  /// `` ` `` fence
  static const FenceType backtick = const FenceType._(0, "backtick");

  /// `~` fence
  static const FenceType tilde = const FenceType._(1, "tilde");

  /// value
  final int value;

  /// name
  final String name;

  /// Constructor
  const FenceType._(this.value, this.name);

  @override
  String toString() => name;

  @override
  bool operator ==(dynamic obj) => obj is FenceType && value == obj.value;

  @override
  int get hashCode => value.hashCode;
}

/// Abstract code block
abstract class CodeBlock extends Block {
  /// Code block contents
  String contents;

  /// Attributes i.e. language of code block
  Attr attributes;

  /// Constructor
  CodeBlock(this.contents, this.attributes);
}

/// Indented code block
class IndentedCodeBlock extends CodeBlock {
  /// Constructor
  IndentedCodeBlock(String contents) : super(contents, new EmptyAttr());

  @override
  String toString() => "IndentedCodeBlock $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is IndentedCodeBlock && contents == obj.contents;

  @override
  int get hashCode => contents.hashCode;
}

/// Fenced code block
class FencedCodeBlock extends CodeBlock {
  /// Fence type `` ` `` or `~`
  FenceType fenceType;

  /// Fence size
  int fenceSize;

  /// Constructor
  FencedCodeBlock(String contents,
      {this.fenceType: FenceType.backtick, this.fenceSize: 3, Attr attributes})
      : super(contents, attributes == null ? new EmptyAttr() : attributes);

  @override
  String toString() => "FencedCodeBlock $attributes $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is FencedCodeBlock &&
      contents == obj.contents &&
      attributes == obj.attributes &&
      fenceType == obj.fenceType &&
      fenceSize == obj.fenceSize;

  @override
  int get hashCode => hash4(contents, attributes, fenceType, fenceSize);
}

/// Abstract raw block
abstract class RawBlock extends Block {
  /// Raw block contents
  String contents;

  /// Constructor
  RawBlock(this.contents);
}

/// HTML raw block
class HtmlRawBlock extends RawBlock {
  /// Constructor
  HtmlRawBlock(String contents) : super(contents);

  @override
  String toString() => "HtmlRawBlock $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is HtmlRawBlock && contents == obj.contents;

  @override
  int get hashCode => contents.hashCode;
}

/// TeX raw block
class TexRawBlock extends RawBlock {
  /// Constructor
  TexRawBlock(String contents) : super(contents);

  @override
  String toString() => "TexRawBlock $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is TexRawBlock && contents == obj.contents;

  @override
  int get hashCode => contents.hashCode;
}

/// Blockquote block
class Blockquote extends Block {
  /// Blockquote contents
  Iterable<Block> contents;

  /// Constructor
  Blockquote(this.contents);

  @override
  String toString() => "Blockquote $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is Blockquote && _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => contents.hashCode;
}

/// List item block
class ListItem {
  /// Item contents
  Iterable<Block> contents;

  /// Constructor
  ListItem(this.contents);

  @override
  String toString() => "ListItem $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is ListItem && _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => contents.hashCode;
}

/// Bullet type for unordered list
class BulletType {
  /// `-` bullet
  static const BulletType minus = const BulletType._(0, "minus", "-");

  /// `+` bullet
  static const BulletType plus = const BulletType._(1, "plus", "+");

  /// `*` bullet
  static const BulletType star = const BulletType._(2, "star", "*");

  /// value
  final int value;

  /// name
  final String name;

  /// char
  final String char;

  /// Constructor
  const BulletType._(this.value, this.name, this.char);

  /// Create from char
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

  @override
  String toString() => name;

  @override
  bool operator ==(dynamic obj) => obj is BulletType && value == obj.value;

  @override
  int get hashCode => value.hashCode;
}

/// Index separator for ordered list
class IndexSeparator {
  /// 1. list
  static const IndexSeparator dot = const IndexSeparator._(0, "dot", ".");

  /// 1) list
  static const IndexSeparator parenthesis =
      const IndexSeparator._(1, "parenthesis", ")");

  /// value
  final int value;

  /// name
  final String name;

  /// char
  final String char;

  /// Constructor
  const IndexSeparator._(this.value, this.name, this.char);

  /// Create from char
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

  @override
  String toString() => name;

  @override
  bool operator ==(dynamic obj) => obj is IndexSeparator && value == obj.value;

  @override
  int get hashCode => value.hashCode;
}

/// abstract list block
abstract class ListBlock extends Block {
  // List class name is already taken by dart

  /// Is list tight, i.e. no paragraphs inside just plain items
  bool tight;

  /// List items
  Iterable<ListItem> items;

  /// Constructor
  ListBlock(this.items, this.tight);
}

/// Unordered list
class UnorderedList extends ListBlock {
  /// Bullet type `+`, `-` or `*`
  BulletType bulletType;

  /// Constructor
  UnorderedList(Iterable<ListItem> items,
      {this.bulletType: BulletType.minus, bool tight: false})
      : super(items, tight);

  @override
  String toString() => "UnorderedList $bulletType $items";

  @override
  bool operator ==(dynamic obj) =>
      obj is UnorderedList &&
      bulletType == obj.bulletType &&
      tight == obj.tight &&
      _iterableEquality.equals(items, obj.items);

  @override
  int get hashCode => hash3(bulletType, tight, items);
}

/// Ordered list
class OrderedList extends ListBlock {
  /// Separator `.` or `)`
  IndexSeparator indexSeparator;

  /// Start index
  int startIndex;

  /// Constructor
  OrderedList(Iterable<ListItem> items,
      {bool tight: false,
      this.indexSeparator: IndexSeparator.dot,
      this.startIndex: 1})
      : super(items, tight);

  @override
  String toString() => "OrderedList start=$startIndex $indexSeparator $items";

  @override
  bool operator ==(dynamic obj) =>
      obj is OrderedList &&
      indexSeparator == obj.indexSeparator &&
      tight == obj.tight &&
      startIndex == obj.startIndex &&
      _iterableEquality.equals(items, obj.items);

  @override
  int get hashCode => hash4(indexSeparator, tight, startIndex, items);
}

/// Paragraph block
class Para extends Block {
  /// Paragraph contents
  Inlines contents;

  /// Constructor
  Para(this.contents);

  @override
  String toString() => "Para $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is Para && _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => contents.hashCode;
}

// Inlines

/// Inlines list
class Inlines extends ListBase<Inline> {
  List<Inline> _inlines = new List<Inline>();

  /// Constructor
  Inlines();

  /// Constructor from
  Inlines.from(Iterable<Inline> inlines)
      : _inlines = new List<Inline>.from(inlines);

  @override
  int get length => _inlines.length;

  @override
  set length(int length) {
    _inlines.length = length;
  }

  @override
  void operator []=(int index, Inline value) {
    _inlines[index] = value;
  }

  @override
  Inline operator [](int index) => _inlines[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  @override
  void add(Inline value) => _inlines.add(value);

  @override
  void addAll(Iterable<Inline> all) => _inlines.addAll(all);
}

/// Abstract inline
abstract class Inline {}

/// String inline
class Str extends Inline {
  /// String contents
  String contents;

  /// Constructor
  Str(this.contents);

  @override
  String toString() => 'Str "$contents"';

  @override
  bool operator ==(dynamic obj) => obj is Str && contents == obj.contents;

  @override
  int get hashCode => contents.hashCode;
}

/// Space inline
class Space extends Inline {
  static final Space _instance = new Space._internal();

  /// Constructor
  factory Space() {
    return _instance;
  }

  Space._internal();

  @override
  String toString() => "Space";

  @override
  bool operator ==(dynamic obj) => obj is Space;

  @override
  int get hashCode => 0;
}

/// Tab inline
class Tab extends Inline {
  static final Tab _instance = new Tab._internal();

  /// Constructor
  factory Tab() {
    return _instance;
  }

  Tab._internal();

  @override
  String toString() => "Tab";

  @override
  bool operator ==(dynamic obj) => obj is Tab;

  @override
  int get hashCode => 0;
}

/// NBSP
class NonBreakableSpace extends Inline {
  static final NonBreakableSpace _instance = new NonBreakableSpace._internal();

  /// Constructor
  factory NonBreakableSpace() {
    return _instance;
  }

  NonBreakableSpace._internal();

  @override
  String toString() => "NonBreakableSpace";

  @override
  bool operator ==(dynamic obj) => obj is NonBreakableSpace;

  @override
  int get hashCode => 0;
}

/// Line break inline
class LineBreak extends Inline {
  static final LineBreak _instance = new LineBreak._internal();

  /// Constructor
  factory LineBreak() {
    return _instance;
  }

  LineBreak._internal();

  @override
  String toString() => "LineBreak";

  @override
  bool operator ==(dynamic obj) => obj is LineBreak;

  @override
  int get hashCode => 0;
}

/// Abstract smart char
abstract class SmartChar extends Inline {}

/// mdash ---
class MDash extends SmartChar {
  static final MDash _instance = new MDash._internal();

  /// Constructor
  factory MDash() {
    return _instance;
  }

  MDash._internal();

  @override
  String toString() => "MDash";

  @override
  bool operator ==(dynamic obj) => obj is MDash;

  @override
  int get hashCode => 0;
}

/// ndash --
class NDash extends SmartChar {
  static final NDash _instance = new NDash._internal();

  /// Constructor
  factory NDash() {
    return _instance;
  }

  NDash._internal();

  @override
  String toString() => "NDash";

  @override
  bool operator ==(dynamic obj) => obj is NDash;

  @override
  int get hashCode => 0;
}

/// Ellipsis char `...`
class Ellipsis extends SmartChar {
  static final Ellipsis _instance = new Ellipsis._internal();

  /// Constructor
  factory Ellipsis() {
    return _instance;
  }

  Ellipsis._internal();

  @override
  String toString() => "Ellipsis";

  @override
  bool operator ==(dynamic obj) => obj is Ellipsis;

  @override
  int get hashCode => 0;
}

/// Smart quote inline
class SmartQuote extends Inline {
  /// Is single (not double)
  bool single;

  /// Have open quote
  bool open;

  /// Have close quote
  bool close;

  /// Inner inlines
  Inlines contents;

  /// Constructor
  SmartQuote(this.contents, {this.single, this.open: true, this.close: true});

  @override
  String toString() =>
      'SmartQuote ' +
      (single
          ? "${open ? "'" : ""}$contents${close ? "'" : ""}"
          : "${open ? '"' : ""}$contents${close ? '"' : ""}");

  @override
  bool operator ==(dynamic obj) =>
      obj is SmartQuote &&
      single == obj.single &&
      open == obj.open &&
      close == obj.close &&
      _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => hash4(single, open, close, contents);
}

/// Code inline
class Code extends Inline {
  /// Code contents
  String contents;

  /// Size of fence
  int fenceSize;

  /// Constructor
  Code(this.contents, {this.fenceSize: 1});

  @override
  String toString() => 'Code "$contents"';

  @override
  bool operator ==(dynamic obj) =>
      obj is Code && contents == obj.contents && fenceSize == obj.fenceSize;

  @override
  int get hashCode => hash2(contents, fenceSize);
}

/// Emphasis inline
class Emph extends Inline {
  /// Inner inlines
  Inlines contents;

  /// Constructor
  Emph(this.contents);

  @override
  String toString() => 'Emph $contents';

  @override
  bool operator ==(dynamic obj) =>
      obj is Emph && _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => contents.hashCode;
}

/// Strong inline
class Strong extends Inline {
  /// Inner inlines
  Inlines contents;

  /// Constructor
  Strong(this.contents);

  @override
  String toString() => 'Strong $contents';

  @override
  bool operator ==(dynamic obj) =>
      obj is Strong && _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => contents.hashCode;
}

/// Strikeout inline
class Strikeout extends Inline {
  /// Inner inlines
  Inlines contents;

  /// Constructor
  Strikeout(this.contents);

  @override
  String toString() => 'Strikeout $contents';

  @override
  bool operator ==(dynamic obj) =>
      obj is Strikeout && _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => contents.hashCode;
}

/// Subscript inline
class Subscript extends Inline {
  /// Inner inlines
  Inlines contents;

  /// Constructor
  Subscript(this.contents);

  @override
  String toString() => 'Subscript $contents';

  @override
  bool operator ==(dynamic obj) =>
      obj is Subscript && _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => contents.hashCode;
}

/// Superscript inline
class Superscript extends Inline {
  /// Inner inlines
  Inlines contents;

  /// Constructor
  Superscript(this.contents);

  @override
  String toString() => 'Superscript $contents';

  @override
  bool operator ==(dynamic obj) =>
      obj is Superscript && _iterableEquality.equals(contents, obj.contents);

  @override
  int get hashCode => contents.hashCode;
}

/// Abstract link inline
abstract class Link extends Inline {
  /// Link label
  Inlines label;

  /// Link target
  Target target;

  /// Constructor
  Link(this.label, this.target);
}

/// Inline link
class InlineLink extends Link {
  /// Constructor
  InlineLink(Inlines label, Target target) : super(label, target);

  @override
  String toString() => 'InlineLink $label ($target)';

  @override
  bool operator ==(dynamic obj) =>
      obj is InlineLink &&
      target == obj.target &&
      _iterableEquality.equals(label, obj.label);

  @override
  int get hashCode => hash2(target, label);
}

/// Reference link
class ReferenceLink extends Link {
  /// Link reference
  String reference;

  /// Constructor
  ReferenceLink(this.reference, Inlines label, Target target)
      : super(label, target);

  @override
  String toString() => 'ReferenceLink[$reference] $label ($target)';

  @override
  bool operator ==(dynamic obj) =>
      obj is ReferenceLink &&
      reference == obj.reference &&
      target == obj.target &&
      _iterableEquality.equals(label, obj.label);

  @override
  int get hashCode => hash3(reference, target, label);
}

/// Autolink inline
class Autolink extends Link {
  /// Constructor
  Autolink(String link)
      : super(new Inlines.from([new Str(link)]), new Target(link, null));

  /// Constructor from email
  Autolink.email(String email)
      : super(new Inlines.from([new Str(email)]),
            new Target("mailto:" + email, null));

  @override
  String toString() => 'Autolink (${target.link})';

  @override
  bool operator ==(dynamic obj) => obj is Autolink && target == obj.target;

  @override
  int get hashCode => target.hashCode;
}

/// Image inline
abstract class Image extends Inline {
  /// Image label
  Inlines label;

  /// Image target
  Target target;

  /// Constructor
  Image(this.label, this.target);
}

/// Inline image
class InlineImage extends Image {
  /// Constructor
  InlineImage(Inlines label, Target target) : super(label, target);

  @override
  String toString() => 'InlineImage $label ($target)';

  @override
  bool operator ==(dynamic obj) =>
      obj is InlineImage &&
      target == obj.target &&
      _iterableEquality.equals(label, obj.label);

  @override
  int get hashCode => hash2(target, label);
}

/// Reference image
class ReferenceImage extends Image {
  /// Image reference
  String reference;

  /// Constructor
  ReferenceImage(this.reference, Inlines label, Target target)
      : super(label, target);

  @override
  String toString() => 'ReferenceImage[$reference] $label ($target)';

  @override
  bool operator ==(dynamic obj) =>
      obj is ReferenceImage &&
      reference == obj.reference &&
      target == obj.target &&
      _iterableEquality.equals(label, obj.label);

  @override
  int get hashCode => hash3(reference, target, label);
}

/// Abstract raw inline
abstract class RawInline extends Inline {
  /// Raw inline contents
  String contents;

  /// Constructor
  RawInline(this.contents);
}

/// HTML raw inline
class HtmlRawInline extends RawInline {
  /// Constructor
  HtmlRawInline(String contents) : super(contents);

  @override
  String toString() => "HtmlRawInline $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is HtmlRawInline && contents == obj.contents;

  @override
  int get hashCode => contents.hashCode;
}

/// Abstract TeX math
abstract class TexMath extends Inline {
  /// TeX math contents
  String contents;

  /// Constructor
  TexMath(this.contents);
}

/// Inline TeX Math inline
class TexMathInline extends TexMath {
  /// Constructor
  TexMathInline(String contents) : super(contents);

  @override
  String toString() => "TexMathInline $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is TexMathInline && contents == obj.contents;

  @override
  int get hashCode => contents.hashCode;
}

/// Display TeX math inline
class TexMathDisplay extends TexMath {
  /// Constructor
  TexMathDisplay(String contents) : super(contents);

  @override
  String toString() => "TexMathDisplay $contents";

  @override
  bool operator ==(dynamic obj) =>
      obj is TexMathDisplay && contents == obj.contents;

  @override
  int get hashCode => contents.hashCode;
}
