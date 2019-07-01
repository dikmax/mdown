library mdown.src.ast.ast_factory;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/ast_factory.dart';

import 'ast.dart';

/// Standard implementation of AST Factory.
class AstFactoryImpl implements AstFactory {
  @override
  Autolink autolink(String link) => AutolinkImpl(link);

  @override
  AutolinkEmail autolinkEmail(String email) => AutolinkEmailImpl(email);

  @override
  BaseCompositeInline baseCompositeInline(Iterable<InlineNode> contents) =>
      BaseCompositeInlineImpl(contents);

  @override
  Blockquote blockquote(Iterable<BlockNode> contents) =>
      BlockquoteImpl(contents);

  @override
  ClassAttribute classAttribute(String className) =>
      ClassAttributeImpl(className);

  @override
  Code code(String contents, int fenceSize, ExtendedAttributes attributes) =>
      CodeImpl(contents, fenceSize, attributes);

  @override
  Document document(Iterable<BlockNode> contents) => DocumentImpl(contents);

  @override
  Emphasis emphasis(Iterable<InlineNode> contents) => EmphasisImpl(contents);

  @override
  ExtendedAttributes extendedAttributes(Iterable<Attribute> attributes) =>
      ExtendedAttributesImpl(attributes);

  @override
  CodeBlock codeBlock(Iterable<String> contents, Attributes attributes) =>
      CodeBlockImpl(contents, attributes);

  @override
  HardLineBreak hardLineBreak() => HardLineBreakImpl();

  @override
  Heading heading(
          BaseInline contents, int level, ExtendedAttributes attributes) =>
      HeadingImpl(contents, level, attributes);

  @override
  HtmlRawBlock htmlRawBlock(String contents) => HtmlRawBlockImpl(contents);

  @override
  HtmlRawInline htmlRawInline(String contents) => HtmlRawInlineImpl(contents);

  @override
  IdentifierAttribute identifierAttribute(String identifier) =>
      IdentifierAttributeImpl(identifier);

  @override
  InfoString infoString(String language) => InfoStringImpl(language);

  @override
  InlineImage inlineImage(Iterable<InlineNode> contents, Target target,
          ExtendedAttributes attributes) =>
      InlineImageImpl(contents, target, attributes);

  @override
  InlineLink inlineLink(Iterable<InlineNode> contents, Target target,
          ExtendedAttributes attributes) =>
      InlineLinkImpl(contents, target, attributes);

  @override
  KeyValueAttribute keyValueAttribute(String key, String value) =>
      KeyValueAttributeImpl(key, value);

  @override
  LinkReference linkReference(
          String reference, Target target, ExtendedAttributes attributes) =>
      LinkReferenceImpl(reference, target, attributes);

  @override
  ListItem listItem(Iterable<BlockNode> contents) => ListItemImpl(contents);

  @override
  NodeList<E> nodeList<E extends AstNode>(AstNode owner,
          [Iterable<E> elements]) =>
      NodeListImpl<E>(owner, elements);

  @override
  NonBreakableSpace nonBreakableSpace(int amount) =>
      NonBreakableSpaceImpl(amount);

  @override
  OrderedList orderedList(Iterable<ListItem> items, bool tight, int startIndex,
          IndexSeparator indexSeparator) =>
      OrderedListImpl(items, tight, startIndex, indexSeparator);

  @override
  Para para(BaseInline contents) => ParaImpl(contents);

  @override
  Reference reference(String reference, Target target) =>
      ReferenceImpl(reference, target);

  @override
  ReferenceImage referenceImage(Iterable<InlineNode> contents,
          Reference reference, ExtendedAttributes attributes) =>
      ReferenceImageImpl(contents, reference, attributes);

  @override
  ReferenceLink referenceLink(Iterable<InlineNode> contents,
          Reference reference, ExtendedAttributes attributes) =>
      ReferenceLinkImpl(contents, reference, attributes);

  @override
  SmartChar smartChar(SmartCharType type) => SmartCharImpl(type);

  @override
  SoftLineBreak softLineBreak() => SoftLineBreakImpl();

  @override
  Space space(int amount) => SpaceImpl(amount);

  @override
  Str str(String contents) => StrImpl(contents);

  @override
  Strikeout strikeout(Iterable<InlineNode> contents) => StrikeoutImpl(contents);

  @override
  Strong strong(Iterable<InlineNode> contents) => StrongImpl(contents);

  @override
  Subscript subscript(Iterable<InlineNode> contents) => SubscriptImpl(contents);

  @override
  Superscript superscript(Iterable<InlineNode> contents) =>
      SuperscriptImpl(contents);

  @override
  Tab tab(int amount) => TabImpl(amount);

  @override
  Table table(
          Iterable<Alignment> alignment,
          BaseInline caption,
          Iterable<TableCell> headers,
          Iterable<Iterable<TableCell>> contents) =>
      TableImpl(alignment, caption, headers, contents);

  @override
  TableCell tableCell(Iterable<BlockNode> contents) => TableCellImpl(contents);

  @override
  Target target(String link, String title) => TargetImpl(link, title);

  @override
  TexMathDisplay texMathDisplay(String contents) =>
      TexMathDisplayImpl(contents);

  @override
  TexMathInline texMathInline(String contents) => TexMathInlineImpl(contents);

  @override
  TexRawBlock texRawBlock(String contents) => TexRawBlockImpl(contents);

  @override
  ThematicBreak thematicBreak() => ThematicBreakImpl();

  @override
  UnorderedList unorderedList(
          Iterable<ListItem> items, bool tight, BulletType bulletType) =>
      UnorderedListImpl(items, tight, bulletType);
}
