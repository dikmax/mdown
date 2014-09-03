part of markdown;

// Class system is inspired by Pandoc

const _iterableEquality = const IterableEquality();
const _mapEquality = const MapEquality();
const _deepEquality = const DeepCollectionEquality();

class Document {
  Iterable<Block> blocks;

  Document(this.blocks);

  String toString() => "Document $blocks";

  bool operator== (obj) => obj is Document &&
    _iterableEquality.equals(blocks, obj.blocks);
}


class Attr {
  String id;
  Iterable<String> classes;
  Map<String, String> attributes;

  Attr(this.id, this.classes, this.attributes);

  String toString() => '("$id", $classes, $attributes)';

  Attr operator+ (Attr obj) => new Attr(obj.id == "" ? id : obj.id,
    new List.from(classes)..addAll(obj.classes),
    new Map.from(attributes)..addAll(obj.attributes));

  bool operator== (obj) => obj is Attr &&
    id == obj.id &&
    _iterableEquality.equals(classes, obj.classes) &&
    _mapEquality.equals(attributes, obj.attributes);
}


class ListNumberDelim {
  static const ListNumberDelim DefaultDelim = const ListNumberDelim._(0, "DefaultDelim");
  static const ListNumberDelim Period = const ListNumberDelim._(1, "Period");
  static const ListNumberDelim OneParen = const ListNumberDelim._(2, "OneParen");
  static const ListNumberDelim TwoParens = const ListNumberDelim._(3, "TwoParens");

  final int value;
  final String name;

  const ListNumberDelim._(this.value, this.name);

  String toString() => name;

  bool operator== (obj) => obj is ListNumberDelim &&
    value == obj.value;
}


class ListNumberStyle {
  static const ListNumberStyle DefaultStyle = const ListNumberStyle._(0, "DefaultStyle");
  static const ListNumberStyle Example = const ListNumberStyle._(1, "Example");
  static const ListNumberStyle Decimal = const ListNumberStyle._(2, "Decimal");
  static const ListNumberStyle LowerRoman = const ListNumberStyle._(3, "LowerRoman");
  static const ListNumberStyle UpperRoman = const ListNumberStyle._(4, "UpperRoman");
  static const ListNumberStyle LowerAlpha = const ListNumberStyle._(5, "LowerAlpha");
  static const ListNumberStyle UpperAlpha = const ListNumberStyle._(6, "UpperAlpha");

  final int value;
  final String name;

  const ListNumberStyle._(this.value, this.name);

  String toString() => name;

  bool operator== (obj) => obj is ListNumberStyle &&
    value == obj.value;
}


class ListAttributes {
  int start;
  ListNumberStyle numberStyle;
  ListNumberDelim numberDelim;

  ListAttributes(this.start, this.numberStyle, this.numberDelim);

  String toString() => "($start, $numberStyle, $numberDelim)";

  bool operator== (obj) => obj is ListAttributes &&
    start == obj.start &&
    numberStyle == obj.numberStyle &&
    numberDelim == obj.numberDelim;
}


abstract class Block {

}


class Plain extends Block {
  Iterable<Inline> inlines;

  Plain(this.inlines);

  String toString() => "Plain $inlines";

  bool operator== (obj) => obj is Plain &&
    _iterableEquality.equals(inlines, obj.inlines);
}


class Para extends Block {
  Iterable<Inline> inlines;

  Para(this.inlines);

  String toString() => "Para $inlines";

  bool operator== (obj) => obj is Para &&
    _iterableEquality.equals(inlines, obj.inlines);
}


class CodeBlock extends Block {
  Attr attr;
  String code;

  CodeBlock(this.attr, this.code);

  String toString() => 'CodeBlock $attr "$code"';

  bool operator== (obj) => obj is CodeBlock &&
    attr == obj.attr &&
    code == obj.code;
}


class RawBlock extends Block {
  String format;
  String data;

  RawBlock(this.format, this.data);

  String toString() => 'RawBlock "$format" "$data"';

  bool operator== (obj) => obj is RawBlock &&
    format == obj.format &&
    data == obj.data;
}


class BlockQuote extends Block {
  Iterable<Block> blocks;

  BlockQuote(this.blocks);

  String toString() => "BlockQuote $blocks";

  bool operator== (obj) => obj is BlockQuote &&
    _iterableEquality.equals(blocks, obj.blocks);
}


class OrderedList extends Block {
  ListAttributes attributes;
  Iterable<Iterable<Block>> items;

  OrderedList(this.attributes, this.items);

  String toString() => "OrderedList $attributes $items";

  bool operator== (obj) => obj is OrderedList &&
    attributes == obj.attributes &&
    _deepEquality.equals(items, obj.items);
}


class BulletList extends Block {
  Iterable<Iterable<Block>> items;

  BulletList(this.items);

  String toString() => "BulletList $items";

  bool operator== (obj) => obj is BulletList &&
    _deepEquality.equals(items, obj.items);
}


class Definition {
  Iterable<Inline> term;
  Iterable<Iterable<Block>> definition;

  Definition(this.term, this.definition);

  String toString() => "Definition $term $definition";

  bool operator== (obj) => obj is Definition &&
    _iterableEquality.equals(term, obj.term) &&
    _deepEquality.equals(definition, obj.definition);
}


class DefinitionList extends Block {
  Iterable<Definition> items;

  DefinitionList(this.items);

  String toString() => "DefinitionList $items";

  bool operator== (obj) => obj is DefinitionList &&
    _iterableEquality.equals(items, obj.items);
}


class Header extends Block {
  int level;
  Attr attributes;
  Iterable<Inline> inlines;

  Header(this.level, this.attributes, this.inlines);

  String toString() => "Header $level $attributes $inlines";

  bool operator== (obj) => obj is Header &&
    level == obj.level &&
    attributes == obj.attributes &&
    _iterableEquality.equals(inlines, obj.inlines);
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


/*
class Table {
  Iterable<Inline> caption;
  Iterable<Alignment> alignments;
  Iterable<double> widths;
  Iterable<TableCell> headers;
  Iterable<Iterable<TableCell>> cells;

  Table(this.caption, this.alignments, this.widths, this.headers, this.cells);
}
*/


class Div {
  Attr attributes;
  Iterable<Block> blocks;

  Div(this.attributes, this.blocks);

  String toString() => "Div $attributes $blocks";

  bool operator== (obj) => obj is Div &&
    attributes == obj.attributes &&
    _iterableEquality.equals(blocks, obj.blocks);
}


abstract class Inline {

}


class Str extends Inline {
  String str;

  Str(this.str);

  String toString() => 'Str "$str"';

  bool operator== (obj) => obj is Str &&
    str == obj.str;
}


class Emph extends Inline {
  Iterable<Inline> inlines;

  Emph(this.inlines);

  String toString() => "Emph $inlines";

  bool operator== (obj) => obj is Emph &&
    _iterableEquality.equals(inlines, obj.inlines);
}


class Strong extends Inline {
  Iterable<Inline> inlines;

  Strong(this.inlines);

  String toString() => "Strong $inlines";

  bool operator== (obj) => obj is Strong &&
    _iterableEquality.equals(inlines, obj.inlines);
}


class Strikeout extends Inline {
  Iterable<Inline> inlines;

  Strikeout(this.inlines);

  String toString() => "Strikeout $inlines";

  bool operator== (obj) => obj is Strikeout &&
    _iterableEquality.equals(inlines, obj.inlines);
}


class Superscript extends Inline {
  Iterable<Inline> inlines;

  Superscript(this.inlines);

  String toString() => "Superscript $inlines";

  bool operator== (obj) => obj is Superscript &&
    _iterableEquality.equals(inlines, obj.inlines);
}


class Subscript extends Inline {
  Iterable<Inline> inlines;

  Subscript(this.inlines);

  String toString() => "Subscript $inlines";

  bool operator== (obj) => obj is Subscript &&
    _iterableEquality.equals(inlines, obj.inlines);
}


class SmallCaps extends Inline {
  Iterable<Inline> inlines;

  SmallCaps(this.inlines);

  String toString() => "SmallCaps $inlines";

  bool operator== (obj) => obj is SmallCaps &&
    _iterableEquality.equals(inlines, obj.inlines);
}


class QuoteType {
  static const QuoteType SingleQuote = const QuoteType._(0, "SingleQuote");
  static const QuoteType DoubleQuote = const QuoteType._(1, "DoubleQuote");

  final int value;
  final String name;

  const QuoteType._(this.value, this.name);

  String toString() => name;

  bool operator== (obj) => obj is QuoteType &&
    value == obj.value;
}


class Quoted extends Inline {
  QuoteType type;
  Iterable<Inline> inlines;

  Quoted(this.type, this.inlines);

  String toString() => "Quoted $type $inlines";

  bool operator== (obj) => obj is Quoted &&
    type == obj.type &&
    _iterableEquality.equals(inlines, obj.inlines);
}


class CitationMode {
  static const CitationMode AuthorInText = const CitationMode._(0, "AuthorInText");
  static const CitationMode SuppressAuthor = const CitationMode._(1, "SuppressAuthor");
  static const CitationMode NormalCitation = const CitationMode._(2, "NormalCitation");

  final int value;
  final String name;

  const CitationMode._(this.value, this.name);

  String toString() => name;

  bool operator== (obj) => obj is CitationMode &&
    value == obj.value;
}


class Citation {
  String id;
  Iterable<Inline> prefix;
  Iterable<Inline> suffix;
  CitationMode mode;
  int noteNum;
  int hash;

  Citation(this.id, this.prefix, this.suffix, this.mode, this.hash);

  String toString() => 'Citation "$id" $prefix $suffix $mode $noteNum $hash';

  bool operator== (obj) => obj is Citation &&
    id == obj.id &&
    _iterableEquality.equals(prefix, obj.prefix) &&
    _iterableEquality.equals(suffix, obj.suffix) &&
    mode == obj.mode &&
    noteNum == obj.noteNum &&
    hash == obj.hash;
}


class Cite extends Inline {
  Iterable<Citation> citations;
  Iterable<Inline> inlines;

  Cite(this.citations, this.inlines);

  String toString() => "Cite $citations $inlines";

  bool operator== (obj) => obj is Cite &&
    _iterableEquality.equals(citations, obj.citations) &&
    _iterableEquality.equals(inlines, obj.inlines);
}


class Code extends Inline {
  Attr attributes;
  String code;

  Code(this.attributes, this.code);

  String toString() => "Code $attributes $code";

  bool operator== (obj) => obj is Code &&
    attributes == obj.attributes &&
    code == obj.code;
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


class MathType {
  static const MathType DisplayMath = const MathType._(0, "DisplayMath");
  static const MathType InlineMath = const MathType._(1, "InlineMath");

  final int value;
  final String name;

  const MathType._(this.value, this.name);

  String toString() => name;

  bool operator== (obj) => obj is MathType &&
    value == obj.value;
}


class Math extends Inline {
  MathType type;
  String string;

  Math(this.type, this.string);

  String toString() => 'Math $type "$string"';

  bool operator== (obj) => obj is Math &&
    type == obj.type &&
    string == obj.string;
}


class RawInline extends Inline {
  String format;
  String data;

  RawInline(this.format, this.data);

  String toString() => 'RawInline "$format" "$data"';

  bool operator== (obj) => obj is RawInline &&
    format == obj.format &&
    data == obj.data;
}


class Target {
  String url;
  String title;

  Target(this.url, this.title);

  String toString() => 'Target "$url" "$title"';

  bool operator== (obj) => obj is Target &&
    url == obj.url &&
    title == obj.title;
}


class Link extends Inline {
  Iterable<Inline> inlines;
  Target target;

  Link(this.inlines, this.target);

  String toString() => "Link $inlines $target";

  bool operator== (obj) => obj is Link &&
    _iterableEquality.equals(inlines, obj.inlines) &&
    target == obj.target;
}


class Image extends Inline {
  Iterable<Inline> inlines;
  Target target;

  Image(this.inlines, this.target);

  String toString() => "Image $inlines $target";

  bool operator== (obj) => obj is Image &&
    _iterableEquality.equals(inlines, obj.inlines) &&
    target == obj.target;
}


class Note extends Inline {
  Iterable<Block> blocks;

  Note(this.blocks);

  String toString() => "Note $blocks";

  bool operator== (obj) => obj is Note &&
    _iterableEquality.equals(blocks, obj.blocks);
}


class Span extends Inline {
  Attr attributes;
  Iterable<Inline> inlines;

  Span(this.attributes, this.inlines);

  String toString() => "Span $attributes $inlines";

  bool operator== (obj) => obj is Span &&
    attributes == obj.attributes &&
    _iterableEquality.equals(inlines, obj.inlines);
}
