part of markdown;

// TODO recheck all options after implementation
class MarkdownParserOptions {
  /**
   * Pandoc/PHP/MMD style footnotes
   */
  final bool footnotes;

  /**
   * Pandoc-style inline notes
   */
  final bool inlineNotes;

  /**
   * Pandoc title block
   */
  final bool pandocTitleBlock;

  /**
   * YAML metadata block
   */
  final bool yamlMetadataBlock;

  /**
   * Multimarkdown metadata block
   */
  final bool mmdTitleBlock;

  /**
   * Pandoc-style table captions
   */
  final bool tableCaptions;

  /**
   * A paragraph with just an image is a figure
   */
  final bool implicitFigures;

  /**
   * Pandoc-style simple tables
   */
  final bool simpleTables;

  /**
   * Pandoc-style multiline tables
   */
  final bool multilineTables;

  /**
   * Grid tables (pandoc, reST)
   */
  final bool gridTables;

  /**
   * Pipe tables (as in PHP markdown extra)
   */
  final bool pipeTables;

  /**
   * Pandoc/citeproc citations
   */
  final bool citations;

  /**
   * Allow raw TeX (other than math)
   */
  final bool rawTex;

  /**
   * Allow raw HTML
   */
  final bool rawHtml;

  /**
   * TeX math between $..$ or $$..$$
   */
  final bool texMathDollars;

  /**
   * TeX math btw \(..\) \[..\]
   */
  final bool texMathSingleBackslash;

  /**
   * TeX math btw \\(..\\) \\[..\\]
   */
  final bool texMathDoubleBackslash;

  /**
   * Parse LaTeX macro definitions (for math only)
   */
  final bool latexMacros;

  /**
   * Parse fenced code blocks
   */
  final bool fencedCodeBlocks;

  /**
   * Allow attributes on fenced code blocks
   */
  final bool fencedCodeAttributes;

  /**
   * Github style ``` code blocks
   */
  final bool backtickCodeBlocks;

  /**
   * Allow attributes on inline code
   */
  final bool inlineCodeAttributes;

  /**
   * Interpret as markdown inside HTML blocks
   */
  final bool markdownInHtmlBlocks;

  /**
   * Use Div blocks for contents of <div> tags
   */
  final bool nativeDivs;

  /**
   * Use Span inlines for contents of <span>
   */
  final bool nativeSpans;

  /**
   * Interpret text inside HTML as markdown if container has attribute 'markdown'
   */
  final bool markdownAttribute;

  /**
   * Treat a backslash at EOL as linebreak
   */
  final bool escapedLineBreaks;

  /**
   * MMD style reference link attributes
   */
  final bool linkAttributes;

  /**
   * Make all absolute URIs into links
   */
  final bool autolinkBareUrls;

  /**
   * Enable fancy list numbers and delimiters
   */
  final bool fancyLists;

  /**
   * Allow lists without preceding blank
   */
  final bool listsWithoutPrecedingBlankline;

  /**
   * Make start number of ordered list significant
   */
  final bool startnum;

  /**
   * Definition lists as in pandoc, mmd, php
   */
  final bool definitionLists;

  /**
   * Definition lists without space between items
   */
  final bool compactDefinitionLists;

  /**
   * Markdown-style numbered examples
   */
  final bool exampleLists;

  /**
   * Make all non-alphanumerics escapable
   */
  final bool allSymbolsEscapable;

  /**
   * Treat underscore inside word as literal
   */
  final bool intrawordUnderscores;

  /**
   * Require blank line before a blockquote
   */
  final bool blankBeforeBlockquote;

  /**
   * Require blank line before a header
   */
  final bool blankBeforeHeader;

  /**
   * Strikeout using ~~this~~ syntax
   */
  final bool strikeout;

  /**
   * Superscript using ^this^ syntax
   */
  final bool superscript;

  /**
   * Subscript using ~this~ syntax
   */
  final bool subscript;

  /**
   * All newlines become hard line breaks
   */
  final bool hardLineBreaks;

  /**
   * Newlines in paragraphs are ignored
   */
  final bool ignoreLineBreaks;

  /**
   * Enable literate Haskell conventions
   */
  final bool literateHaskell;

  /**
   * Enable literate Haskell conventions
   */
  final bool abbreviations;

  /**
   * Automatic identifiers for headers
   */
  final bool autoIdentifiers;

  /**
   * ascii-only identifiers for headers
   */
  final bool asciiIdentifiers;

  /**
   * Explicit header attributes {#id .class k=v}
   */
  final bool headerAttributes;

  /**
   * Multimarkdown style header identifiers [myid]
   */
  final bool mmdHeaderIdentifiers;

  /**
   * Implicit reference links for headers
   */
  final bool implicitHeaderReferences;

  /**
   * RST style line blocks
   */
  final bool lineBlocks;

  const MarkdownParserOptions({
                              this.footnotes: false,
                              this.inlineNotes: false,
                              this.pandocTitleBlock: false,
                              this.yamlMetadataBlock: false,
                              this.mmdTitleBlock: false,
                              this.tableCaptions: false,
                              this.implicitFigures: false,
                              this.simpleTables: false,
                              this.multilineTables: false,
                              this.gridTables: false,
                              this.pipeTables: false,
                              this.citations: false,
                              this.rawTex: false,
                              this.rawHtml: false,
                              this.texMathDollars: false,
                              this.texMathSingleBackslash: false,
                              this.texMathDoubleBackslash: false,
                              this.latexMacros: false,
                              this.fencedCodeBlocks: false,
                              this.fencedCodeAttributes: false,
                              this.backtickCodeBlocks: false,
                              this.inlineCodeAttributes: false,
                              this.markdownInHtmlBlocks: false,
                              this.nativeDivs: false,
                              this.nativeSpans: false,
                              this.markdownAttribute: false,
                              this.escapedLineBreaks: false,
                              this.linkAttributes: false,
                              this.autolinkBareUrls: false,
                              this.fancyLists: false,
                              this.listsWithoutPrecedingBlankline: false,
                              this.startnum: false,
                              this.definitionLists: false,
                              this.compactDefinitionLists: false,
                              this.exampleLists: false,
                              this.allSymbolsEscapable: false,
                              this.intrawordUnderscores: false,
                              this.blankBeforeBlockquote: false,
                              this.blankBeforeHeader: false,
                              this.strikeout: false,
                              this.superscript: false,
                              this.subscript: false,
                              this.hardLineBreaks: false,
                              this.ignoreLineBreaks: false,
                              this.literateHaskell: false,
                              this.abbreviations: false,
                              this.autoIdentifiers: false,
                              this.asciiIdentifiers: false,
                              this.headerAttributes: false,
                              this.mmdHeaderIdentifiers: false,
                              this.implicitHeaderReferences: false,
                              this.lineBlocks: false
                              });

  MarkdownParserOptions setOption({
                                  footnotes,
                                  inlineNotes,
                                  pandocTitleBlock,
                                  yamlMetadataBlock,
                                  mmdTitleBlock,
                                  tableCaptions,
                                  implicitFigures,
                                  simpleTables,
                                  multilineTables,
                                  gridTables,
                                  pipeTables,
                                  citations,
                                  rawTex,
                                  rawHtml,
                                  texMathDollars,
                                  texMathSingleBackslash,
                                  texMathDoubleBackslash,
                                  latexMacros,
                                  fencedCodeBlocks,
                                  fencedCodeAttributes,
                                  backtickCodeBlocks,
                                  inlineCodeAttributes,
                                  markdownInHtmlBlocks,
                                  nativeDivs,
                                  nativeSpans,
                                  markdownAttribute,
                                  escapedLineBreaks,
                                  linkAttributes,
                                  autolinkBareUrls,
                                  fancyLists,
                                  listsWithoutPrecedingBlankline,
                                  startnum,
                                  definitionLists,
                                  compactDefinitionLists,
                                  exampleLists,
                                  allSymbolsEscapable,
                                  intrawordUnderscores,
                                  blankBeforeBlockquote,
                                  blankBeforeHeader,
                                  strikeout,
                                  superscript,
                                  subscript,
                                  hardLineBreaks,
                                  ignoreLineBreaks,
                                  literateHaskell,
                                  abbreviations,
                                  autoIdentifiers,
                                  asciiIdentifiers,
                                  headerAttributes,
                                  mmdHeaderIdentifiers,
                                  implicitHeaderReferences,
                                  lineBlocks
                                  }) => const MarkdownParserOptions(
      footnotes: footnotes == null ? this.footnotes : footnotes,
      inlineNotes: inlineNotes == null ? this.inlineNotes : inlineNotes,
      pandocTitleBlock: pandocTitleBlock == null ? this.pandocTitleBlock : pandocTitleBlock,
      yamlMetadataBlock: yamlMetadataBlock == null ? this.yamlMetadataBlock : yamlMetadataBlock,
      mmdTitleBlock: mmdTitleBlock == null ? this.mmdTitleBlock : mmdTitleBlock,
      tableCaptions: tableCaptions == null ? this.tableCaptions : tableCaptions,
      implicitFigures: implicitFigures == null ? this.implicitFigures : implicitFigures,
      simpleTables: simpleTables == null ? this.simpleTables : simpleTables,
      multilineTables: multilineTables == null ? this.multilineTables : multilineTables,
      gridTables: gridTables == null ? this.gridTables : gridTables,
      pipeTables: pipeTables == null ? this.pipeTables : pipeTables,
      citations: citations == null ? this.citations : citations,
      rawTex: rawTex == null ? this.rawTex : rawTex,
      rawHtml: rawHtml == null ? this.rawHtml : rawHtml,
      texMathDollars: texMathDollars == null ? this.texMathDollars : texMathDollars,
      texMathSingleBackslash: texMathSingleBackslash == null ? this.texMathSingleBackslash : texMathSingleBackslash,
      texMathDoubleBackslash: texMathDoubleBackslash == null ? this.texMathDoubleBackslash : texMathDoubleBackslash,
      latexMacros: latexMacros == null ? this.latexMacros : latexMacros,
      fencedCodeBlocks: fencedCodeBlocks == null ? this.fencedCodeBlocks : fencedCodeBlocks,
      fencedCodeAttributes: fencedCodeAttributes == null ? this.fencedCodeAttributes : fencedCodeAttributes,
      backtickCodeBlocks: backtickCodeBlocks == null ? this.backtickCodeBlocks : backtickCodeBlocks,
      inlineCodeAttributes: inlineCodeAttributes == null ? this.inlineCodeAttributes : inlineCodeAttributes,
      markdownInHtmlBlocks: markdownInHtmlBlocks == null ? this.markdownInHtmlBlocks : markdownInHtmlBlocks,
      nativeDivs: nativeDivs == null ? this.nativeDivs : nativeDivs,
      nativeSpans: nativeSpans == null ? this.nativeSpans : nativeSpans,
      markdownAttribute: markdownAttribute == null ? this.markdownAttribute : markdownAttribute,
      escapedLineBreaks: escapedLineBreaks == null ? this.escapedLineBreaks : escapedLineBreaks,
      linkAttributes: linkAttributes == null ? this.linkAttributes : linkAttributes,
      autolinkBareUrls: autolinkBareUrls == null ? this.autolinkBareUrls : autolinkBareUrls,
      fancyLists: fancyLists == null ? this.fancyLists : fancyLists,
      listsWithoutPrecedingBlankline: listsWithoutPrecedingBlankline == null ? this.listsWithoutPrecedingBlankline : listsWithoutPrecedingBlankline,
      startnum: startnum == null ? this.startnum : startnum,
      definitionLists: definitionLists == null ? this.definitionLists : definitionLists,
      compactDefinitionLists: compactDefinitionLists == null ? this.compactDefinitionLists : compactDefinitionLists,
      exampleLists: exampleLists == null ? this.exampleLists : exampleLists,
      allSymbolsEscapable: allSymbolsEscapable == null ? this.allSymbolsEscapable : allSymbolsEscapable,
      intrawordUnderscores: intrawordUnderscores == null ? this.intrawordUnderscores : intrawordUnderscores,
      blankBeforeBlockquote: blankBeforeBlockquote == null ? this.blankBeforeBlockquote : blankBeforeBlockquote,
      blankBeforeHeader: blankBeforeHeader == null ? this.blankBeforeHeader : blankBeforeHeader,
      strikeout: strikeout == null ? this.strikeout : strikeout,
      superscript: superscript == null ? this.superscript : superscript,
      subscript: subscript == null ? this.subscript : subscript,
      hardLineBreaks: hardLineBreaks == null ? this.hardLineBreaks : hardLineBreaks,
      ignoreLineBreaks: ignoreLineBreaks == null ? this.ignoreLineBreaks : ignoreLineBreaks,
      literateHaskell: literateHaskell == null ? this.literateHaskell : literateHaskell,
      abbreviations: abbreviations == null ? this.abbreviations : abbreviations,
      autoIdentifiers: autoIdentifiers == null ? this.autoIdentifiers : autoIdentifiers,
      asciiIdentifiers: asciiIdentifiers == null ? this.asciiIdentifiers : asciiIdentifiers,
      headerAttributes: headerAttributes == null ? this.headerAttributes : headerAttributes,
      mmdHeaderIdentifiers: mmdHeaderIdentifiers == null ? this.mmdHeaderIdentifiers : mmdHeaderIdentifiers,
      implicitHeaderReferences: implicitHeaderReferences == null ? this.implicitHeaderReferences : implicitHeaderReferences,
      lineBlocks: lineBlocks == null ? this.lineBlocks : lineBlocks
  );

  static const MarkdownParserOptions PANDOC = const MarkdownParserOptions(
      footnotes: true,
      inlineNotes: true,
      pandocTitleBlock: true,
      yamlMetadataBlock: true,
      tableCaptions: true,
      implicitFigures: true,
      simpleTables: true,
      multilineTables: true,
      gridTables: true,
      pipeTables: true,
      citations: true,
      rawTex: true,
      rawHtml: true,
      texMathDollars: true,
      latexMacros: true,
      fencedCodeBlocks: true,
      fencedCodeAttributes: true,
      backtickCodeBlocks: true,
      inlineCodeAttributes: true,
      markdownInHtmlBlocks: true,
      nativeDivs: true,
      nativeSpans: true,
      escapedLineBreaks: true,
      fancyLists: true,
      startnum: true,
      definitionLists: true,
      exampleLists: true,
      allSymbolsEscapable: true,
      intrawordUnderscores: true,
      blankBeforeBlockquote: true,
      blankBeforeHeader: true,
      strikeout: true,
      superscript: true,
      subscript: true,
      literateHaskell: true,
      autoIdentifiers: true,
      headerAttributes: true,
      implicitHeaderReferences: true,
      lineBlocks: true
  );

  static const MarkdownParserOptions PHPEXTRA = const MarkdownParserOptions(
      footnotes: true,
      pipeTables: true,
      rawHtml: true,
      markdownAttribute: true,
      fencedCodeBlocks: true,
      definitionLists: true,
      intrawordUnderscores: true,
      headerAttributes: true,
      abbreviations: true
  );

  static const MarkdownParserOptions GITHUB = const MarkdownParserOptions(
      pipeTables: true,
      rawHtml: true,
      texMathSingleBackslash: true,
      fencedCodeBlocks: true,
      autoIdentifiers: true,
      asciiIdentifiers: true,
      backtickCodeBlocks: true,
      autolinkBareUrls: true,
      intrawordUnderscores: true,
      strikeout: true,
      hardLineBreaks: true
  );

  static const MarkdownParserOptions MMD = const MarkdownParserOptions(
      pipeTables: true,
      rawHtml: true,
      markdownAttribute: true,
      linkAttributes: true,
      rawTex: true,
      texMathDoubleBackslash: true,
      intrawordUnderscores: true,
      mmdTitleBlock: true,
      footnotes: true,
      definitionLists: true,
      allSymbolsEscapable: true,
      implicitHeaderReferences: true,
      autoIdentifiers: true,
      mmdHeaderIdentifiers: true
  );

  static const MarkdownParserOptions STRICT = const MarkdownParserOptions(
      rawHtml: true
  );

  static const MarkdownParserOptions DEFAULT = PANDOC;
}
