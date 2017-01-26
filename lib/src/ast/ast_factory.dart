library mdown.src.ast.ast_factory;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/ast_factory.dart';

import 'ast.dart';

/// Standard implementation of AST Factory.
class AstFactoryImpl implements AstFactory {
  @override
  Autolink autolink(String link) => new AutolinkImpl(link);

  @override
  AutolinkEmail autolinkEmail(String email) => new AutolinkEmailImpl(email);

  @override
  BaseCompositeInline baseCompositeInline(Iterable<InlineNode> contents) =>
      new BaseCompositeInlineImpl(contents);

  @override
  Blockquote blockquote(Iterable<BlockNode> contents) =>
      new BlockquoteImpl(contents);

  @override
  ClassAttribute classAttribute(String className) =>
      new ClassAttributeImpl(className);

  @override
  Code code(String contents, int fenceSize, ExtendedAttributes attributes) =>
      new CodeImpl(contents, fenceSize, attributes);

  @override
  Document document(Iterable<BlockNode> contents) => new DocumentImpl(contents);

  @override
  Emphasis emphasis(Iterable<InlineNode> contents) =>
      new EmphasisImpl(contents);

  @override
  ExtendedAttributes extendedAttributes(Iterable<Attribute> attributes) =>
      new ExtendedAttributesImpl(attributes);

  @override
  CodeBlock codeBlock(Iterable<String> contents, Attributes attributes) =>
      new CodeBlockImpl(contents, attributes);

  @override
  HardLineBreak hardLineBreak() => new HardLineBreakImpl();

  @override
  Heading heading(
          BaseInline contents, int level, ExtendedAttributes attributes) =>
      new HeadingImpl(contents, level, attributes);

  @override
  HtmlRawBlock htmlRawBlock(String contents) => new HtmlRawBlockImpl(contents);

  @override
  HtmlRawInline htmlRawInline(String contents) =>
      new HtmlRawInlineImpl(contents);

  @override
  IdentifierAttribute identifierAttribute(String identifier) =>
      new IdentifierAttributeImpl(identifier);

  @override
  InfoString infoString(String language) => new InfoStringImpl(language);

  @override
  InlineImage inlineImage(Iterable<InlineNode> contents, Target target,
          ExtendedAttributes attributes) =>
      new InlineImageImpl(contents, target, attributes);

  @override
  InlineLink inlineLink(Iterable<InlineNode> contents, Target target,
          ExtendedAttributes attributes) =>
      new InlineLinkImpl(contents, target, attributes);

  @override
  KeyValueAttribute keyValueAttribute(String key, String value) =>
      new KeyValueAttributeImpl(key, value);

  @override
  LinkReference linkReference(
          String reference, Target target, ExtendedAttributes attributes) =>
      new LinkReferenceImpl(reference, target, attributes);

  @override
  ListItem listItem(Iterable<BlockNode> contents) => new ListItemImpl(contents);

  @override
  NodeList<E> nodeList<E extends AstNode>(AstNode owner,
          [Iterable<E> elements]) =>
      new NodeListImpl<E>(owner, elements);

  @override
  NonBreakableSpace nonBreakableSpace(int amount) =>
      new NonBreakableSpaceImpl(amount);

  @override
  OrderedList orderedList(Iterable<ListItem> items, bool tight, int startIndex,
          IndexSeparator indexSeparator) =>
      new OrderedListImpl(items, tight, startIndex, indexSeparator);

  @override
  Para para(BaseInline contents) => new ParaImpl(contents);

  @override
  Reference reference(String reference, Target target) =>
      new ReferenceImpl(reference, target);

  @override
  ReferenceImage referenceImage(Iterable<InlineNode> contents,
          Reference reference, ExtendedAttributes attributes) =>
      new ReferenceImageImpl(contents, reference, attributes);

  @override
  ReferenceLink referenceLink(Iterable<InlineNode> contents,
          Reference reference, ExtendedAttributes attributes) =>
      new ReferenceLinkImpl(contents, reference, attributes);

  @override
  SmartChar smartChar(SmartCharType type) => new SmartCharImpl(type);

  @override
  SoftLineBreak softLineBreak() => new SoftLineBreakImpl();

  @override
  Space space(int amount) => new SpaceImpl(amount);

  @override
  Str str(String contents) => new StrImpl(contents);

  @override
  Strikeout strikeout(Iterable<InlineNode> contents) =>
      new StrikeoutImpl(contents);

  @override
  Strong strong(Iterable<InlineNode> contents) => new StrongImpl(contents);

  @override
  Subscript subscript(Iterable<InlineNode> contents) =>
      new SubscriptImpl(contents);

  @override
  Superscript superscript(Iterable<InlineNode> contents) =>
      new SuperscriptImpl(contents);

  @override
  Tab tab(int amount) => new TabImpl(amount);

  @override
  Table table(
          Iterable<Alignment> alignment,
          BaseInline caption,
          Iterable<TableCell> headers,
          Iterable<Iterable<TableCell>> contents) =>
      new TableImpl(alignment, caption, headers, contents);

  @override
  TableCell tableCell(Iterable<BlockNode> contents) =>
      new TableCellImpl(contents);

  @override
  Target target(String link, String title) =>
      new TargetImpl(link, title);

  @override
  TexMathDisplay texMathDisplay(String contents) =>
      new TexMathDisplayImpl(contents);

  @override
  TexMathInline texMathInline(String contents) =>
      new TexMathInlineImpl(contents);

  @override
  TexRawBlock texRawBlock(String contents) => new TexRawBlockImpl(contents);

  @override
  ThematicBreak thematicBreak() => new ThematicBreakImpl();

  @override
  UnorderedList unorderedList(
          Iterable<ListItem> items, bool tight, BulletType bulletType) =>
      new UnorderedListImpl(items, tight, bulletType);
}
