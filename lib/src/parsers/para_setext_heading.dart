part of md_proc.src.parsers;

/// Parser for paragraphs and setext headings.
class ParaSetextHeadingParser extends AbstractParser<Iterable<Block>> {
  static final RegExp _setextHeadingRegExp =
      new RegExp('^ {0,3}(-+|=+)[ \t]*\$');

  List<RegExp> _paragraphBreaks;

  /// Constructor.
  ParaSetextHeadingParser(ParsersContainer container) : super(container);

  @override
  void init() {
    _paragraphBreaks = <RegExp>[
      _thematicBreakTest,
      _fencedCodeStartTest,
      _atxHeadingText,
      _blockquoteSimpleTest
    ];

    if (container.options.rawHtml) {
      _paragraphBreaks.addAll(<RegExp>[
        _htmlBlock1Test,
        _htmlBlock2Test,
        _htmlBlock3Test,
        _htmlBlock4Test,
        _htmlBlock5Test,
        _htmlBlock6Test
      ]);
    }
  }

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    List<String> contents = <String>[];
    bool canBeHeading = false;
    int level = 0;
    int length = text.length;

    Iterable<Block> listAddition;

    while (offset < length) {
      ParseResult<String> lineResult = container.lineParser.parse(text, offset);
      assert(lineResult.isSuccess);

      String line = lineResult.value;

      if (!_emptyLineRegExp.hasMatch(line)) {
        if (canBeHeading) {
          if (fastBlockTest2(
              text, offset, _minusCodeUnit, _equalCodeUnit)) {
            Match match = _setextHeadingRegExp.firstMatch(line);
            if (match != null) {
              level = match[1][0] == '=' ? 1 : 2;
              offset = lineResult.offset;
              break;
            }
          }
        }

        if (contents.length > 0 &&
            _paragraphBreaks.any((RegExp re) => re.hasMatch(lineResult.value))) {
          // Paragraph stops here as we've got another block.
          break;
        }

        // Special check for list, as it can break paragraph only if not empty
        // Ordered lists are also required to start with 1. to allow breaking.
        if (_listSimpleTest.hasMatch(lineResult.value)) {
          // It could be a list.

          ParseResult<Iterable<Block>> listResult =
              container.blockquoteListParser.parse(text, offset);
          if (listResult.isSuccess) {
            // It's definitely a list
            Block firstBlock = listResult.value.elementAt(0);
            if (firstBlock is ListBlock) {
              if (firstBlock.items.length > 0 &&
                  firstBlock.items.elementAt(0).contents.length > 0) {
                // It's not empty list, append it in the end and stop parsing.

                offset = listResult.offset;
                listAddition = listResult.value;
                break;
              }
            }
          }
        }

        contents.add(line.replaceFirst(_trimLeftRegExp, ''));
        canBeHeading = true;
      } else {
        // Empty line should be parsed by blank line parser.
        // List tightness rely on this. So, we exit here.
        break;
      }
      offset = lineResult.offset;
    }

    Inlines inlines = new _UnparsedInlines(contents.join('\n'));
    if (level > 0) {
      return new ParseResult<Iterable<SetextHeading>>.success(
          <SetextHeading>[new SetextHeading(level, inlines)], offset);
    }

    List<Block> result = <Block>[new Para(inlines)];
    if (listAddition != null) {
      result.addAll(listAddition);
    }
    return new ParseResult<Iterable<Block>>.success(result, offset);
  }
}
