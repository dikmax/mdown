library mdown.src.ast.replacing_visitor;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/visitor.dart';
import 'package:mdown/src/ast/ast.dart';

class ListReplacingAstVisitor extends UnifyingAstVisitor<List<AstNodeImpl>> {
  ReplacingAstVisitor _outerVisitor;

  set outerVisitor(ReplacingAstVisitor visitor) {
    _outerVisitor = visitor;
  }

  @override
  List<AstNodeImpl> visitNode(AstNode node) {
    final AstNode updatedNode = node.accept(_outerVisitor);
    return node == updatedNode ? null : <AstNodeImpl>[updatedNode];
  }
}

class ReplacingAstVisitor extends AstVisitor<AstNodeImpl> {
  ListReplacingAstVisitor _childVisitor;

  ReplacingAstVisitor([this._childVisitor]) {
    _childVisitor ??= new ListReplacingAstVisitor();
    _childVisitor.outerVisitor = this;
  }

  List<InlineNodeImpl> _visitInlineNodeList(Iterable<InlineNode> list) {
    final List<InlineNodeImpl> result = <InlineNodeImpl>[];
    bool changed = false;
    for (InlineNode child in list) {
      final List<AstNodeImpl> replacement =
          child.accept<List<AstNodeImpl>>(_childVisitor);
      if (replacement == null) {
        result.add(child);
      } else {
        changed = true;
        for (AstNodeImpl node in replacement) {
          // ignore: avoid_as
          result.add(node as InlineNodeImpl);
        }
      }
    }

    return changed ? result : null;
  }

  List<InlineNodeImpl> visitInlineNodeList(Iterable<InlineNode> list) =>
      _visitInlineNodeList(list) ?? list;

  List<BlockNodeImpl> _visitBlockNodeList(Iterable<BlockNode> list) {
    final List<BlockNodeImpl> result = <BlockNodeImpl>[];
    bool changed = false;
    for (BlockNode child in list) {
      final List<AstNodeImpl> replacement =
          child.accept<List<AstNodeImpl>>(_childVisitor);
      if (replacement == null) {
        result.add(child);
      } else {
        changed = true;
        for (AstNodeImpl node in replacement) {
          // ignore: avoid_as
          result.add(node as BlockNodeImpl);
        }
      }
    }

    return changed ? result : null;
  }

  List<TableCellImpl> _visitCellNodeList(Iterable<TableCell> list) {
    final List<TableCellImpl> result = <TableCellImpl>[];
    bool changed = false;
    for (TableCell child in list) {
      final List<AstNodeImpl> replacement =
          child.accept<List<AstNodeImpl>>(_childVisitor);
      if (replacement == null) {
        result.add(child);
      } else {
        changed = true;
        for (AstNodeImpl node in replacement) {
          // ignore: avoid_as
          result.add(node as TableCellImpl);
        }
      }
    }

    return changed ? result : null;
  }

  List<TableRowImpl> _visitRowNodeList(Iterable<TableRow> list) {
    final List<TableRowImpl> result = <TableRowImpl>[];
    bool changed = false;
    for (TableRow child in list) {
      final List<AstNodeImpl> replacement =
          child.accept<List<AstNodeImpl>>(_childVisitor);
      if (replacement == null) {
        result.add(child);
      } else {
        changed = true;
        for (AstNodeImpl node in replacement) {
          // ignore: avoid_as
          result.add(node as TableRowImpl);
        }
      }
    }

    return changed ? result : null;
  }

  List<BlockNodeImpl> visitBlockNodeList(Iterable<BlockNode> list) =>
      _visitBlockNodeList(list) ?? list;

  List<AttributeImpl> _visitAttributeNodeList(Iterable<Attribute> list) {
    final List<AttributeImpl> result = <AttributeImpl>[];
    bool changed = false;
    for (Attribute child in list) {
      final List<AstNodeImpl> replacement =
          child.accept<List<AstNodeImpl>>(_childVisitor);
      if (replacement == null) {
        result.add(child);
      } else {
        changed = true;
        for (AstNodeImpl node in replacement) {
          // ignore: avoid_as
          result.add(node as AttributeImpl);
        }
      }
    }

    return changed ? result : null;
  }

  List<AttributeImpl> visitAttributeNodeList(Iterable<AttributeImpl> list) =>
      _visitAttributeNodeList(list) ?? list;

  List<ListItemImpl> _visitListItemNodeList(Iterable<ListItem> list) {
    final List<ListItemImpl> result = <ListItemImpl>[];
    bool changed = false;
    for (ListItem child in list) {
      final List<AstNodeImpl> replacement =
          child.accept<List<AstNodeImpl>>(_childVisitor);
      if (replacement == null) {
        result.add(child);
      } else {
        changed = true;
        for (AstNodeImpl node in replacement) {
          // ignore: avoid_as
          result.add(node as ListItemImpl);
        }
      }
    }

    return changed ? result : null;
  }

  List<ListItemImpl> visitListItemNodeList(Iterable<ListItem> list) =>
      _visitListItemNodeList(list) ?? list;

  @override
  AutolinkImpl visitAutolink(Autolink node) =>
      // ignore: avoid_as
      node as AutolinkImpl;

  @override
  AutolinkEmailImpl visitAutolinkEmail(AutolinkEmail node) =>
      // ignore: avoid_as
      node as AutolinkEmailImpl;

  @override
  BaseCompositeInlineImpl visitBaseCompositeInline(BaseCompositeInline node) {
    final List<InlineNode> contents = _visitInlineNodeList(node.contents);
    return contents != null ? new BaseCompositeInlineImpl(contents) : node;
  }

  @override
  BlockquoteImpl visitBlockquote(Blockquote node) {
    final List<BlockNodeImpl> contents = _visitBlockNodeList(node.contents);
    return contents != null ? new BlockquoteImpl(contents) : node;
  }

  @override
  ClassAttributeImpl visitClassAttribute(ClassAttribute node) =>
      // ignore: avoid_as
      node as ClassAttributeImpl;

  @override
  CodeImpl visitCode(Code node) {
    final ExtendedAttributes attributes =
        node.attributes?.accept<AstNode>(this);

    return attributes == node.attributes
        ? node
        : new CodeImpl(node.contents, node.fenceSize, attributes);
  }

  @override
  CodeBlockImpl visitCodeBlock(CodeBlock node) {
    final Attributes attributes = node.attributes?.accept<AstNode>(this);

    return attributes == node.attributes
        ? node
        : new CodeBlockImpl(node.contents, attributes);
  }

  @override
  DocumentImpl visitDocument(Document node) {
    final List<BlockNode> contents = _visitBlockNodeList(node.contents);
    return contents != null ? new DocumentImpl(contents) : node;
  }

  @override
  EmphasisImpl visitEmphasis(Emphasis node) {
    final List<InlineNode> contents = _visitInlineNodeList(node.contents);
    return contents != null ? new EmphasisImpl(contents) : node;
  }

  @override
  ExtendedAttributesImpl visitExtendedAttributes(ExtendedAttributes node) {
    final List<Attribute> attributes = _visitAttributeNodeList(node.attributes);
    return attributes != null ? new ExtendedAttributesImpl(attributes) : node;
  }

  @override
  HardLineBreakImpl visitHardLineBreak(HardLineBreak node) =>
      // ignore: avoid_as
      node as HardLineBreakImpl;

  @override
  HeadingImpl visitHeading(Heading node) {
    final BaseInline contents = node.contents.accept<AstNode>(this);
    final ExtendedAttributes attributes =
        node.attributes?.accept<AstNode>(this);

    return contents == node.contents && attributes == node.attributes
        ? node
        : new HeadingImpl(contents, node.level, attributes);
  }

  @override
  HtmlRawBlockImpl visitHtmlRawBlock(HtmlRawBlock node) =>
      // ignore: avoid_as
      node as HtmlRawBlockImpl;

  @override
  HtmlRawInlineImpl visitHtmlRawInline(HtmlRawInline node) =>
      // ignore: avoid_as
      node as HtmlRawInlineImpl;

  @override
  IdentifierAttributeImpl visitIdentifierAttribute(IdentifierAttribute node) =>
      // ignore: avoid_as
      node as IdentifierAttributeImpl;

  @override
  InfoStringImpl visitInfoString(InfoString node) =>
      // ignore: avoid_as
      node as InfoStringImpl;

  @override
  InlineImageImpl visitInlineImage(InlineImage node) {
    final Target target = node.target.accept<AstNode>(this);
    final ExtendedAttributes attributes =
        node.attributes?.accept<AstNode>(this);
    final List<InlineNode> contents = _visitInlineNodeList(node.contents);

    return attributes == node.attributes &&
            target == node.target &&
            contents == null
        ? node
        : new InlineImageImpl(contents ?? node.contents, target, attributes);
  }

  @override
  InlineLinkImpl visitInlineLink(InlineLink node) {
    final Target target = node.target.accept<AstNode>(this);
    final ExtendedAttributes attributes =
        node.attributes?.accept<AstNode>(this);
    final List<InlineNode> contents = _visitInlineNodeList(node.contents);

    return attributes == node.attributes &&
            target == node.target &&
            contents == null
        ? node
        : new InlineLinkImpl(contents ?? node.contents, target, attributes);
  }

  @override
  KeyValueAttributeImpl visitKeyValueAttribute(KeyValueAttribute node) =>
      // ignore: avoid_as
      node as KeyValueAttributeImpl;

  @override
  LinkReferenceImpl visitLinkReference(LinkReference node) {
    final Target target = node.target.accept<AstNode>(this);
    final ExtendedAttributes attributes =
        node.attributes?.accept<AstNode>(this);

    return attributes == node.attributes && target == node.target
        ? node
        : new LinkReferenceImpl(node.reference, target, attributes);
  }

  @override
  ListItemImpl visitListItem(ListItem node) {
    final List<BlockNode> contents = _visitBlockNodeList(node.contents);
    return contents != null ? new ListItemImpl(contents) : node;
  }

  @override
  NonBreakableSpaceImpl visitNonBreakableSpace(NonBreakableSpace node) =>
      // ignore: avoid_as
      node as NonBreakableSpaceImpl;

  @override
  OrderedListImpl visitOrderedList(OrderedList node) {
    final List<ListItem> items = _visitListItemNodeList(node.items);
    return items != null
        ? new OrderedListImpl(
            items, node.tight, node.startIndex, node.indexSeparator)
        : node;
  }

  @override
  ParaImpl visitPara(Para node) {
    final BaseInline contents = node.contents.accept<AstNode>(this);
    return contents == node.contents ? node : new ParaImpl(contents);
  }

  @override
  ReferenceImpl visitReference(Reference node) {
    final Target target = node.target.accept<AstNode>(this);

    return target == node.target
        ? node
        : new ReferenceImpl(node.reference, target);
  }

  @override
  ReferenceImageImpl visitReferenceImage(ReferenceImage node) {
    final Reference reference = node.reference.accept<AstNode>(this);
    final ExtendedAttributes attributes =
        node.attributes?.accept<AstNode>(this);
    final List<InlineNode> contents = _visitInlineNodeList(node.contents);

    return attributes == node.attributes &&
            reference == node.reference &&
            contents == null
        ? node
        : new ReferenceImageImpl(
            contents ?? node.contents, reference, attributes);
  }

  @override
  ReferenceLinkImpl visitReferenceLink(ReferenceLink node) {
    final Reference reference = node.reference.accept<AstNode>(this);
    final ExtendedAttributes attributes =
        node.attributes?.accept<AstNode>(this);
    final List<InlineNode> contents = _visitInlineNodeList(node.contents);

    return attributes == node.attributes &&
            reference == node.reference &&
            contents == null
        ? node
        : new ReferenceLinkImpl(
            contents ?? node.contents, reference, attributes);
  }

  @override
  SmartCharImpl visitSmartChar(SmartChar node) =>
      // ignore: avoid_as
      node as SmartCharImpl;

  @override
  SoftLineBreakImpl visitSoftLineBreak(SoftLineBreak node) =>
      // ignore: avoid_as
      node as SoftLineBreakImpl;

  @override
  SpaceImpl visitSpace(Space node) =>
      // ignore: avoid_as
      node as SpaceImpl;

  @override
  StrImpl visitStr(Str node) =>
      // ignore: avoid_as
      node as StrImpl;

  @override
  StrikeoutImpl visitStrikeout(Strikeout node) {
    final List<InlineNode> contents = _visitInlineNodeList(node.contents);
    return contents != null ? new StrikeoutImpl(contents) : node;
  }

  @override
  StrongImpl visitStrong(Strong node) {
    final List<InlineNode> contents = _visitInlineNodeList(node.contents);
    return contents != null ? new StrongImpl(contents) : node;
  }

  @override
  SubscriptImpl visitSubscript(Subscript node) {
    final List<InlineNode> contents = _visitInlineNodeList(node.contents);
    return contents != null ? new SubscriptImpl(contents) : node;
  }

  @override
  SuperscriptImpl visitSuperscript(Superscript node) {
    final List<InlineNode> contents = _visitInlineNodeList(node.contents);
    return contents != null ? new SuperscriptImpl(contents) : node;
  }

  @override
  TabImpl visitTab(Tab node) =>
      // ignore: avoid_as
      node as TabImpl;

  @override
  TableImpl visitTable(Table node) {
    final BaseInline caption = node.caption?.accept<AstNode>(this);
    final List<TableCell> headers = _visitCellNodeList(node.headers);
    final List<TableRow> contents = _visitRowNodeList(node.contents);
    return caption != node.caption || headers != null || contents != null
        ? new TableImpl.rows(node.alignment, caption, headers ?? node.headers,
            contents ?? node.contents)
        :
        // ignore: avoid_as
        node as TableImpl;
  }

  @override
  TableCellImpl visitTableCell(TableCell node) {
    final List<BlockNodeImpl> contents = _visitBlockNodeList(node.contents);
    return contents != null ? new TableCellImpl(contents) : node;
  }

  @override
  TableRowImpl visitTableRow(TableRow node) {
    final List<TableCellImpl> contents = _visitCellNodeList(node.contents);
    return contents != null
        ? new TableRowImpl(contents)
        :
        // ignore: avoid_as
        node as TableRowImpl;
  }

  @override
  TargetImpl visitTarget(Target node) =>
      // ignore: avoid_as
      node as TargetImpl;

  @override
  TexMathDisplayImpl visitTexMathDisplay(TexMathDisplay node) =>
      // ignore: avoid_as
      node as TexMathDisplayImpl;

  @override
  TexMathInlineImpl visitTexMathInline(TexMathInline node) =>
      // ignore: avoid_as
      node as TexMathInlineImpl;

  @override
  TexRawBlockImpl visitTexRawBlock(TexRawBlock node) =>
      // ignore: avoid_as
      node as TexRawBlockImpl;

  @override
  ThematicBreakImpl visitThematicBreak(ThematicBreak node) =>
      // ignore: avoid_as
      node as ThematicBreakImpl;

  @override
  UnorderedListImpl visitUnorderedList(UnorderedList node) {
    final List<ListItem> items = _visitListItemNodeList(node.items);
    return items != null
        ? new UnorderedListImpl(items, node.tight, node.bulletType)
        : node;
  }
}
