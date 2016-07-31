part of md_proc.src.parsers;

/// Simple DI container
class ParsersContainer {
  Options options;

  Map<String, Target> references;

  LineParser lineParser;
  BlanklineParser blanklineParser;
  BlockquoteListParser blockquoteListParser;
  AtxHeadingParser atxHeadingParser;
  IndentedCodeParser indentedCodeParser;
  FencedCodeParser fencedCodeParser;
  ParaSetextHeadingParser paraSetextHeadingParser;
  ThematicBreakParser thematicBreakParser;
  HtmlBlockParser htmlBlockParser;
  HtmlBlock7Parser htmlBlock7Parser;
  LinkReferenceParser linkReferenceParser;

  EscapesParser escapesParser;
  EntityParser entityParser;
  HardLineBreakParser hardLineBreakParser;
  InlineCodeParser inlineCodeParser;
  InlineStructureParser inlineStructureParser;
  LinkImageParser linkImageParser;
  AutolinkParser autolinkParser;
  InlineHtmlParser inlineHtmlParser;
  StrParser strParser;

  DocumentParser documentParser;

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
    strParser.init();

    // Document
    documentParser.init();
  }
}
