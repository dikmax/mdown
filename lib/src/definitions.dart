part of markdown;

/*
Class system is inspired by Pandoc
 */

bool _compareIterable(Iterable a, Iterable b, [int level = 1]) {
  var aIterator = a.iterator;
  var bIterator = b.iterator;
  for (;;) {
    // Advance in lockstep.
    var expectedNext = aIterator.moveNext();
    var actualNext = bIterator.moveNext();

    // If we reached the end of both, we succeeded.
    if (!expectedNext && !actualNext) {
      return true;
    }

    // Fail if their lengths are different.
    if (!expectedNext || !actualNext) {
      return false;
    }

    // Match the elements.
    if (level > 1) {
      return _compareIterable(aIterator.current, bIterator.current, level - 1);
    } else {
      if (aIterator.current != bIterator.current) {
        return false;
      }
    }
  }
}

bool _compareMap(Map a, Map b) {
  if (a.length != b.length) {
    return false;
  }

  for (var key in a.keys) {
    if (!b.containsKey(key)) {
      return false;
    }
  }

  for (var key in b.keys) {
    if (!a.containsKey(key)) {
      return false;
    }
  }

  for (var key in a.keys) {
    if (a[key] != b[key]) {
      return false;
    }
  }

  return true;
}

class Document {
  Iterable<Block> blocks;

  Document(this.blocks);

  String toString() => "Document $blocks";

  bool operator== (Document obj) => _compareIterable(blocks, obj.blocks);
}


class Attr {
  String id;
  Iterable<String> classes;
  Map<String, String> attributes;

  Attr(this.id, this.classes, this.attributes);

  String toString() => '("$id", $classes, $attributes)';

  bool operator== (Attr obj) => id == obj.id &&
    _compareIterable(classes, obj.classes) &&
    _compareMap(attributes, obj.attributes);
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

  bool operator== (ListNumberDelim obj) => value == obj.value;
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

  bool operator== (ListNumberStyle obj) => value == obj.value;
}


class ListAttributes {
  int start;
  ListNumberStyle numberStyle;
  ListNumberDelim numberDelim;

  ListAttributes(this.start, this.numberStyle, this.numberDelim);

  String toString() => "($start, $numberStyle, $numberDelim)";

  bool operator== (ListAttributes obj) => start == obj.start &&
    numberStyle == obj.numberStyle &&
    numberDelim == obj.numberDelim;
}


abstract class Block {

}


class Plain extends Block {
  Iterable<Inline> inlines;

  Plain(this.inlines);

  String toString() => "Plain $inlines";

  bool operator== (Plain obj) => _compareIterable(inlines, obj.inlines);
}


class Para extends Block {
  Iterable<Inline> inlines;

  Para(this.inlines);

  String toString() => "Para $inlines";

  bool operator== (Para obj) => _compareIterable(inlines, obj.inlines);
}


class CodeBlock extends Block {
  Attr attr;
  String code;

  CodeBlock(this.attr, this.code);

  String toString() => 'CodeBlock $attr "$code"';

  bool operator== (CodeBlock obj) => attr == obj.attr && code == obj.code;
}


class RawBlock extends Block {
  String format;
  String data;

  RawBlock(this.format, this.data);

  String toString() => 'RawBlock "$format" "$data"';

  bool operator== (RawBlock obj) => format == obj.format && data == obj.data;
}


class BlockQuote extends Block {
  Iterable<Block> blocks;

  BlockQuote(this.blocks);

  String toString() => "BlockQuote $blocks";

  bool operator== (BlockQuote obj) => _compareIterable(blocks, obj.blocks);
}


class OrderedList extends Block {
  ListAttributes attributes;
  Iterable<Iterable<Block>> items;

  OrderedList(this.attributes, this.items);

  String toString() => "OrderedList $attributes $items";

  bool operator== (OrderedList obj) => attributes == obj.attributes && _compareIterable(items, obj.items, 2);
}


class BulletList extends Block {
  Iterable<Iterable<Block>> items;

  BulletList(this.items);

  String toString() => "BulletList $items";

  bool operator== (BulletList obj) => _compareIterable(items, obj.items, 2);
}


class Definition {
  Iterable<Inline> term;
  Iterable<Iterable<Block>> definition;

  Definition(this.term, this.definition);

  String toString() => "Definition $term $definition";

  bool operator== (Definition obj) => _compareIterable(term, obj.term) && _compareIterable(definition, obj.definition, 2);
}


class DefinitionList extends Block {
  Iterable<Definition> items;

  DefinitionList(this.items);

  String toString() => "DefinitionList $items";

  bool operator== (DefinitionList obj) => _compareIterable(items, obj.items);
}


class Header extends Block {
  int level;
  Attr attributes;
  Iterable<Inline> inlines;

  Header(this.level, this.attributes, this.inlines);

  String toString() => "Header $level $attributes $inlines";

  bool operator== (Header obj) => level == obj.level && attributes == obj.attributes &&
    _compareIterable(inlines, obj.inlines);
}


class HorizontalRule extends Block {
  HorizontalRule();

  String toString() => "HorizontalRule";

  bool operator== (HorizontalRule obj) => true;
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

  bool operator== (Div obj) => attributes == obj.attributes && _compareIterable(blocks, obj.blocks);
}


abstract class Inline {

}


class Str extends Inline {
  String str;

  Str(this.str);

  String toString() => 'Str "$str"';

  bool operator== (Str obj) => str == obj.str;
}


class Emph extends Inline {
  Iterable<Inline> inlines;

  Emph(this.inlines);

  String toString() => "Emph $inlines";

  bool operator== (Emph obj) => _compareIterable(inlines, obj.inlines);
}


class Strong extends Inline {
  Iterable<Inline> inlines;

  Strong(this.inlines);

  String toString() => "Strong $inlines";

  bool operator== (Strong obj) => _compareIterable(inlines, obj.inlines);
}


class Strikeout extends Inline {
  Iterable<Inline> inlines;

  Strikeout(this.inlines);

  String toString() => "Strikeout $inlines";

  bool operator== (Strikeout obj) => _compareIterable(inlines, obj.inlines);
}


class Superscript extends Inline {
  Iterable<Inline> inlines;

  Superscript(this.inlines);

  String toString() => "Superscript $inlines";

  bool operator== (Superscript obj) => _compareIterable(inlines, obj.inlines);
}


class Subscript extends Inline {
  Iterable<Inline> inlines;

  Subscript(this.inlines);

  String toString() => "Subscript $inlines";

  bool operator== (Subscript obj) => _compareIterable(inlines, obj.inlines);
}


class SmallCaps extends Inline {
  Iterable<Inline> inlines;

  SmallCaps(this.inlines);

  String toString() => "SmallCaps $inlines";

  bool operator== (SmallCaps obj) => _compareIterable(inlines, obj.inlines);
}


class QuoteType {
  static const QuoteType SingleQuote = const QuoteType._(0, "SingleQuote");
  static const QuoteType DoubleQuote = const QuoteType._(1, "DoubleQuote");

  final int value;
  final String name;

  const QuoteType._(this.value, this.name);

  String toString() => name;

  bool operator== (QuoteType obj) => value == obj.value;
}


class Quoted extends Inline {
  QuoteType type;
  Iterable<Inline> inlines;

  Quoted(this.type, this.inlines);

  String toString() => "Quoted $type $inlines";

  bool operator== (Quoted obj) => type == obj.type && _compareIterable(inlines, obj.inlines);
}


class CitationMode {
  static const CitationMode AuthorInText = const CitationMode._(0, "AuthorInText");
  static const CitationMode SuppressAuthor = const CitationMode._(1, "SuppressAuthor");
  static const CitationMode NormalCitation = const CitationMode._(2, "NormalCitation");

  final int value;
  final String name;

  const CitationMode._(this.value, this.name);

  String toString() => name;

  bool operator== (CitationMode obj) => value == obj.value;
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

  bool operator== (Citation obj) => id == obj.id &&
    _compareIterable(prefix, obj.prefix) &&
    _compareIterable(suffix, obj.suffix) &&
    mode == obj.mode &&
    noteNum == obj.noteNum &&
    hash == obj.hash;
}


class Cite extends Inline {
  Iterable<Citation> citations;
  Iterable<Inline> inlines;

  Cite(this.citations, this.inlines);

  String toString() => "Cite $citations $inlines";

  bool operator== (Cite obj) => _compareIterable(citations, obj.citations) &&
    _compareIterable(inlines, obj.inlines);
}


class Code extends Inline {
  Attr attributes;
  String code;

  Code(this.attributes, this.code);

  String toString() => "Code $attributes $code";

  bool operator== (Code obj) => attributes == obj.attributes && code == obj.code;
}


class Space extends Inline {
  Space();

  String toString() => "Space";

  bool operator== (Space obj) => true;
}


class LineBreak extends Inline {
  LineBreak();

  String toString() => "LineBreak";

  bool operator== (LineBreak obj) => true;
}


class MathType {
  static const MathType DisplayMath = const MathType._(0, "DisplayMath");
  static const MathType InlineMath = const MathType._(1, "InlineMath");

  final int value;
  final String name;

  const MathType._(this.value, this.name);

  String toString() => name;

  bool operator== (MathType obj) => value == obj.value;
}


class Math extends Inline {
  MathType type;
  String string;

  Math(this.type, this.string);

  String toString() => 'Math $type "$string"';

  bool operator== (Math obj) => type == obj.type && string == obj.string;
}


class RawInline extends Inline {
  String format;
  String data;

  RawInline(this.format, this.data);

  String toString() => 'RawInline "$format" "$data"';

  bool operator== (RawInline obj) => format == obj.format && data == obj.data;
}


class Target {
  String url;
  String title;

  Target(this.url, this.title);

  String toString() => 'Target "$url" "$title"';

  bool operator== (Target obj) => url == obj.url && title == obj.title;
}


class Link extends Inline {
  Iterable<Inline> inlines;
  Target target;

  Link(this.inlines, this.target);

  String toString() => "Link $inlines $target";

  bool operator== (Link obj) => _compareIterable(inlines, obj.inlines) && target == obj.target;
}


class Image extends Inline {
  Iterable<Inline> inlines;
  Target target;

  Image(this.inlines, this.target);

  String toString() => "Image $inlines $target";

  bool operator== (Image obj) => _compareIterable(inlines, obj.inlines) && target == obj.target;
}


class Note extends Inline {
  Iterable<Block> blocks;

  Note(this.blocks);

  String toString() => "Note $blocks";

  bool operator== (Note obj) => _compareIterable(blocks, obj.blocks);
}


class Span extends Inline {
  Attr attributes;
  Iterable<Inline> inlines;

  Span(this.attributes, this.inlines);

  String toString()

  bool operator== (Span obj) => attributes == obj.attributes && _compareIterable(inlines, obj.inlines);
}
