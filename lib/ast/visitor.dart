library mdown.ast.visitor;

import 'ast.dart';

/// An AST visitor that will do nothing when visiting an AST node. It is
/// intended to be a superclass for classes that use the visitor pattern
/// primarily as a dispatch mechanism (and hence don't need to recursively visit
/// a whole structure) and that only need to visit a small number of node types.
class SimpleAstVisitor<R> implements AstVisitor<R> {
  @override
  R visitAutolink(Autolink node) => null;

  @override
  R visitAutolinkEmail(AutolinkEmail node) => null;

  @override
  R visitBaseCompositeInline(BaseCompositeInline node) => null;

  @override
  R visitBlockquote(Blockquote node) => null;

  @override
  R visitClassAttribute(ClassAttribute node) => null;

  @override
  R visitCode(Code node) => null;

  @override
  R visitCodeBlock(CodeBlock node) => null;

  @override
  R visitDocument(Document node) => null;

  @override
  R visitEmphasis(Emphasis node) => null;

  @override
  R visitExtendedAttributes(ExtendedAttributes node) => null;

  @override
  R visitHardLineBreak(HardLineBreak node) => null;

  @override
  R visitHeading(Heading node) => null;

  @override
  R visitHtmlRawBlock(HtmlRawBlock node) => null;

  @override
  R visitHtmlRawInline(HtmlRawInline node) => null;

  @override
  R visitIdentifierAttribute(IdentifierAttribute node) => null;

  @override
  R visitInfoString(InfoString node) => null;

  @override
  R visitInlineImage(InlineImage node) => null;

  @override
  R visitInlineLink(InlineLink node) => null;

  @override
  R visitKeyValueAttribute(KeyValueAttribute node) => null;

  @override
  R visitLinkReference(LinkReference node) => null;

  @override
  R visitListItem(ListItem node) => null;

  @override
  R visitNonBreakableSpace(NonBreakableSpace node) => null;

  @override
  R visitOrderedList(OrderedList node) => null;

  @override
  R visitPara(Para node) => null;

  @override
  R visitReference(Reference node) => null;

  @override
  R visitReferenceImage(ReferenceImage node) => null;

  @override
  R visitReferenceLink(ReferenceLink node) => null;

  @override
  R visitSmartChar(SmartChar node) => null;

  @override
  R visitSoftLineBreak(SoftLineBreak node) => null;

  @override
  R visitSpace(Space node) => null;

  @override
  R visitStr(Str node) => null;

  @override
  R visitStrikeout(Strikeout node) => null;

  @override
  R visitStrong(Strong node) => null;

  @override
  R visitSubscript(Subscript node) => null;

  @override
  R visitSuperscript(Superscript node) => null;

  @override
  R visitTab(Tab node) => null;

  @override
  R visitTable(Table node) => null;

  @override
  R visitTableCell(TableCell node) => null;

  @override
  R visitTableRow(TableRow node) => null;

  @override
  R visitTarget(Target node) => null;

  @override
  R visitTexMathDisplay(TexMathDisplay node) => null;

  @override
  R visitTexMathInline(TexMathInline node) => null;

  @override
  R visitTexRawBlock(TexRawBlock node) => null;

  @override
  R visitThematicBreak(ThematicBreak node) => null;

  @override
  R visitUnorderedList(UnorderedList node) => null;
}

/// An AST visitor that will recursively visit all of the nodes in an AST
/// structure. For example, using an instance of this class to visit
/// a [BlockNode] will also cause all of the statements in the block to be
/// visited.
///
/// Subclasses that override a visit method must either invoke the overridden
/// visit method or must explicitly ask the visited node to visit its children.
/// Failure to do so will cause the children of the visited node to not be
/// visited.
///
/// Clients may extend or implement this class.
class RecursiveAstVisitor<R> implements AstVisitor<R> {
  @override
  R visitAutolink(Autolink node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitAutolinkEmail(AutolinkEmail node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitBaseCompositeInline(BaseCompositeInline node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitBlockquote(Blockquote node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitClassAttribute(ClassAttribute node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitCode(Code node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitCodeBlock(CodeBlock node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitDocument(Document node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitEmphasis(Emphasis node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitExtendedAttributes(ExtendedAttributes node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitHardLineBreak(HardLineBreak node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitHeading(Heading node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitHtmlRawBlock(HtmlRawBlock node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitHtmlRawInline(HtmlRawInline node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitIdentifierAttribute(IdentifierAttribute node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitInfoString(InfoString node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitInlineImage(InlineImage node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitInlineLink(InlineLink node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitKeyValueAttribute(KeyValueAttribute node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitLinkReference(LinkReference node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitListItem(ListItem node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitNonBreakableSpace(NonBreakableSpace node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitOrderedList(OrderedList node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitPara(Para node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitReference(Reference node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitReferenceImage(ReferenceImage node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitReferenceLink(ReferenceLink node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitSmartChar(SmartChar node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitSoftLineBreak(SoftLineBreak node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitSpace(Space node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitStr(Str node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitStrikeout(Strikeout node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitStrong(Strong node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitSubscript(Subscript node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitSuperscript(Superscript node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitTab(Tab node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitTable(Table node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitTableCell(TableCell node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitTableRow(TableRow node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitTarget(Target node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitTexMathDisplay(TexMathDisplay node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitTexMathInline(TexMathInline node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitTexRawBlock(TexRawBlock node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitThematicBreak(ThematicBreak node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitUnorderedList(UnorderedList node) {
    node.visitChildren(this);
    return null;
  }
}

/// An AST visitor that will recursively visit all of the nodes in an AST
/// structure (like instances of the class [RecursiveAstVisitor]). In addition,
/// when a node of a specific type is visited not only will the visit method for
/// that specific type of node be invoked, but additional methods for the
/// superclasses of that node will also be invoked. For example, using an
/// instance of this class to visit a [BaseCompositeInline] will cause the
/// method [visitBaseCompositeInline] to be invoked but will also cause the
/// methods [visitCompositeInline], [visitInlineNode], [visitNode] to be
/// subsequently invoked.
///
/// Subclasses that override a visit method must either invoke the overridden
/// visit method or explicitly invoke the more general visit method. Failure to
/// do so will cause the visit methods for superclasses of the node to not be
/// invoked and will cause the children of the visited node to not be visited.
///
/// Clients may extend or implement this class.
class GeneralizingAstVisitor<R> implements AstVisitor<R> {
  R visitAttribute(Attribute node) => visitNode(node);

  R visitAttributes(Attributes node) => visitNode(node);

  @override
  R visitAutolink(Autolink node) => visitLink(node);

  @override
  R visitAutolinkEmail(AutolinkEmail node) => visitAutolink(node);

  @override
  R visitBaseCompositeInline(BaseCompositeInline node) =>
      visitCompositeInline(node);

  R visitBlockNode(BlockNode node) => visitNode(node);

  @override
  R visitBlockquote(Blockquote node) => visitBlockNode(node);

  R visitChar(Char node) => visitInlineNode(node);

  @override
  R visitClassAttribute(ClassAttribute node) => visitAttribute(node);

  @override
  R visitCode(Code node) => visitInlineNode(node);

  @override
  R visitCodeBlock(CodeBlock node) => visitBlockNode(node);

  R visitCompositeInline(CompositeInline node) => visitInlineNode(node);

  @override
  R visitDocument(Document node) => visitNode(node);

  @override
  R visitEmphasis(Emphasis node) => visitCompositeInline(node);

  @override
  R visitExtendedAttributes(ExtendedAttributes node) => visitAttributes(node);

  @override
  R visitHardLineBreak(HardLineBreak node) => visitInlineNode(node);

  @override
  R visitHeading(Heading node) => visitBlockNode(node);

  @override
  R visitHtmlRawBlock(HtmlRawBlock node) => visitRawBlock(node);

  @override
  R visitHtmlRawInline(HtmlRawInline node) => visitRawInline(node);

  @override
  R visitIdentifierAttribute(IdentifierAttribute node) => visitAttribute(node);

  R visitImage(Image node) => visitCompositeInline(node);

  @override
  R visitInfoString(InfoString node) => visitAttributes(node);

  @override
  R visitInlineImage(InlineImage node) => visitImage(node);

  @override
  R visitInlineLink(InlineLink node) => visitLink(node);

  R visitInlineNode(InlineNode node) => visitNode(node);

  @override
  R visitKeyValueAttribute(KeyValueAttribute node) => visitAttribute(node);

  R visitLink(Link node) => visitCompositeInline(node);

  @override
  R visitLinkReference(LinkReference node) => visitBlockNode(node);

  R visitListBlock(ListBlock node) => visitBlockNode(node);

  @override
  R visitListItem(ListItem node) => visitNode(node);

  R visitNode(AstNode node) {
    node.visitChildren<R>(this);
    return null;
  }

  @override
  R visitNonBreakableSpace(NonBreakableSpace node) => visitWhitespace(node);

  @override
  R visitOrderedList(OrderedList node) => visitListBlock(node);

  @override
  R visitPara(Para node) => visitBlockNode(node);

  R visitRawBlock(RawBlock node) => visitBlockNode(node);

  R visitRawInline(RawInline node) => visitInlineNode(node);

  @override
  R visitReference(Reference node) => visitNode(node);

  @override
  R visitReferenceImage(ReferenceImage node) => visitImage(node);

  @override
  R visitReferenceLink(ReferenceLink node) => visitLink(node);

  @override
  R visitSmartChar(SmartChar node) => visitChar(node);

  @override
  R visitSoftLineBreak(SoftLineBreak node) => visitInlineNode(node);

  @override
  R visitSpace(Space node) => visitWhitespace(node);

  @override
  R visitStr(Str node) => visitInlineNode(node);

  @override
  R visitStrikeout(Strikeout node) => visitCompositeInline(node);

  @override
  R visitStrong(Strong node) => visitCompositeInline(node);

  @override
  R visitSubscript(Subscript node) => visitCompositeInline(node);

  @override
  R visitSuperscript(Superscript node) => visitCompositeInline(node);

  @override
  R visitTab(Tab node) => visitWhitespace(node);

  @override
  R visitTable(Table node) => visitBlockNode(node);

  @override
  R visitTableCell(TableCell node) => visitNode(node);

  @override
  R visitTableRow(TableRow node) => visitNode(node);

  @override
  R visitTarget(Target node) => visitNode(node);

  R visitTexMath(TexMath node) => visitTexRawInline(node);

  @override
  R visitTexMathDisplay(TexMathDisplay node) => visitTexMath(node);

  @override
  R visitTexMathInline(TexMathInline node) => visitTexMath(node);

  @override
  R visitTexRawBlock(TexRawBlock node) => visitRawBlock(node);

  R visitTexRawInline(TexRawInline node) => visitRawInline(node);

  @override
  R visitThematicBreak(ThematicBreak node) => visitBlockNode(node);

  @override
  R visitUnorderedList(UnorderedList node) => visitListBlock(node);

  R visitWhitespace(Whitespace node) => visitChar(node);
}

/// An AST visitor that will recursively visit all of the nodes in an AST
/// structure (like instances of the class [RecursiveAstVisitor]). In addition,
/// every node will also be visited by using a single unified [visitNode]
/// method.
///
/// Subclasses that override a visit method must either invoke the overridden
/// visit method or explicitly invoke the more general [visitNode] method.
/// Failure to do so will cause the children of the visited node to not be
/// visited.
///
/// Clients may extend or implement this class.
class UnifyingAstVisitor<R> implements AstVisitor<R> {
  @override
  R visitAutolink(Autolink node) => visitNode(node);

  @override
  R visitAutolinkEmail(AutolinkEmail node) => visitNode(node);

  @override
  R visitBaseCompositeInline(BaseCompositeInline node) => visitNode(node);

  @override
  R visitBlockquote(Blockquote node) => visitNode(node);

  @override
  R visitClassAttribute(ClassAttribute node) => visitNode(node);

  @override
  R visitCode(Code node) => visitNode(node);

  @override
  R visitCodeBlock(CodeBlock node) => visitNode(node);

  @override
  R visitDocument(Document node) => visitNode(node);

  @override
  R visitEmphasis(Emphasis node) => visitNode(node);

  @override
  R visitExtendedAttributes(ExtendedAttributes node) => visitNode(node);

  @override
  R visitHardLineBreak(HardLineBreak node) => visitNode(node);

  @override
  R visitHeading(Heading node) => visitNode(node);

  @override
  R visitHtmlRawBlock(HtmlRawBlock node) => visitNode(node);

  @override
  R visitHtmlRawInline(HtmlRawInline node) => visitNode(node);

  @override
  R visitIdentifierAttribute(IdentifierAttribute node) => visitNode(node);

  @override
  R visitInfoString(InfoString node) => visitNode(node);

  @override
  R visitInlineImage(InlineImage node) => visitNode(node);

  @override
  R visitInlineLink(InlineLink node) => visitNode(node);

  @override
  R visitKeyValueAttribute(KeyValueAttribute node) => visitNode(node);

  @override
  R visitLinkReference(LinkReference node) => visitNode(node);

  @override
  R visitListItem(ListItem node) => visitNode(node);

  R visitNode(AstNode node) {
    node.visitChildren(this);
    return null;
  }

  @override
  R visitNonBreakableSpace(NonBreakableSpace node) => visitNode(node);

  @override
  R visitOrderedList(OrderedList node) => visitNode(node);

  @override
  R visitPara(Para node) => visitNode(node);

  @override
  R visitReference(Reference node) => visitNode(node);

  @override
  R visitReferenceImage(ReferenceImage node) => visitNode(node);

  @override
  R visitReferenceLink(ReferenceLink node) => visitNode(node);

  @override
  R visitSmartChar(SmartChar node) => visitNode(node);

  @override
  R visitSoftLineBreak(SoftLineBreak node) => visitNode(node);

  @override
  R visitSpace(Space node) => visitNode(node);

  @override
  R visitStr(Str node) => visitNode(node);

  @override
  R visitStrikeout(Strikeout node) => visitNode(node);

  @override
  R visitStrong(Strong node) => visitNode(node);

  @override
  R visitSubscript(Subscript node) => visitNode(node);

  @override
  R visitSuperscript(Superscript node) => visitNode(node);

  @override
  R visitTab(Tab node) => visitNode(node);

  @override
  R visitTable(Table node) => visitNode(node);

  @override
  R visitTableCell(TableCell node) => visitNode(node);

  @override
  R visitTableRow(TableRow node) => visitNode(node);

  @override
  R visitTarget(Target node) => visitNode(node);

  @override
  R visitTexMathDisplay(TexMathDisplay node) => visitNode(node);

  @override
  R visitTexMathInline(TexMathInline node) => visitNode(node);

  @override
  R visitTexRawBlock(TexRawBlock node) => visitNode(node);

  @override
  R visitThematicBreak(ThematicBreak node) => visitNode(node);

  @override
  R visitUnorderedList(UnorderedList node) => visitNode(node);
}
