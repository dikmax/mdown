library mdown.src.parsers.container;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/options.dart';
import 'package:mdown/src/parsers/attributes.dart';
import 'package:mdown/src/parsers/atx_heading.dart';
import 'package:mdown/src/parsers/autolink.dart';
import 'package:mdown/src/parsers/blankline.dart';
import 'package:mdown/src/parsers/blockquote_list.dart';
import 'package:mdown/src/parsers/document.dart';
import 'package:mdown/src/parsers/ellipsis.dart';
import 'package:mdown/src/parsers/entity.dart';
import 'package:mdown/src/parsers/escapes.dart';
import 'package:mdown/src/parsers/fenced_code.dart';
import 'package:mdown/src/parsers/hard_line_break.dart';
import 'package:mdown/src/parsers/html_block.dart';
import 'package:mdown/src/parsers/html_block_7.dart';
import 'package:mdown/src/parsers/indented_code.dart';
import 'package:mdown/src/parsers/inline_code.dart';
import 'package:mdown/src/parsers/inline_html.dart';
import 'package:mdown/src/parsers/inline_structure.dart';
import 'package:mdown/src/parsers/line.dart';
import 'package:mdown/src/parsers/link_image.dart';
import 'package:mdown/src/parsers/link_reference.dart';
import 'package:mdown/src/parsers/mn_dash.dart';
import 'package:mdown/src/parsers/para_setext_heading.dart';
import 'package:mdown/src/parsers/raw_tex.dart';
import 'package:mdown/src/parsers/str.dart';
import 'package:mdown/src/parsers/tex_math_dollars.dart';
import 'package:mdown/src/parsers/tex_math_double_backslash.dart';
import 'package:mdown/src/parsers/tex_math_single_backslash.dart';
import 'package:mdown/src/parsers/thematic_break.dart';

/// Simple DI container
class ParsersContainer {
  /// Parser options.
  Options options;

  /// Map with references.
  Map<String, LinkReference> references;

  /// Line parser.
  LineParser lineParser;

  /// Parser for attributes string `{#id .class}`
  ExtendedAttributesParser attributesParser;

  /// Parser for blankline.
  BlanklineParser blanklineParser;

  /// Parser for blockquotes and lists.
  BlockquoteListParser blockquoteListParser;

  /// Parser for atx-headings.
  AtxHeadingParser atxHeadingParser;

  /// Parser for indented code blocks.
  IndentedCodeParser indentedCodeParser;

  /// Parser for fenced code blocks.
  FencedCodeParser fencedCodeParser;

  /// Parser for paragraphs and setext-headings.
  ParaSetextHeadingParser paraSetextHeadingParser;

  /// Parser for thematic breaks.
  ThematicBreakParser thematicBreakParser;

  /// Parser for html blocks.
  HtmlBlockParser htmlBlockParser;

  /// Parser for html blocks using rule 7 from specification.
  HtmlBlock7Parser htmlBlock7Parser;

  /// Parser for raw TeX blocks
  RawTexParser rawTexParser;

  /// Parser for link references.
  LinkReferenceParser linkReferenceParser;

  /// Parser for escaped chars.
  EscapesParser escapesParser;

  /// Parser for html-entities.
  EntityParser entityParser;

  /// Parser for hard line breaks.
  HardLineBreakParser hardLineBreakParser;

  /// Parser for inline code blocks.
  InlineCodeParser inlineCodeParser;

  /// Parser for emphasises, strongs and other inline structures with
  /// nested inlines.
  InlineStructureParser inlineStructureParser;

  /// Parser for links and images.
  LinkImageParser linkImageParser;

  /// Parser for autolinks.
  AutolinkParser autolinkParser;

  /// Parser for inline html.
  InlineHtmlParser inlineHtmlParser;

  /// Parser for ellipsis.
  EllipsisParser ellipsisParser;

  /// Parser for mdash and ndash.
  MNDashParser mnDashParser;

  /// Parser for TeX Math between dollars.
  TexMathDollarsParser texMathDollarsParser;

  /// Parser for TeX Math between `\[...\]` and `\(...\)`.
  TexMathSingleBackslashParser texMathSingleBackslashParser;

  /// Parser for TeX Math between `\\[...\\]` and `\\(...\\)`.
  TexMathDoubleBackslashParser texMathDoubleBackslashParser;

  /// Parser for arbitrary strings.
  StrParser strParser;

  /// Parser for whole document.
  DocumentParser documentParser;

  /// Constructor.
  ParsersContainer(this.options) {
    lineParser = new LineParser(this);
    attributesParser = new ExtendedAttributesParser(this);

    // Block parsers
    atxHeadingParser = new AtxHeadingParser(this);
    blanklineParser = new BlanklineParser(this);
    blockquoteListParser = new BlockquoteListParser(this);
    fencedCodeParser = new FencedCodeParser(this);
    indentedCodeParser = new IndentedCodeParser(this);
    linkReferenceParser = new LinkReferenceParser(this);
    paraSetextHeadingParser = new ParaSetextHeadingParser(this);
    thematicBreakParser = new ThematicBreakParser(this);
    htmlBlockParser = new HtmlBlockParser(this);
    htmlBlock7Parser = new HtmlBlock7Parser(this);
    rawTexParser = new RawTexParser(this);

    // Inline parsers
    escapesParser = new EscapesParser(this);
    entityParser = new EntityParser(this);
    hardLineBreakParser = new HardLineBreakParser(this);
    inlineCodeParser = new InlineCodeParser(this);
    inlineStructureParser = new InlineStructureParser(this);
    linkImageParser = new LinkImageParser(this);
    autolinkParser = new AutolinkParser(this);
    inlineHtmlParser = new InlineHtmlParser(this);
    ellipsisParser = new EllipsisParser(this);
    mnDashParser = new MNDashParser(this);
    texMathDollarsParser = new TexMathDollarsParser(this);
    texMathSingleBackslashParser = new TexMathSingleBackslashParser(this);
    texMathDoubleBackslashParser = new TexMathDoubleBackslashParser(this);
    strParser = new StrParser(this);

    // Document
    documentParser = new DocumentParser(this);

    // All parsers are instantiated, they should be linked with each other.
    // There's [AbstractParser.init] for it.

    lineParser.init();
    attributesParser.init();

    // Block parsers
    atxHeadingParser.init();
    blanklineParser.init();
    blockquoteListParser.init();
    fencedCodeParser.init();
    indentedCodeParser.init();
    linkReferenceParser.init();
    paraSetextHeadingParser.init();
    thematicBreakParser.init();
    htmlBlockParser.init();
    htmlBlock7Parser.init();
    rawTexParser.init();

    // Inline parsers
    escapesParser.init();
    entityParser.init();
    hardLineBreakParser.init();
    inlineCodeParser.init();
    inlineStructureParser.init();
    linkImageParser.init();
    autolinkParser.init();
    inlineHtmlParser.init();
    ellipsisParser.init();
    mnDashParser.init();
    texMathDollarsParser.init();
    texMathSingleBackslashParser.init();
    texMathDoubleBackslashParser.init();
    strParser.init();

    // Document
    documentParser.init();
  }
}
