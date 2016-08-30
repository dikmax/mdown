part of md_proc.src.parsers;

/// Simple DI container
class ParsersContainer {
  /// Parser options.
  Options options;

  /// Map with references.
  Map<String, Target> references;

  /// Line parser.
  LineParser lineParser;

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

  /// Parser for arbitrary strings.
  StrParser strParser;

  /// Parser for whole document.
  DocumentParser documentParser;

  /// Constructor.
  ParsersContainer(this.options) {
    lineParser = new LineParser(this);

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
    strParser = new StrParser(this);

    // Document
    documentParser = new DocumentParser(this);

    // All parsers are instantiated, they should be linked with each other.
    // There's [AbstractParser.init] for it.

    lineParser.init();

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
    strParser.init();

    // Document
    documentParser.init();
  }
}
