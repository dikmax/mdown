library mdown.ast.ast;

import 'package:mdown/src/ast/ast.dart';

/// Column alignment in table.
enum Alignment {
  /// Align to left
  left,

  /// Align to center
  center,

  /// Align to right
  right,

  /// No alignment (default)
  none
}

/// Bullet type for unordered list
enum BulletType {
  /// `-` bullet
  minus,

  /// `+` bullet
  plus,

  /// `*` bullet
  star
}

/// Type of emphasis and strong delimiter.
enum EmphasisDelimiterType {
  /// `*emphasis*`
  star,

  /// `_emphasis_`
  underscore
}

/// Fence type for fenced code block
enum FencedCodeBlockType {
  /// `` ` `` fence
  backtick,

  /// `~` fence
  tilde
}

/// Index separator for ordered list
enum IndexSeparator {
  /// 1. list
  dot,

  /// 1) list
  parenthesis
}

/// Type of smart char.
enum SmartCharType {
  /// Mdash (`---`)
  mdash,

  /// Ndash (`--`)
  ndash,

  /// Ellipsis (`...`)
  ellipsis,

  /// Single open quote (`'`)
  singleOpenQuote,

  /// Single close quote (`'`)
  singleCloseQuote,

  /// Double open quote (`"`)
  doubleOpenQuote,

  /// Double close quote (`"`)
  doubleCloseQuote,

  /// Apostrophe (`'`)
  apostrophe
}

/// Type of thematic break
enum ThematicBreakType {
  /// `---`
  minus,

  /// `***`
  star,

  /// `___`
  underscore
}

/// A predicate is a one-argument function that returns a boolean value.
typedef bool Predicate<E>(E argument);

/// A node in the AST structure for a Markdown file.
///
/// Clients may not extend, implement or mix-in this class.
abstract class AstNode {
  /// Return an iterator that can be used to iterate through all the entities
  /// (either AST nodes or tokens) that make up the contents of this node,
  /// including doc comments but excluding other comments.
  Iterable<AstNode> get childEntities;

  /// Return this node's parent node, or `null` if this node is the root of an
  /// AST structure.
  AstNode get parent;

  /// Return the node at the root of this node's AST structure. Note that this
  /// method's performance is linear with respect to the depth of the node in
  /// the AST structure (O(depth)).
  AstNode get root;

  /// Use the given [visitor] to visit this node. Return the value returned by
  /// the visitor as a result of visiting this node.
  E accept<E>(AstVisitor<E> visitor);

  /// Return the most immediate ancestor of this node for which the [predicate]
  /// returns `true`, or `null` if there is no such ancestor. Note that this
  /// node will never be returned.
  E getAncestor<E extends AstNode>(Predicate<AstNode> predicate);

  /// Use the given [visitor] to visit all of the children of this node. The
  /// children will be visited in lexical order.
  void visitChildren<E>(AstVisitor<E> visitor);
}

/// Single attribute in extended attributes.
abstract class Attribute implements AstNode {}

/// Abstract attributes
abstract class Attributes implements AstNode {}

/// Autolink
abstract class Autolink implements Link {}

/// Autolink email
abstract class AutolinkEmail implements Autolink {
  /// Email.
  String get email;
}

/// Root composite inline node in block nodes.
abstract class BaseCompositeInline implements CompositeInline, BaseInline {}

/// Root inline node in block nodes.
abstract class BaseInline implements InlineNode {}

/// BlockNode = ThematicBreak | Heading | Blockquote | ListBlock | RawBlock |
///   CodeBlock | Para | LinkReference
abstract class BlockNode implements AstNode {}

/// Blockquote block
abstract class Blockquote implements BlockNode {
  /// Blockquote contents
  NodeList<BlockNode> get contents;
}

/// Base class for all simple char inlines.
abstract class Char implements InlineNode {}

/// Class attribute in extended attributes ('.' className)
abstract class ClassAttribute implements Attribute {
  /// Class name
  String get className;
}

/// Code inline
abstract class Code implements InlineNode, WithExtendedAttributes {
  /// Code contents
  String get contents;

  /// Size of fence
  int get fenceSize;
}

/// Abstract code block
/// CodeBlock = IndentedCodeBlock | FencedCodeBlock
abstract class CodeBlock implements BlockNode, WithAttributes {
  /// Code block contents
  Iterable<String> get contents;
}

/// Collapsed reference
abstract class CollapsedReference implements Reference {}

/// Base class for all composite inlines. Also used as top component for
/// inlines list.
abstract class CompositeInline implements InlineNode {
  /// Inline contents
  NodeList<InlineNode> get contents;
}

/// Main document object
abstract class Document implements AstNode {
  /// Documents contents
  NodeList<BlockNode> get contents;
}

/// Emphasis inline
abstract class Emphasis implements CompositeInline {
  /// Type of delimiter
  EmphasisDelimiterType get delimiterType;
}

/// Extended attributes
///
/// '{' Attribute* '}'
abstract class ExtendedAttributes implements Attributes {
  /// List of attributes.
  NodeList<Attribute> get attributes;
}

/// Fenced code block
abstract class FencedCodeBlock implements CodeBlock {
  /// Fence type `` ` `` or `~`
  FencedCodeBlockType get type;

  /// Fence size
  int get fenceSize;
}

/// Full reference
abstract class FullReference implements Reference {}

/// Hard line break.
abstract class HardLineBreak implements InlineNode {}

/// Abstract heading.
///
/// Heading = AtxHeading | SetextHeading
abstract class Heading implements BlockNode, WithExtendedAttributes {
  /// Heading level 1—6
  int get level;

  /// Heading contents
  BaseInline get contents;
}

/// HTML raw block
abstract class HtmlRawBlock implements RawBlock {}

/// HTML raw inline
abstract class HtmlRawInline implements RawInline {}

/// Id attribute in extended attributes ('#' + identifier).
abstract class IdentifierAttribute implements Attribute {
  /// Identifier.
  String get identifier;
}

/// Abstract image inline.
abstract class Image implements CompositeInline, WithExtendedAttributes {
  String get link;

  String get title;
}

/// Indented code block
abstract class IndentedCodeBlock implements CodeBlock {}

/// InfoString attribute (for fenced code only).
abstract class InfoString implements Attributes {
  /// Language name
  String get language;
}

/// Inline image
abstract class InlineImage
    implements Image, WithTarget, WithExtendedAttributes {}

/// Inline link
abstract class InlineLink implements Link, WithTarget {}

/// Abstract inline
abstract class InlineNode implements AstNode {}

/// Key-value attribute in extended attributes (key '=' value).
abstract class KeyValueAttribute implements Attribute {
  String get key;

  String get value;
}

/// Abstract link inline
abstract class Link implements CompositeInline, WithExtendedAttributes {
  /// Link href.
  String get link;

  /// Link title
  String get title;
}

abstract class LinkReference
    implements BlockNode, WithTarget, WithExtendedAttributes {
  String get reference;

  String get normalizedReference;
}

/// Abstract list block
///
/// ListBlock = UnorderedList | OrderedList
abstract class ListBlock implements BlockNode {
  /// Is list tight, i.e. no paragraphs inside just plain items
  bool get tight;

  /// List items
  NodeList<ListItem> get items;
}

/// List item block
abstract class ListItem implements AstNode {
  /// Item contents
  NodeList<BlockNode> get contents;
}

/// Non-breakable space
abstract class NonBreakableSpace implements Whitespace {}

/// Ordered list
abstract class OrderedList implements ListBlock {
  /// Separator `.` or `)`
  IndexSeparator get indexSeparator;

  /// Start index
  int get startIndex;
}

/// Paragraph block
abstract class Para implements BlockNode {
  /// Paragraph contents
  BaseInline get contents;
}

/// Abstract raw block
abstract class RawBlock implements BlockNode {
  /// Raw block contents
  String get contents;
}

/// Abstract raw inline
abstract class RawInline implements InlineNode {
  /// Raw inline contents
  String get contents;
}

/// Abstract reference.
abstract class Reference implements AstNode, WithTarget {
  /// Reference
  String get reference;
}

/// Reference image.
abstract class ReferenceImage
    implements Image, WithReference, WithExtendedAttributes {}

/// Reference link.
abstract class ReferenceLink implements Link, WithReference {}

/// Shortcut reference.
abstract class ShortcutReference implements Reference {}

/// Smart char
abstract class SmartChar implements Char {
  /// Type of smart char
  SmartCharType get type;
}

/// Soft line break.
abstract class SoftLineBreak implements InlineNode {}

/// Space char inline
abstract class Space implements Whitespace {}

/// String inline
abstract class Str implements InlineNode {
  /// String contents
  String get contents;
}

/// Strikeout inline
abstract class Strikeout implements CompositeInline {}

/// Strong inline
abstract class Strong implements CompositeInline {
  /// Type of delimiter
  EmphasisDelimiterType get delimiterType;
}

/// Subscript inline
abstract class Subscript implements CompositeInline {}

/// Superscript inline
abstract class Superscript implements CompositeInline {}

/// Tab char inline
abstract class Tab implements Whitespace {}

/// Table block.
abstract class Table implements BlockNode {
  /// Table caption
  BaseInline get caption;

  /// Alignment descriptions
  List<Alignment> get alignment;

  /// Table headers
  NodeList<TableCell> get headers;

  /// Table contents
  NodeList<TableRow> get contents;
}

abstract class TableCell implements AstNode {
  /// Cell contents contents
  NodeList<BlockNode> get contents;
}

abstract class TableRow implements AstNode {
  /// Cells in row
  NodeList<TableCell> get contents;
}

/// Target ::= TargetLink (' ' TargetTitle)?
abstract class Target implements AstNode {
  TargetLink get link;

  TargetTitle get title;
}

/// Target link.
///
/// TargetLink ::= '<'? link '>'?
abstract class TargetLink implements AstNode {
  String get link;
}

/// Target title.
///
/// TargetTitle ::= '(' title ')' | '"' title '"' | "'" title "'"
abstract class TargetTitle implements AstNode {
  String get title;
}

abstract class TexMath implements TexRawInline {}

/// Display TeX math inline
abstract class TexMathDisplay implements TexMath {}

/// Inline TeX Math inline
abstract class TexMathInline implements TexMath {}

/// TeX raw block
abstract class TexRawBlock implements RawBlock {}

abstract class TexRawInline implements RawInline {}

/// Thematic break block
abstract class ThematicBreak implements BlockNode {
  /// Thematic break type `-`, `_` or `*`.
  ThematicBreakType get type;
}

/// Unordered list
abstract class UnorderedList implements ListBlock {
  /// Bullet type `+`, `-` or `*`
  BulletType get bulletType;
}

/// Whitespace char
abstract class Whitespace implements Char {
  /// Amount of consequential chars.
  int get amount;
}

/// Node with extended attributes.
abstract class WithAttributes implements AstNode {
  /// Attributes.
  Attributes get attributes;
}

/// Node with extended attributes.
abstract class WithExtendedAttributes extends WithAttributes {
  @override
  ExtendedAttributes get attributes;
}

/// Node with reference assigned to it.
abstract class WithReference implements AstNode {
  /// Reference
  Reference get reference;
}

/// Node with target assigned to it.
abstract class WithTarget implements AstNode {
  /// Target
  Target get target;
}

/// A list of AST nodes that have a common parent.
///
/// Clients may not extend, implement or mix-in this class.
abstract class NodeList<E extends AstNode> implements List<E> {
  /// Initialize a newly created list of nodes such that all of the nodes that
  /// are added to the list will have their parent set to the given [owner]. The
  /// list will initially be populated with the given [elements].
  factory NodeList(AstNode owner, [List<E> elements]) =>
      new NodeListImpl<E>(owner as AstNodeImpl, elements);

  /// Return the node that is the parent of each of the elements in the list.
  AstNode get owner;

  /// Return the node at the given [index] in the list or throw a [RangeError] if
  /// [index] is out of bounds.
  @override
  E operator [](int index);

  /// Set the node at the given [index] in the list to the given [node] or throw
  /// a [RangeError] if [index] is out of bounds.
  @override
  void operator []=(int index, E node);

  /// Use the given [visitor] to visit each of the nodes in this list.
  R accept<R>(AstVisitor<R> visitor);
}

/// An object that can be used to visit an AST structure.
///
/// Clients may extend or implement this class.
abstract class AstVisitor<R> {
  R visitAutolink(Autolink node);

  R visitAutolinkEmail(AutolinkEmail node);

  R visitBaseCompositeInline(BaseCompositeInline node);

  R visitBlockquote(Blockquote node);

  R visitClassAttribute(ClassAttribute node);

  R visitCode(Code node);

  R visitCollapsedReference(CollapsedReference node);

  R visitDocument(Document node);

  R visitEmphasis(Emphasis node);

  R visitExtendedAttributes(ExtendedAttributes node);

  R visitFencedCodeBlock(FencedCodeBlock node);

  R visitFullReference(FullReference node);

  R visitHardLineBreak(HardLineBreak node);

  R visitHeading(Heading node);

  R visitHtmlRawBlock(HtmlRawBlock node);

  R visitHtmlRawInline(HtmlRawInline node);

  R visitIdentifierAttribute(IdentifierAttribute node);

  R visitIndentedCodeBlock(IndentedCodeBlock node);

  R visitInfoString(InfoString node);

  R visitInlineImage(InlineImage node);

  R visitInlineLink(InlineLink node);

  R visitKeyValueAttribute(KeyValueAttribute node);

  R visitLinkReference(LinkReference node);

  R visitListItem(ListItem node);

  R visitNonBreakableSpace(NonBreakableSpace node);

  R visitOrderedList(OrderedList node);

  R visitPara(Para node);

  R visitReferenceImage(ReferenceImage node);

  R visitReferenceLink(ReferenceLink node);

  R visitShortcutReference(ShortcutReference node);

  R visitSmartChar(SmartChar node);

  R visitSoftLineBreak(SoftLineBreak node);

  R visitSpace(Space node);

  R visitStr(Str node);

  R visitStrikeout(Strikeout node);

  R visitStrong(Strong node);

  R visitSubscript(Subscript node);

  R visitSuperscript(Superscript node);

  R visitTab(Tab node);

  R visitTable(Table node);

  R visitTableCell(TableCell node);

  R visitTableRow(TableRow node);

  R visitTarget(Target node);

  R visitTargetLink(TargetLink node);

  R visitTargetTitle(TargetTitle node);

  R visitTexMathDisplay(TexMathDisplay node);

  R visitTexMathInline(TexMathInline node);

  R visitTexRawBlock(TexRawBlock node);

  R visitThematicBreak(ThematicBreak node);

  R visitUnorderedList(UnorderedList node);
}
