library md_proc.definitions;

import 'package:collection/collection.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

// Class system is inspired by Pandoc

const IterableEquality<dynamic> _iterableEquality =
    const IterableEquality<dynamic>();
const ListEquality<dynamic> _listEquality = const ListEquality<dynamic>();
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
  /// Language name
  String language;

  /// Constructor
  InfoString(this.language);

  @override
  String toString() => "InfoString($language)";

  @override
  bool operator ==(dynamic obj) =>
      obj is InfoString && language == obj.language;

  @override
  int get hashCode => language.hashCode;
}

/// Extended attribute information.
class Attributes extends Attr {
  /// Element id.
  String identifier;

  /// List of classes.
  Iterable<String> classes;

  /// Rest of the attributes.
  Multimap<String, String> attributes;

  /// Constructor
  Attributes(this.identifier, this.classes, this.attributes);

  @override
  String toString() {
    final List<String> res = <String>[];
    if (identifier != null) {
      res.add('#$identifier');
    }
    if (classes != null) {
      for (String el in classes) {
        res.add('.$el');
      }
    }

    final List<String> keys = attributes.keys.toList(growable: false);
    keys.sort();
    for (String key in keys) {
      for (String value in attributes[key]) {
        res.add('$key=$value');
      }
    }

    return 'Attributes(${res.join(' ')})';
  }

  @override
  bool operator ==(dynamic obj) =>
      obj is Attributes &&
      identifier == obj.identifier &&
      _iterableEquality.equals(classes, obj.classes) &&
      _deepEquality.equals(attributes.asMap(), obj.attributes.asMap());

  @override
  int get hashCode => hash3(identifier, classes, attributes);
}

// TODO link type: with or without <>
// TODO title delimiters ", ' or ()
/// Image or link target
class Target {
  /// Target link
  String link;

  /// Target link title
  String title;

  /// Attributes
  Attr attributes;

  /// Constructor
  Target(this.link, this.title, [Attr attributes]) {
    this.attributes = attributes ?? new EmptyAttr();
  }

  @override
  String toString() =>
      'Target "$link" ${title == null ? "null" : "\"$title\""} $attributes';

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
/// Thematic break block
class ThematicBreak extends Block {
  static final ThematicBreak _instance = new ThematicBreak._internal();

  /// Constructor
  factory ThematicBreak() {
    return _instance;
  }

  ThematicBreak._internal();

  @override
  String toString() => "ThematicBreak";

  @override
  bool operator ==(dynamic obj) => obj is ThematicBreak;

  @override
  int get hashCode => 0;
}

/// Abstract heading
abstract class Heading extends Block {
  /// Heading level 1—6
  int level;

  /// Heading contents
  Iterable<Inline> contents;

  /// Heading attributes
  Attr attributes;

  /// constructor
  Heading(this.level, this.contents, [Attr attributes]) {
    this.attributes = attributes ?? new EmptyAttr();
  }
}

/// ATX heading block
class AtxHeading extends Heading {
  /// constructor
  AtxHeading(int level, Iterable<Inline> contents, [Attr attributes])
      : super(level, contents, attributes);

  /// H1 constructor
  AtxHeading.h1(Iterable<Inline> contents, [Attr attributes])
      : super(1, contents, attributes);

  /// H2 constructor
  AtxHeading.h2(Iterable<Inline> contents, [Attr attributes])
      : super(2, contents, attributes);

  /// H3 constructor
  AtxHeading.h3(Iterable<Inline> contents, [Attr attributes])
      : super(3, contents, attributes);

  /// H4 constructor
  AtxHeading.h4(Iterable<Inline> contents, [Attr attributes])
      : super(4, contents, attributes);

  /// H5 constructor
  AtxHeading.h5(Iterable<Inline> contents, [Attr attributes])
      : super(5, contents, attributes);

  /// H6 constructor
  AtxHeading.h6(Iterable<Inline> contents, [Attr attributes])
      : super(6, contents, attributes);

  @override
  String toString() => "AtxHeading $level $contents $attributes";

  @override
  bool operator ==(dynamic obj) =>
      obj is AtxHeading &&
      level == obj.level &&
      _iterableEquality.equals(contents, obj.contents) &&
      attributes == obj.attributes;

  @override
  int get hashCode => hash2(level, contents);
}

/// Setext heading block
class SetextHeading extends Heading {
  /// constructor
  SetextHeading(int level, Iterable<Inline> contents, [Attr attributes])
      : super(level, contents, attributes);

  /// H1 constructor
  SetextHeading.h1(Iterable<Inline> contents, [Attr attributes])
      : super(1, contents, attributes);

  /// H2 constructor
  SetextHeading.h2(Iterable<Inline> contents, [Attr attributes])
      : super(2, contents, attributes);

  @override
  String toString() => "SetextHeading $level $contents $attributes";

  @override
  bool operator ==(dynamic obj) =>
      obj is SetextHeading &&
      level == obj.level &&
      _iterableEquality.equals(contents, obj.contents) &&
      attributes == obj.attributes;

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

  /// Create from char
  static FenceType fromChar(String markerChar) {
    FenceType type;
    switch (markerChar) {
      case '~':
        type = FenceType.tilde;
        break;

      case '`':
        type = FenceType.backtick;
        break;

      default:
        assert(false);
        type = FenceType.backtick;
    }

    return type;
  }

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
      : super(contents, attributes ?? new EmptyAttr());

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
  Iterable<Inline> contents;

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

/// Single open quote `'`
class SingleOpenQuote extends SmartChar {
  static final SingleOpenQuote _instance = new SingleOpenQuote._internal();

  /// Constructor
  factory SingleOpenQuote() {
    return _instance;
  }

  SingleOpenQuote._internal();

  @override
  String toString() => "SingleOpenQuote";

  @override
  bool operator ==(dynamic obj) => obj is SingleOpenQuote;

  @override
  int get hashCode => 0;
}

/// Single close quote `'`
class SingleCloseQuote extends SmartChar {
  static final SingleCloseQuote _instance = new SingleCloseQuote._internal();

  /// Constructor
  factory SingleCloseQuote() {
    return _instance;
  }

  SingleCloseQuote._internal();

  @override
  String toString() => "SingleCloseQuote";

  @override
  bool operator ==(dynamic obj) => obj is SingleCloseQuote;

  @override
  int get hashCode => 0;
}

/// Double open quote `"`
class DoubleOpenQuote extends SmartChar {
  static final DoubleOpenQuote _instance = new DoubleOpenQuote._internal();

  /// Constructor
  factory DoubleOpenQuote() {
    return _instance;
  }

  DoubleOpenQuote._internal();

  @override
  String toString() => "DoubleOpenQuote";

  @override
  bool operator ==(dynamic obj) => obj is DoubleOpenQuote;

  @override
  int get hashCode => 0;
}

/// Double close quote `"`
class DoubleCloseQuote extends SmartChar {
  static final DoubleCloseQuote _instance = new DoubleCloseQuote._internal();

  /// Constructor
  factory DoubleCloseQuote() {
    return _instance;
  }

  DoubleCloseQuote._internal();

  @override
  String toString() => "DoubleCloseQuote";

  @override
  bool operator ==(dynamic obj) => obj is DoubleCloseQuote;

  @override
  int get hashCode => 0;
}

/// Apostrophe `'`
class Apostrophe extends SmartChar {
  static final Apostrophe _instance = new Apostrophe._internal();

  /// Constructor
  factory Apostrophe() {
    return _instance;
  }

  Apostrophe._internal();

  @override
  String toString() => "Apostrophe";

  @override
  bool operator ==(dynamic obj) => obj is Apostrophe;

  @override
  int get hashCode => 0;
}

/// Code inline
class Code extends Inline {
  /// Code contents
  String contents;

  /// Size of fence
  int fenceSize;

  /// Code attributes
  Attr attributes;

  /// Constructor
  Code(this.contents, {this.fenceSize: 1, Attr attributes}) {
    this.attributes = attributes ?? new EmptyAttr();
  }

  @override
  String toString() => 'Code "$contents" $attributes';

  @override
  bool operator ==(dynamic obj) =>
      obj is Code && contents == obj.contents && fenceSize == obj.fenceSize;

  @override
  int get hashCode => hash2(contents, fenceSize);
}

/// Emphasis inline
class Emph extends Inline {
  /// Inner inlines
  Iterable<Inline> contents;

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
  Iterable<Inline> contents;

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
  Iterable<Inline> contents;

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
  Iterable<Inline> contents;

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
  Iterable<Inline> contents;

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
  Iterable<Inline> label;

  /// Link target
  Target target;

  /// Constructor
  Link(this.label, this.target);
}

/// Inline link
class InlineLink extends Link {
  /// Constructor
  InlineLink(Iterable<Inline> label, Target target) : super(label, target);

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
  ReferenceLink(this.reference, Iterable<Inline> label, Target target)
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
      : super(<Inline>[new Str(link)], new Target(link, null));

  /// Constructor from email
  Autolink.email(String email)
      : super(<Inline>[new Str(email)], new Target("mailto:" + email, null));

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
  Iterable<Inline> label;

  /// Image target
  Target target;

  /// Constructor
  Image(this.label, this.target);
}

/// Inline image
class InlineImage extends Image {
  /// Constructor
  InlineImage(Iterable<Inline> label, Target target) : super(label, target);

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
  ReferenceImage(this.reference, Iterable<Inline> label, Target target)
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
