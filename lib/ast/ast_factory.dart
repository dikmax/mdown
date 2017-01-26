library mdown.ast.ast_factory;

import 'dart:core';

import 'ast.dart';

/// A collection of factory methods which may be used to create concrete
/// instances of the interfaces that constitute the AST.
///
/// Clients should not extend, implement or mix-in this class.
abstract class AstFactory {
  /// Creates autolink with [link] as a target.
  Autolink autolink(String link);

  /// Creates email autolink with [email] as a target.
  AutolinkEmail autolinkEmail(String email);

  /// Creates base composite inline.
  BaseCompositeInline baseCompositeInline(Iterable<InlineNode> contents);

  /// Creates blockquote.
  Blockquote blockquote(Iterable<BlockNode> contents);

  /// Creates attribute with [className] class.
  ClassAttribute classAttribute(String className);

  /// Creates inline code
  Code code(String contents, int fenceSize, ExtendedAttributes attributes);

  /// Creates code block.
  CodeBlock codeBlock(Iterable<String> contents, Attributes attributes);

  /// Creates document.
  Document document(Iterable<BlockNode> contents);

  /// Creates emphasis.
  Emphasis emphasis(Iterable<InlineNode> contents);

  /// Creates extended attributes.
  ExtendedAttributes extendedAttributes(Iterable<Attribute> attributes);

  /// Creates hard line break.
  HardLineBreak hardLineBreak();

  /// Creates heading with [level] and [contents] as contents.
  Heading heading(
      BaseInline contents, int level, ExtendedAttributes attributes);

  /// Creates HTML raw block.
  HtmlRawBlock htmlRawBlock(String contents);

  /// Creates HTML raw inline.
  HtmlRawInline htmlRawInline(String contents);

  /// Creates Identifier attribute.
  IdentifierAttribute identifierAttribute(String identifier);

  /// Creates infostring attribute.
  InfoString infoString(String language);

  /// Creates inline image.
  InlineImage inlineImage(Iterable<InlineNode> contents, Target target,
      ExtendedAttributes attributes);

  /// Creates inline link.
  InlineLink inlineLink(Iterable<InlineNode> contents, Target target,
      ExtendedAttributes attributes);

  /// Creates key-value attribute.
  KeyValueAttribute keyValueAttribute(String key, String value);

  /// Creates link reference block.
  LinkReference linkReference(
      String reference, Target target, ExtendedAttributes attributes);

  /// Creates list item.
  ListItem listItem(Iterable<BlockNode> contents);

  /// Returns a newly created list of nodes such that all of the nodes that
  /// are added to the list will have their parent set to the given [owner]. The
  /// list will initially be populated with the given [elements].
  NodeList<E> nodeList<E extends AstNode>(AstNode owner,
      [Iterable<E> elements]);

  /// Creates sequence of [amount] non breakable spaces.
  NonBreakableSpace nonBreakableSpace(int amount);

  /// Creates ordered list.
  OrderedList orderedList(Iterable<ListItem> items, bool tight, int startIndex,
      IndexSeparator indexSeparator);

  /// Creates paragraph.
  Para para(BaseInline contents);

  /// Creates reference.
  Reference reference(String reference, Target target);

  /// Creates reference image.
  ReferenceImage referenceImage(Iterable<InlineNode> contents,
      Reference reference, ExtendedAttributes attributes);

  /// Creates reference link.
  ReferenceLink referenceLink(Iterable<InlineNode> contents,
      Reference reference, ExtendedAttributes attributes);

  /// Creates smart char.
  SmartChar smartChar(SmartCharType type);

  /// Creates soft line break.
  SoftLineBreak softLineBreak();

  /// Creates sequence of [amount] spaces.
  Space space(int amount);

  /// Creates inline str element.
  Str str(String contents);

  /// Creates strikeout element.
  Strikeout strikeout(Iterable<InlineNode> contents);

  /// Creates strong emphasis.
  Strong strong(Iterable<InlineNode> contents);

  /// Creates subscript inline.
  Subscript subscript(Iterable<InlineNode> contents);

  /// Creates superscript inline.
  Superscript superscript(Iterable<InlineNode> contents);

  /// Creates sequence of [amount] tabs.
  Tab tab(int amount);

  /// Creates table
  Table table(Iterable<Alignment> alignment, BaseInline caption,
      Iterable<TableCell> headers, Iterable<Iterable<TableCell>> contents);

  /// Creates table cell.
  TableCell tableCell(Iterable<BlockNode> contents);

  /// Creates target for link and image.
  Target target(String link, String title);

  /// Creates display TeX math.
  TexMathDisplay texMathDisplay(String contents);

  /// Creates inline TeX math.
  TexMathInline texMathInline(String contents);

  /// Creates TeX raw block.
  TexRawBlock texRawBlock(String contents);

  /// Creates thematic break.
  ThematicBreak thematicBreak();

  /// Creates unordered list.
  UnorderedList unorderedList(
      Iterable<ListItem> items, bool tight, BulletType bulletType);
}
