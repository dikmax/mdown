library mdown.src.ast.ast;

import 'dart:collection';

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/standard_ast_factory.dart';
import 'package:mdown/ast/visitor.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/code_units_list.dart';

class _ContainsLinkVisitor extends RecursiveAstVisitor<Null> {
  bool _result = false;

  bool get result => _result;

  @override
  Null visitAutolink(Autolink node) {
    _result = true;
    return null;
  }

  @override
  Null visitReferenceLink(ReferenceLink node) {
    _result = true;
    return null;
  }

  @override
  Null visitInlineLink(InlineLink node) {
    _result = true;
    return null;
  }

  @override
  Null visitAutolinkEmail(AutolinkEmail node) {
    _result = true;
    return null;
  }
}

/// Default AstNode implementation.
abstract class AstNodeImpl implements AstNode {
  /// The parent of the node, or `null` if the node is the root of an AST
  /// structure.
  AstNode _parent;

  @override
  AstNode get parent => _parent;

  @override
  AstNode get root {
    AstNode root = this;
    AstNode parent = this.parent;
    while (parent != null) {
      root = parent;
      parent = root.parent;
    }
    return root;
  }

  @override
  E getAncestor<E extends AstNode>(Predicate<AstNode> predicate) {
    AstNode node = this;
    while (node != null && !predicate(node)) {
      node = node.parent;
    }
    return node == this ? null : node as E;
  }

  /// Make this node the parent of the given [child] node. Return the child
  /// node.
  AstNode _becomeParentOf(AstNodeImpl child) {
    if (child != null) {
      child._parent = this;
    }
    return child;
  }
}

/// Default Attribute implementation.
abstract class AttributeImpl extends AstNodeImpl implements Attribute {
  @override
  Iterable<AstNode> get childEntities => null;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Default Attributes implementation.
abstract class AttributesImpl extends AstNodeImpl implements Attributes {}

/// Default Autolink implementation.
class AutolinkImpl extends LinkImpl implements Autolink {
  /// Link
  final String _link;

  /// Constructs instance of Autolink.
  AutolinkImpl(this._link, [String text]) : super(null) {
    _contents = new NodeListImpl<InlineNode>(this,
        <InlineNode>[astFactory.str(new CodeUnitsList.string(text ?? _link))]);
  }

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitAutolink(this);

  @override
  String get link => _link;

  @override
  ExtendedAttributes get attributes => null;

  // TODO: implement title
  @override
  String get title => null;
}

/// Default AutolinkEmail implementation.
class AutolinkEmailImpl extends AutolinkImpl implements AutolinkEmail {
  /// Email
  final String _email;

  /// Constructs instance of AutolinkEmail.
  AutolinkEmailImpl(String email)
      : _email = email,
        super('mailto:$email', email);

  @override
  R accept<R>(AstVisitor<R> visitor) {
    return visitor.visitAutolinkEmail(this);
  }

  @override
  String get email => _email;
}

/// Default BaseCompositeInline implementation.
class BaseCompositeInlineImpl extends CompositeInlineImpl
    implements BaseCompositeInline {
  /// Constructs instance of BaseCompositeInline.
  BaseCompositeInlineImpl(Iterable<InlineNode> contents) : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitBaseCompositeInline(this);
}

/// Default BlockNode implementation.
abstract class BlockNodeImpl extends AstNodeImpl implements BlockNode {}

/// Default Blockquote implementation.
class BlockquoteImpl extends BlockNodeImpl implements Blockquote {
  /// Blockquote contents.
  NodeList<BlockNodeImpl> _contents;

  /// Constructs instance of Blockquote.
  BlockquoteImpl(Iterable<BlockNodeImpl> contents) {
    _contents = new NodeListImpl<BlockNodeImpl>(this, contents);
  }

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitBlockquote(this);

  @override
  Iterable<AstNode> get childEntities => _contents;

  @override
  NodeList<BlockNode> get contents => _contents;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _contents?.accept<R>(visitor);
  }
}

/// Default Char implementation.
abstract class CharImpl extends InlineNodeImpl implements Char {}

/// Default ClassAttribute implementation.
class ClassAttributeImpl extends AttributeImpl implements ClassAttribute {
  final String _className;

  /// Constructs instance of ClassAttribute.
  ClassAttributeImpl(this._className);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitClassAttribute(this);

  @override
  String get className => _className;
}

/// Default Code implementation.
class CodeImpl extends InlineNodeImpl implements Code {
  final CodeUnitsList _contents;

  final int _fenceSize;

  final ExtendedAttributes _attributes;

  /// Constructs Code instance.
  CodeImpl(this._contents, this._fenceSize, this._attributes);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitCode(this);

  @override
  ExtendedAttributes get attributes => _attributes;

  @override
  Iterable<AstNode> get childEntities => <AstNode>[_attributes];

  @override
  CodeUnitsList get contents => _contents;

  @override
  int get fenceSize => _fenceSize;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _attributes?.accept<R>(visitor);
  }
}

/// Default CodeBlock implementation.
class CodeBlockImpl extends BlockNodeImpl implements CodeBlock {
  final Iterable<String> _contents;
  final Attributes _attributes;

  /// Constructs CodeBlock instance.
  CodeBlockImpl(this._contents, this._attributes);

  @override
  Iterable<String> get contents => _contents;

  @override
  Attributes get attributes => _attributes;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    this._attributes?.accept(visitor);
  }

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitCodeBlock(this);

  @override
  Iterable<AstNode> get childEntities => <AstNode>[_attributes];
}

/// Default CompositeInline implementation.
abstract class CompositeInlineImpl extends InlineNodeImpl
    implements CompositeInline {
  NodeList<InlineNode> _contents;

  /// Constructs instance of CompositeInline.
  CompositeInlineImpl(Iterable<InlineNode> contents) {
    _contents = new NodeListImpl<InlineNode>(this, contents);
  }

  @override
  NodeList<InlineNode> get contents => _contents;

  @override
  Iterable<AstNode> get childEntities => _contents;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _contents?.accept(visitor);
  }
}

/// Default Document implementation.
class DocumentImpl extends AstNodeImpl implements Document {
  NodeList<BlockNode> _contents;

  /// Constructs Document instance.
  DocumentImpl(Iterable<BlockNode> contents) {
    this._contents = new NodeListImpl<BlockNode>(this, contents);
  }

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitDocument(this);

  @override
  Iterable<AstNode> get childEntities => _contents;

  @override
  NodeList<BlockNode> get contents => _contents;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _contents?.accept(visitor);
  }
}

/// Default Emphasis implementation.
class EmphasisImpl extends CompositeInlineImpl implements Emphasis {
  /// Constructs Emplasis instance.
  EmphasisImpl(Iterable<InlineNode> contents) : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitEmphasis(this);
}

/// Default ExtendedAttributes implementation.
class ExtendedAttributesImpl extends AttributesImpl
    implements ExtendedAttributes {
  NodeList<Attribute> _attributes;

  /// Constructs ExtendedAttributes instance.
  ExtendedAttributesImpl(Iterable<Attribute> attributes) {
    this._attributes = new NodeListImpl<Attribute>(this, attributes);
  }

  @override
  E accept<E>(AstVisitor<E> visitor) => visitor.visitExtendedAttributes(this);

  @override
  NodeList<Attribute> get attributes => _attributes;

  @override
  Iterable<AstNode> get childEntities => _attributes;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _attributes?.accept(visitor);
  }
}

/// Default HardLineBreak implementation.
class HardLineBreakImpl extends InlineNodeImpl implements HardLineBreak {
  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitHardLineBreak(this);

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Default Heading implementation.
class HeadingImpl extends BlockNodeImpl implements Heading {
  ExtendedAttributes _attributes;

  BaseInline _contents;

  final int _level;

  /// Constructs instance of Heading.
  HeadingImpl(this._contents, this._level, this._attributes);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitHeading(this);

  @override
  ExtendedAttributes get attributes => _attributes;

  @override
  Iterable<AstNode> get childEntities => <AstNode>[_contents, _attributes];

  @override
  BaseInline get contents => _contents;

  @override
  int get level => _level;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _contents?.accept<R>(visitor);
    _attributes?.accept<R>(visitor);
  }
}

/// Default HtmlRawBlock implementation.
class HtmlRawBlockImpl extends RawBlockImpl implements HtmlRawBlock {
  /// Constructs HtmlRawBlock instance.
  HtmlRawBlockImpl(String contents) : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitHtmlRawBlock(this);
}

/// Default HtmlRawInline implementation.
class HtmlRawInlineImpl extends RawInlineImpl implements HtmlRawInline {
  /// Constructs HtmlRawInline instance.
  HtmlRawInlineImpl(String contents) : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitHtmlRawInline(this);
}

/// Default IdentifierAttribute implementation.
class IdentifierAttributeImpl extends AttributeImpl
    implements IdentifierAttribute {
  final String _identifier;

  /// Constructs instance of IdentifierAttribute.
  IdentifierAttributeImpl(this._identifier);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitIdentifierAttribute(this);

  @override
  String get identifier => _identifier;
}

/// Default Image implementation.
abstract class ImageImpl extends CompositeInlineImpl implements Image {
  /// Constructs instance of Link.
  ImageImpl(Iterable<InlineNode> contents) : super(contents);
}

/// Default InfoString implementation.
class InfoStringImpl extends AttributesImpl implements InfoString {
  final String _language;

  /// Constructs InfoString
  InfoStringImpl(this._language);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitInfoString(this);

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  String get language => _language;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Default InlineImage implementation
class InlineImageImpl extends ImageImpl implements InlineImage {
  final Target _target;

  final ExtendedAttributes _attributes;

  /// Constructs InlineImage instance.
  InlineImageImpl(Iterable<InlineNode> contents, this._target, this._attributes)
      : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitInlineImage(this);

  @override
  ExtendedAttributes get attributes => _attributes;

  @override
  Target get target => _target;

  @override
  String get link => _target?.link;

  @override
  String get title => _target?.title;
}

/// Default InlineLink implementation
class InlineLinkImpl extends LinkImpl implements InlineLink {
  final Target _target;

  final ExtendedAttributes _attributes;

  /// Constructs InlineImage instance.
  InlineLinkImpl(Iterable<InlineNode> contents, this._target, this._attributes)
      : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitInlineLink(this);

  @override
  ExtendedAttributes get attributes => _attributes;

  @override
  Target get target => _target;

  @override
  String get link => _target?.link;

  @override
  String get title => _target?.title;
}

/// Default InlineNode implementation
abstract class InlineNodeImpl extends AstNodeImpl implements InlineNode {
  bool _containsLink;

  bool get containsLink {
    if (_containsLink == null) {
      final _ContainsLinkVisitor visitor = new _ContainsLinkVisitor();
      accept(visitor);
      _containsLink = visitor.result;
    }

    return _containsLink;
  }
}

/// Default KeyValueAttribute implementation.
class KeyValueAttributeImpl extends AttributeImpl implements KeyValueAttribute {
  final String _key;

  final String _value;

  /// Constructs KeyValueAttribute instance.
  KeyValueAttributeImpl(this._key, this._value);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitKeyValueAttribute(this);

  @override
  String get key => _key;

  @override
  String get value => _value;
}

/// Default Link implementation.
abstract class LinkImpl extends CompositeInlineImpl implements Link {
  /// Constructs instance of Link.
  LinkImpl(Iterable<InlineNode> contents) : super(contents);

  @override
  bool get containsLink => true;
}

/// Default LinkReference implementation.
class LinkReferenceImpl extends BlockNodeImpl implements LinkReference {
  final String _reference;
  String _normalizedReference;
  final Target _target;
  final ExtendedAttributes _attributes;

  /// Constructs LinkReference instance.
  LinkReferenceImpl(this._reference, this._target, this._attributes) {
    _normalizedReference =
        normalizeReference(new CodeUnitsList.string(_reference));
  }

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitLinkReference(this);

  @override
  ExtendedAttributes get attributes => _attributes;

  @override
  Iterable<AstNode> get childEntities => <AstNode>[_target, _attributes];

  @override
  String get reference => _reference;

  @override
  String get normalizedReference => _normalizedReference;

  @override
  Target get target => _target;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _target?.accept(visitor);
    _attributes?.accept(visitor);
  }
}

/// Default ListBlock implementation.
abstract class ListBlockImpl extends BlockNodeImpl implements ListBlock {
  NodeList<ListItem> _items;
  bool _tight;

  /// Constructs ListBlock instance.
  ListBlockImpl(Iterable<ListItem> items, this._tight) {
    _items = new NodeListImpl<ListItem>(this, items);
  }

  @override
  Iterable<AstNode> get childEntities => _items;

  @override
  NodeList<ListItem> get items => _items;

  @override
  bool get tight => _tight;

  set tight(bool value) {
    _tight = value;
  }

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _items.accept(visitor);
  }
}

/// Default ListItem implementation.
class ListItemImpl extends AstNodeImpl implements ListItem {
  NodeList<BlockNode> _contents;

  /// Constructs ListItem instance.
  ListItemImpl(Iterable<BlockNode> contents) {
    _contents = new NodeListImpl<BlockNode>(this, contents);
  }

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitListItem(this);

  @override
  Iterable<AstNode> get childEntities => _contents;

  @override
  NodeList<BlockNode> get contents => _contents;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _contents.accept(visitor);
  }
}

/// Default NonBreakableSpace implementation.
class NonBreakableSpaceImpl extends WhitespaceImpl
    implements NonBreakableSpace {
  /// Constructs NonBreakableSpace instance.
  NonBreakableSpaceImpl(int amount) : super(amount);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitNonBreakableSpace(this);
}

/// Default OrderedList implementation.
class OrderedListImpl extends ListBlockImpl implements OrderedList {
  final IndexSeparator _indexSeparator;

  final int _startIndex;

  /// Constructs OrderedList instance.
  OrderedListImpl(Iterable<ListItem> items, bool tight, this._startIndex,
      this._indexSeparator)
      : super(items, tight);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitOrderedList(this);

  @override
  IndexSeparator get indexSeparator => _indexSeparator;

  @override
  int get startIndex => _startIndex;
}

/// Default Para implementation.
class ParaImpl extends BlockNodeImpl implements Para {
  final BaseInline _contents;

  /// Constructs Para instance.
  ParaImpl(this._contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitPara(this);

  @override
  Iterable<AstNode> get childEntities => <AstNode>[_contents];

  @override
  BaseInline get contents => _contents;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _contents.accept(visitor);
  }
}

/// Default RawBlock implementation.
abstract class RawBlockImpl extends BlockNodeImpl implements RawBlock {
  final String _contents;

  /// Constructs RawBlock instance.
  RawBlockImpl(this._contents);

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  String get contents => _contents;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Default RawInline implementation.
abstract class RawInlineImpl extends InlineNodeImpl implements RawInline {
  final String _contents;

  /// Constructs RawBlock instance.
  RawInlineImpl(this._contents);

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  String get contents => _contents;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Default Reference implementation.
class ReferenceImpl extends AstNodeImpl implements Reference {
  final String _reference;
  final Target _target;

  /// Constructs Reference instance.
  ReferenceImpl(this._reference, this._target);

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  String get reference => _reference;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}

  @override
  Target get target => _target;

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitReference(this);
}

/// Default ReferenceImage implementation.
class ReferenceImageImpl extends ImageImpl implements ReferenceImage {
  final Reference _reference;

  final ExtendedAttributes _attributes;

  /// Constructs ReferenceImage instance.
  ReferenceImageImpl(
      Iterable<InlineNode> contents, this._reference, this._attributes)
      : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitReferenceImage(this);

  @override
  Reference get reference => _reference;

  @override
  ExtendedAttributes get attributes => _attributes;

  @override
  String get link => _reference?.target?.link;

  @override
  String get title => _reference?.target?.title;
}

/// Default ReferenceLink implementation.
class ReferenceLinkImpl extends LinkImpl implements ReferenceLink {
  final ExtendedAttributes _attributes;

  final Reference _reference;

  /// Constructs ReferenceLink instance.
  ReferenceLinkImpl(
      Iterable<InlineNode> contents, this._reference, this._attributes)
      : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitReferenceLink(this);

  @override
  ExtendedAttributes get attributes => _attributes;

  @override
  Reference get reference => _reference;

  @override
  String get link => _reference?.target?.link;

  @override
  String get title => _reference?.target?.title;
}

/// Default SmartChar implementation.
class SmartCharImpl extends CharImpl implements SmartChar {
  final SmartCharType _type;

  /// Constructs SmartChar instance.
  SmartCharImpl(this._type);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitSmartChar(this);

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  SmartCharType get type => _type;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Default HardLineBreak implementation.
class SoftLineBreakImpl extends InlineNodeImpl implements SoftLineBreak {
  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitSoftLineBreak(this);

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Default Space implementation.
class SpaceImpl extends WhitespaceImpl implements Space {
  /// Constructs Space instance.
  SpaceImpl(int amount) : super(amount);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitSpace(this);
}

/// Default Str implementation.
class StrImpl extends InlineNodeImpl implements Str {
  final CodeUnitsList _contents;

  /// Constructs Str instance.
  StrImpl(this._contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitStr(this);

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  CodeUnitsList get contents => _contents;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Default Strikeout implementation.
class StrikeoutImpl extends CompositeInlineImpl implements Strikeout {
  /// Constructs Strikeout instance.
  StrikeoutImpl(Iterable<InlineNode> contents) : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitStrikeout(this);
}

/// Default Strong implementation.
class StrongImpl extends CompositeInlineImpl implements Strong {
  /// Constructs Strong instance.
  StrongImpl(Iterable<InlineNode> contents) : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitStrong(this);
}

/// Default Subscript implementation.
class SubscriptImpl extends CompositeInlineImpl implements Subscript {
  /// Constructs Subscript instance.
  SubscriptImpl(Iterable<InlineNode> contents) : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitSubscript(this);
}

/// Default Superscript implementation.
class SuperscriptImpl extends CompositeInlineImpl implements Superscript {
  /// Constructs Superscript implementation.
  SuperscriptImpl(Iterable<InlineNode> contents) : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitSuperscript(this);
}

/// Default Tab implementation.
class TabImpl extends WhitespaceImpl implements Tab {
  /// Constructs Tab instance.
  TabImpl(int amount) : super(amount);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitTab(this);
}

/// Default Table implementation
class TableImpl extends BlockNodeImpl implements Table {
  final List<Alignment> _alignment;
  final BaseInline _caption;
  NodeList<TableRowImpl> _contents;
  NodeList<TableCellImpl> _headers;

  /// Constructs Table instance
  factory TableImpl(
          List<Alignment> alignment,
          BaseInline caption,
          Iterable<TableCell> headers,
          Iterable<Iterable<TableCell>> contents) =>
      new TableImpl.rows(alignment, caption, headers,
          contents.map((Iterable<TableCell> item) => new TableRowImpl(item)));

  /// Constructs Table instance from rows
  TableImpl.rows(this._alignment, this._caption, Iterable<TableCell> headers,
      Iterable<TableRow> contents) {
    _headers = new NodeListImpl<TableCellImpl>(this, headers);
    _contents = new NodeListImpl<TableRowImpl>(this, contents);
  }

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitTable(this);

  @override
  List<Alignment> get alignment => _alignment;

  @override
  BaseInline get caption => _caption;

  @override
  Iterable<AstNode> get childEntities {
    final List<AstNode> result = <AstNode>[_caption]
      ..addAll(_headers)
      ..addAll(_contents);
    return result;
  }

  @override
  NodeList<TableRow> get contents => _contents;

  @override
  NodeList<TableCell> get headers => _headers;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _caption.accept(visitor);
    _headers.accept(visitor);
    _contents.accept(visitor);
  }
}

/// Default TableCell implementation
class TableCellImpl extends AstNodeImpl implements TableCell {
  /// Cell contents.
  NodeList<BlockNodeImpl> _contents;

  /// Constructs instance of TableCell.
  TableCellImpl(Iterable<BlockNodeImpl> contents) {
    _contents = new NodeListImpl<BlockNodeImpl>(this, contents);
  }

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitTableCell(this);

  @override
  Iterable<AstNode> get childEntities => _contents;

  @override
  NodeList<BlockNode> get contents => _contents;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _contents?.accept<R>(visitor);
  }
}

/// Default TableRow implementation.
class TableRowImpl extends AstNodeImpl implements TableRow {
  NodeList<TableCellImpl> _contents;

  /// Constructs instance of TableRow.
  TableRowImpl(Iterable<TableCellImpl> contents) {
    _contents = new NodeListImpl<TableCellImpl>(this, contents);
  }

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitTableRow(this);

  @override
  Iterable<AstNode> get childEntities => _contents;

  @override
  NodeList<TableCell> get contents => _contents;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    _contents.accept(visitor);
  }
}

/// Default Target implementation.
class TargetImpl extends AstNodeImpl implements Target {
  final String _link;
  String _title;

  /// Constructs Target instance.
  TargetImpl(this._link, this._title);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitTarget(this);

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  String get link => _link;

  @override
  String get title => _title;

  set title(String title) {
    _title = title;
  }

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Default TexMath implementation.
abstract class TexMathImpl extends TexRawInlineImpl implements TexMath {
  /// Constructs TexMath instance.
  TexMathImpl(String contents) : super(contents);
}

/// Default TexMathDisplay implementation.
class TexMathDisplayImpl extends TexMathImpl implements TexMathDisplay {
  /// Constructs TexMathDisplay instance.
  TexMathDisplayImpl(String contents) : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitTexMathDisplay(this);
}

/// Default TexMathInline implementation.
class TexMathInlineImpl extends TexMathImpl implements TexMathInline {
  /// Constructs TexMathInline instance.
  TexMathInlineImpl(String contents) : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitTexMathInline(this);
}

/// Default TexRawBlock implementation.
class TexRawBlockImpl extends RawBlockImpl implements TexRawBlock {
  /// Constructs TexRawBlock instance.
  TexRawBlockImpl(String contents) : super(contents);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitTexRawBlock(this);
}

/// Default TexRawInline implementation.
abstract class TexRawInlineImpl extends RawInlineImpl implements TexRawInline {
  /// Constructs TexRawInline instance.
  TexRawInlineImpl(String contents) : super(contents);
}

/// Default ThematicBreak implementation.
class ThematicBreakImpl extends BlockNodeImpl implements ThematicBreak {
  /// Constructs ThematicBreak instance.
  ThematicBreakImpl();

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitThematicBreak(this);

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Default UnorderedList implementation.
class UnorderedListImpl extends ListBlockImpl implements UnorderedList {
  final BulletType _bulletType;

  /// Constructs OrderedList instance.
  UnorderedListImpl(Iterable<ListItem> items, bool tight, this._bulletType)
      : super(items, tight);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitUnorderedList(this);

  @override
  BulletType get bulletType => _bulletType;
}

/// Default Whitespace implementation.
abstract class WhitespaceImpl extends CharImpl implements Whitespace {
  final int _amount;

  /// Constructs Whitespace instance.
  WhitespaceImpl(this._amount);

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  int get amount => _amount;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Default NodeList implementation
class NodeListImpl<E extends AstNode> extends ListBase<E>
    implements NodeList<E> {
  /// The node that is the parent of each of the elements in the list.
  AstNodeImpl _owner;

  /// The elements contained in the list.
  List<E> _elements = <E>[];

  /// Initialize a newly created list of nodes such that all of the nodes that
  /// are added to the list will have their parent set to the given [owner]. The
  /// list will initially be populated with the given [elements].
  NodeListImpl(this._owner, [Iterable<E> elements]) {
    addAll(elements);
  }

  @override
  AstNode get owner => _owner;

  @override
  int get length => _elements.length;

  @deprecated // Never intended for public use.
  @override
  set length(int newLength) {
    throw new UnsupportedError("Cannot resize NodeList.");
  }

  @override
  E operator [](int index) {
    if (index < 0 || index >= _elements.length) {
      throw new RangeError("Index: $index, Size: ${_elements.length}");
    }
    return _elements[index];
  }

  @override
  void operator []=(int index, E node) {
    if (index < 0 || index >= _elements.length) {
      throw new RangeError("Index: $index, Size: ${_elements.length}");
    }
    _owner._becomeParentOf(node as AstNodeImpl);
    _elements[index] = node;
  }

  @override
  R accept<R>(AstVisitor<R> visitor) {
    for (E element in _elements) {
      element.accept(visitor);
    }

    return null;
  }

  @override
  void add(E node) {
    insert(length, node);
  }

  @override
  bool addAll(Iterable<E> nodes) {
    if (nodes != null && nodes.isNotEmpty) {
      for (E node in nodes) {
        _elements.add(node);
        _owner._becomeParentOf(node as AstNodeImpl);
      }
      return true;
    }
    return false;
  }

  @override
  void clear() {
    _elements = <E>[];
  }

  @override
  void insert(int index, E node) {
    final int length = _elements.length;
    if (index < 0 || index > length) {
      throw new RangeError("Index: $index, Size: ${_elements.length}");
    }
    _owner._becomeParentOf(node as AstNodeImpl);
    if (index + 1 == length) {
      _elements.add(node);
    } else {
      _elements.insert(index, node);
    }
  }

  @override
  E removeAt(int index) {
    if (index < 0 || index >= _elements.length) {
      throw new RangeError("Index: $index, Size: ${_elements.length}");
    }
    final E removedNode = _elements[index];
    _elements.removeAt(index);
    return removedNode;
  }
}
