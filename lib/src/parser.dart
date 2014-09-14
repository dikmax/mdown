part of markdown;

class _UnparsedInlines extends Inlines {
  String raw;

  _UnparsedInlines(this.raw);

  String toString() => raw;

  bool operator==(obj) => obj is _UnparsedInlines &&
    raw == obj.raw;
}


class _LinkReference extends Block {
  String reference;
  Target target;

  _LinkReference(this.reference, this.target);
}

// TODO make aux parsers private

// TODO extract constant parsers from parsers methods

// CommonMark parser
class CommonMarkParser {
  static const int TAB_STOP = 4;

  CommonMarkParser();

  Map<String, Target> _references;

  Map<String, Target> get references => _references; // TODO remove later

  Document parse(String s) {
    // TODO separate preprocess option

    _references = {};

    var doc = document.parse(preprocess(s) + "\n\n");

    // TODO parse inlines
    return doc;

  }

  //
  // Preprocess
  //

  String preprocess(String s) {
    StringBuffer sb = new StringBuffer();

    int i = 0, len = s.length;
    int pos = 1;
    while (i < len) {
      if (s[i] == "\r") {
        if (i + 1 < len && s[i + 1] == "\n") {
          ++i;
        }

        sb.write("\n");
        pos = 0;
      } else if (s[i] == "\n") {
        if (i + 1 < len && s[i + 1] == "\r") {
          ++i;
        }

        sb.write("\n");
        pos = 0;
      } else if (s[i] == "\t") {
        int expandSize = (TAB_STOP - pos) % TAB_STOP;
        sb.write(" " * (expandSize + 1));
        pos += expandSize;
      } else {
        sb.write(s[i]);
      }

      ++i;
      ++pos;
    }

    return sb.toString();
  }

  //
  // Aux methods
  //

  List<Block> processParsedBlocks(Iterable blocks) {
    List list = flatten(blocks);
    List result = [];
    list.forEach((Block block) {
      if (block is _LinkReference) {
        if (!_references.containsKey(block.reference)) {
          _references[block.reference] = block.target;
        }
      } else {
        result.add(block);
      }
    });
    return result;
  }


  static List flatten(Iterable list) {
    List result = [];

    for (var item in list) {
      if (item is Iterable) {
        result.addAll(flatten(item));
      } else {
        result.add(item);
      }
    }

    return result;
  }


  String stripTrailingNewlines(String str) {
    var l = str.length;
    while (l > 0 && str[l - 1] == '\n') {
      --l;
    }
    return str.substring(0, l);
  }


  //
  // Aux parsers
  //

  static Parser get anyLine => new Parser((s, Position pos) {
    String result = '';
    int offset = pos.offset, len = s.length;
    if (offset >= len) {
      return new ParseResult(s, new Expectations.empty(pos), pos, false, false, null);
    }
    while (offset < len && s[offset] != '\n') {
      result += s[offset];
      ++offset;
    }
    var newPos;
    if (offset < len && s[offset] == '\n') {
      newPos = new Position(offset + 1, pos.line + 1, 1);
    } else {
      newPos = new Position(offset, pos.line, pos.character + result.length);
    }
    return new ParseResult(s, new Expectations.empty(newPos), newPos, true, false, result);
  });

  static Parser spaceChar = oneOf(" \t") % 'space';
  static Parser nonSpaceChar = noneOf("\t\n \r");
  static Parser skipSpaces = spaceChar.skipMany;
  static Parser blankline = skipSpaces > newline % 'blankline';
  static Parser blanklines = blankline.many1 % 'blanklines';
  Parser get indentSpaces => count(TAB_STOP, char(' ')) | char('\t') % "indentation";
  static Parser get skipNonindentSpaces => atMostSpaces(TAB_STOP - 1).notFollowedBy(char(' '));
  static Parser spnl = (skipSpaces > newline);

  static Parser atMostSpaces(n) {
    if (n <= 0) {
      return success(0);
    }

    return new Parser((s, pos) {
      int i = 0;
      Position position = pos;
      while (i < n) {
        var res = char(' ').run(s, position);
        if (!res.isSuccess) {
          return success(i).run(s, position);
        }
        position = res.position;
        ++i;
      }
      return success(i).run(s, position);
    });
  }

  static Parser count(int l, Parser p) {
    return new Parser((s, pos) {
      var position = pos;
      var value = [];
      ParseResult res;
      for (int i = 0; i < l; ++i) {
        res = p.run(s, position);
        if (res.isSuccess) {
          value.add(res.value);
          position = res.position;
        } else {
          return res;
        }
      }

      return res.copy(value: value);
    });
  }

  Parser many1Until(Parser parser, Parser end) => parser + parser.manyUntil(end) ^ (a, b) {
    List<Inline> res = [a];
    if (b.length > 0) {
      res.addAll(b);
    }
    return res;
  };


  //
  // HTML
  //

  static final String _lower = "abcdefghijklmnopqrstuvwxyz";
  static final String _upper = _lower.toUpperCase();
  static final String _alpha = "$_lower$_upper";
  static final String _digit = "1234567890";
  static final String _alphanum = "$_alpha$_digit";
  static final Set<String> _allowedTags = new Set.from(["article", "header", "aside", "hgroup", "blockquote", "hr", "iframe",
    "body", "li", "map", "button", "object", "canvas", "ol", "caption", "output", "col", "p", "colgroup", "pre", "dd",
    "progress", "div", "section", "dl", "table", "td", "dt", "tbody", "embed", "textarea", "fieldset", "tfoot",
    "figcaption", "th", "figure", "thead", "footer", "footer", "tr", "form", "ul", "h1", "h2", "h3", "h4", "h5", "h6",
    "video", "script", "style"]);
  static Parser spaceOrNL = oneOf(" \t\n");

  static Parser htmlAttributeName = (oneOf(_alpha + "_:") > oneOf(_alphanum + "_.:-").many).record;
  static Parser htmlAttiributeValue = (spaceOrNL.many + char('=') + spaceOrNL.many +
    (htmlUnquotedAttributeValue | htmlSingleQuotedAttributeValue | htmlDoubleQuotedAttributeValue)).list.record;
  static Parser htmlUnquotedAttributeValue = noneOf(" \t\n\"'=<>`").many1;
  static Parser htmlSingleQuotedAttributeValue = (char("'") > noneOf("'\n").many) < char("'");
  static Parser htmlDoubleQuotedAttributeValue = (char('"') > noneOf('"\n').many) < char('"');

  static Parser get htmlAttribute => (spaceOrNL.many1 + htmlAttributeName + htmlAttiributeValue.maybe).list.record;
  static Parser htmlBlockTag(Parser p) {
    return new Parser((s, pos) {
      ParseResult res = p.run(s, pos);
      if (!res.isSuccess) {
        return res;
      }

      if (_allowedTags.contains(res.value.join().toLowerCase())) {
        return res.copy(value: s.substring(pos.offset, res.position.offset));
      }
      return fail.run(s, pos);
    });
  }
  Parser get htmlOpenTag => htmlBlockTag(
      ((((char("<") > alphanum.many1) < htmlAttribute.many) < spaceOrNL.many) < char('/').maybe) < char('>')
  );

  Parser get htmlCloseTag => htmlBlockTag(
      ((string("</") > alphanum.many1) < spaceOrNL.many) < char('>')
  );

  Parser get htmlCompleteComment => (string('<!--') > anyChar.manyUntil(string('-->'))).record;
  Parser get htmlCompletePI => (string('<?') > anyChar.manyUntil(string('?>'))).record;
  Parser get htmlDeclaration => (string('<!') + upper.many1 + spaceOrNL.many1 + anyChar.manyUntil(char('>'))).list.record;
  Parser get htmlCompleteCDATA => (string('<![CDATA[') > anyChar.manyUntil(string(']]>'))).record;

  //
  // Inlines
  //

  //
  // Blocks
  //

  Parser<List<Block>> get block => choice([
      blanklines ^ (_) => [],
      hrule,
      atxHeader,
      setextHeader,
      codeBlockIndented,
      codeBlockFenced,
      rawHtml,
      linkReference,
      blockquote,
      unorderedList,
      orderedList,
      para
  ]);

  Parser<List<Block>> get blockTight => choice([
      hrule,
      atxHeader,
      setextHeader,
      codeBlockIndented,
      codeBlockFenced,
      rawHtml,
      linkReference,
      blockquote,
      unorderedList,
      orderedList,
      para
  ]);

  //
  // Horizontal rule
  //

  static const String hruleChars = '*-_';

  static Parser get hrule => new Parser((s, pos) {
    ParseResult startRes = (skipNonindentSpaces > oneOf(hruleChars)).run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    var start = startRes.value;

    return ((((count(2, skipSpaces > char(start)) > (spaceChar | char(start)).skipMany) > newline) > blanklines.maybe) >
      success([new HorizontalRule()])).run(s, startRes.position);
  });

  //
  // ATX Header
  //

  Parser get atxHeader => new Parser((s, pos) {
    Parser startParser = skipNonindentSpaces > char('#').many1;
    ParseResult startRes = startParser.run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    int level = startRes.value.length;
    if (level > 6) {
      return fail.run(s, pos);
    }

    ParseResult textRes = (((spaceChar > skipSpaces) > anyChar.manyUntil(char('#').many > blankline)) |
      (newline ^ (_) => [])).run(s, startRes.position);
    if (!textRes.isSuccess) {
      return textRes;
    }
    String raw = textRes.value.join();
    // TODO parse inlines

    _UnparsedInlines inlines = new _UnparsedInlines(raw.trim());
    return textRes.copy(value: [new AtxHeader(level, inlines)]);
  });

  //
  // Setext Header
  //

  static const String setextHChars = "=-";

  Parser get setextHeader => new Parser((s, pos) {
    ParseResult res = (((skipNonindentSpaces.notFollowedBy(char('>')) > anyLine) +
      (skipNonindentSpaces > oneOf(setextHChars).many1)).list < blankline).run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    String raw = res.value[0];
    int level = res.value[1][0] == '=' ? 1 : 2;
    // TODO parse inlines

    _UnparsedInlines inlines = new _UnparsedInlines(raw.trim());
    return res.copy(value: [new SetextHeader(level, inlines)]);
  });

  //
  // Indented code
  //

  Parser get indentedLine => (indentSpaces > anyLine) ^ (line) => line + "\n";

  Parser get codeBlockIndented =>
    ((indentedLine | (blanklines + indentedLine) ^ (b, l) => b.join('') + l).many1 < blanklines.maybe) ^
        (c) => new IndentedCodeBlock(stripTrailingNewlines(c.join('')) + '\n');

  //
  // Fenced code
  //

  Parser get codeBlockFenced => new Parser((s, pos) {
    Parser fenceStartParser = (skipNonindentSpaces + (string('~~~') | string('```'))).list;
    ParseResult fenceStartRes = fenceStartParser.run(s, pos);
    if (!fenceStartRes.isSuccess) {
      return fenceStartRes;
    }
    int indent = fenceStartRes.value[0];
    String fenceChar = fenceStartRes.value[1][0];

    Parser infoStringParser = ((skipSpaces > noneOf("\n " + fenceChar).many) < noneOf("\n" + fenceChar).many) < newline;
    Parser topFenceParser = (char(fenceChar).many + infoStringParser).list;
    ParseResult topFenceRes = topFenceParser.run(s, fenceStartRes.position);
    if (!topFenceRes.isSuccess) {
      return topFenceRes;
    }

    int fenceSize = topFenceRes.value[0].length + 3;
    String infoString = topFenceRes.value[1].join();

    Parser lineParser = anyLine;
    if (indent > 0) {
      lineParser = atMostSpaces(indent) > lineParser;
    }
    Parser endFenceParser = (((skipSpaces > string(fenceChar * fenceSize)) > char(fenceChar).many) > skipSpaces) > newline;
    Parser restParser = (lineParser.manyUntil(endFenceParser) ^
        (lines) => [new FencedCodeBlock(lines.map((i) => i + '\n').join(), new InfoString(infoString))])
      | (lineParser.manyUntil(eof) ^ (List lines) {
        // If fenced code block is ended by eof trim last two new lines;
        if (lines.length > 0 && lines.last == "") {
          lines.removeLast();
        }
        return [new FencedCodeBlock(lines.join('\n'), new InfoString(infoString))];
      });

    return restParser.run(s, topFenceRes.position);
  });

  //
  // Raw html block
  //

  Parser get rawHtml => new Parser((s, pos) {
    // Simple test
    ParseResult testRes = (skipNonindentSpaces < char('<')).run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }

    int firstLineIndent = testRes.value;

    Parser contentParser = anyLine.manyUntil(blankline);
    ParseResult contentRes = contentParser.run(s, testRes.position);
    if (!contentRes.isSuccess) {
      return contentRes;
    }
    if (contentRes.value.length == 0) {
      return fail.run(s, pos);
    }
    String content = "<" + contentRes.value.join('\n');

    // TODO add support for partial html comments, pi and CDATA.

    ParseResult tagRes = (htmlOpenTag
      | htmlCloseTag
      | htmlCompleteComment
      | htmlCompletePI
      | htmlDeclaration
      | htmlCompleteCDATA).run(content);
    if (!tagRes.isSuccess) {
      return fail.run(s, pos);
    }

    return contentRes.copy(value: [new HtmlRawBlock((" " * firstLineIndent) + content)]);
  });

  //
  // Link reference
  //

  // TODO complete inlines parser for label
  Parser get linkLabel => ((char("[") > noneOf("]\n").many1) < string("]:")) ^ (i) => i.join();

  // TODO proper parentheses ()
  Parser get linkDestination => (
    ((char("<") > noneOf("<>\n").many1) < char(">")) |
    noneOf("\t\n ()").many1
  ) ^ (i) => i.join();

  // TODO support escaping
  Parser get linkTitle => (
      ((char("'") > noneOf("'\n")) < char("'")) |
      ((char('"') > noneOf('"\n')) < char('"')) |
      ((char('(') > noneOf(')\n')) < char(')'))
  ) ^ (i) => i.join();

  Parser get linkReference => (((skipNonindentSpaces > linkLabel) +
    ((blankline.maybe > skipSpaces) > linkDestination) +
    ((blankline.maybe > skipSpaces) > linkTitle).maybe) ^
      (String label, String link, Option<String> title) =>
        new _LinkReference(label, new Target(link, title.isDefined ? title.value : null))) < blankline;

  //
  // Paragraph
  //

  // TODO paragraph could be ended by other block types
  Parser get para => new Parser((s, pos) {
    // TODO replace codeBlockFenced with starting fence test
    Parser end = blankline
      | hrule
      | atxHeader
      | codeBlockFenced
      | (skipNonindentSpaces > (
        char('>')
        | (oneOf('+-*') > char(' '))));
    ParseResult res = (end.notAhead > anyLine).many1.run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    _UnparsedInlines inlines = new _UnparsedInlines(res.value.join("\n").trim());
    return res.copy(value: [new Para(inlines)]);
    //return (blankline.many ^ (_) => [new Para(inlines)]).run(s, res.position);
  });

  //
  // Blockquote
  //

  static Parser blockquoteStrictLine = ((skipNonindentSpaces > char('>')) > char(' ').maybe) > anyLine;
  static Parser blockquoteLazyLine = skipNonindentSpaces > anyLine;
  static Parser blockquoteLine = (blockquoteStrictLine ^ (l) => [true, l])
    | (blockquoteLazyLine ^ (l) => [false, l]);

  bool acceptLazy(Iterable<Block> blocks, String s) {
    if (blocks.length > 0) {
      if (blocks.last is Para) {
        blocks.last.contents.raw += "\n" + s;
        return true;
      } else if (blocks.last is Blockquote) {
        return acceptLazy(blocks.last.contents, s);
      } else if (blocks.last is ListBlock) {
        return acceptLazy(blocks.last.items.last.contents, s);
      }
      // TODO add list support
    }

    return false;
  }

  Parser get blockquote => new Parser((s, pos) {
    ParseResult firstLineRes = blockquoteStrictLine.run(s, pos);
    if (!firstLineRes.isSuccess) {
      return firstLineRes;
    }
    List<String> buffer = [firstLineRes.value];
    List<Block> blocks = [];

    bool closeParagraph = false;

    void buildBuffer() {
      String s = buffer.map((l) => l + "\n").join();
      List<Block> innerRes = (block.manyUntil(eof) ^ (res) => processParsedBlocks(res)).parse(s);
      if (!closeParagraph && innerRes.length > 0 && innerRes.first is Para && acceptLazy(blocks, innerRes.first.contents.raw)) {
        innerRes.removeAt(0);
      }
      if (innerRes.length > 0) {
        blocks.addAll(innerRes);
      }
      buffer = [];
    }

    Position position = firstLineRes.position;
    while(true) {
      ParseResult res = blockquoteLine.run(s, position);
      if (!res.isSuccess) {
        break;
      }
      bool isStrict = res.value[0];
      String line = res.value[1];
      if (isStrict) {
        closeParagraph = line.trim() == "";
        buffer.add(line);
      } else {
        if (buffer.length > 0) {
          buildBuffer();
          List<Block> lineBlock = block.parse(line + "\n");
          // TODO fix condition
          if (!closeParagraph && lineBlock.length == 1 && lineBlock[0] is Para && acceptLazy(blocks, lineBlock[0].contents.raw)) {

          } else {
            break;
          }
        }
      }
      position = res.position;
    }

    if (buffer.length > 0) {
      buildBuffer();
    }

    return firstLineRes.copy(position: position, value: [new Blockquote(blocks)]);
  });

  //
  // Lists
  //

  static Parser get unorderedListMarkerTest => ((skipNonindentSpaces.notFollowedBy(hrule) > oneOf('-+*')) < char(' '));
  static Parser get orderedListMarkerTest => ((skipNonindentSpaces > digit.many1) + (oneOf('.)') < char(' '))).list;
  static Parser listFirstLine(int indent, Parser marker) => (atMostSpaces(indent).notFollowedBy(hrule) + marker + anyLine).list;
  static Parser listStrictLine(int indent) => string(" " * indent) > anyLine;
  static Parser get listLazyLine => skipNonindentSpaces > anyLine;
  static Parser listLine(int indent, Parser marker) => // There are three types of lines in list
    (listFirstLine(indent - 1, marker) ^ (l) => [0,  l[0], l[1], l[2]]) // List item start
    | (blankline ^ (l) => [3])                                          // Blank line
    | (listStrictLine(indent) ^ (l) => [1, l])                          // List item strict continuation
    | (listLazyLine ^ (l) => [2, l]);                                   // List item lazy continuation


  Parser list(Parser marker) => new Parser((s, pos) {
    ParseResult firstLineRes = listFirstLine(TAB_STOP - 1, marker).run(s, pos);
    if (!firstLineRes.isSuccess) {
      return firstLineRes;
    }

    List<ListItem> items = [];
    List<Block> blocks = [];
    String line = firstLineRes.value[2];
    List<String> buffer = [line];
    bool closeParagraph = false;
    bool tight = true;

    void buildBuffer() {
      String s = buffer.map((l) => l + "\n").join();
      List<Block> innerBlocks;
      if (tight) {
        // TODO
        ParseResult innerRes = (blockTight.manyUntil(eof) ^ (res) => processParsedBlocks(res)).run(s);
        if (innerRes.isSuccess) {
          innerBlocks = innerRes.value;
        } else {
          tight = false;
        }
      }

      if (!tight) {
        innerBlocks = (block.manyUntil(eof) ^ (res) => processParsedBlocks(res)).parse(s);
      }
      if (!closeParagraph && innerBlocks.length > 0 && innerBlocks.first is Para && acceptLazy(blocks, innerBlocks.first.contents.raw)) {
        innerBlocks.removeAt(0);
      }
      if (innerBlocks.length > 0) {
        blocks.addAll(innerBlocks);
      }
      buffer = [];
    }

    void addItem() {
      if (buffer.length > 0) {
        buildBuffer();
      }
      items.add(new ListItem(blocks));
      blocks = [];
    }

    int indent = firstLineRes.value[0] + firstLineRes.value[1].length;
    int size = min(line.length, 4);
    String substring = line.substring(0, size);
    if (substring != "    ") {
      indent += size - substring.trimLeft().length;
    }

    Position position = firstLineRes.position;
    loop: while (true) {
      ParseResult res = listLine(indent, marker).run(s, position);
      if (!res.isSuccess) {
        break;
      }

      switch (res.value[0]) {
        case 0: // New list item start
          if (closeParagraph) {
            tight = false;
          }
          closeParagraph = true;
          addItem();

          line = res.value[3];
          buffer.add(line);
          indent = res.value[1] + res.value[2].length;
          int size = min(line.length, 4);
          String substring = line.substring(0, size);
          if (substring != "    ") {
            indent += size - substring.trimLeft().length;
          }

          closeParagraph = false;
          break;

        case 1: // Strict line
          if (closeParagraph) {
            buffer.add('');
          }
          buffer.add(res.value[1]);
          closeParagraph = false;
          break;

        case 2: // Lazy line
          if (buffer.length > 0) {
            buildBuffer();
            List<Block> lineBlock = block.parse(res.value[1] + "\n");
            // TODO fix condition
            if (!closeParagraph && lineBlock.length == 1 && lineBlock[0] is Para && acceptLazy(blocks, lineBlock[0].contents.raw)) {

            } else {
              break loop;
            }
          }

          closeParagraph = false;
          break;

        case 3: // Blank line
          // TODO fenced code block test
          if (closeParagraph) {
            // Second blank line. Closing list
            break loop;
          } else {
            closeParagraph = true;
          }
          break;
      }

      position = res.position;
    }

    if (buffer.length > 0) {
      buildBuffer();
    }

    addItem();

    if (tight) {
      items.forEach((ListItem item) {
        item.contents = item.contents.map((Block block) {
          if (block is Para) {
            return new Plain(block.contents);
          }
          return block;
        });
      });
    }

    return firstLineRes.copy(position: position, value: items);
  });

  Parser get unorderedList => new Parser((s, pos) {
    ParseResult testRes = unorderedListMarkerTest.run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }
    String markerChar = testRes.value;

    return (list(string(markerChar + " ")) ^ (items) {
      BulletType type;
      switch(markerChar) {
        case '+':
          type = BulletType.PlusBullet;
          break;

        case '-':
          type = BulletType.MinusBullet;
          break;

        case '*':
          type = BulletType.StarBullet;
          break;

        default:
          assert(false);
          type = BulletType.PlusBullet;
      }

      return [new UnorderedList(items, type)];
    }).run(s, pos);
  });

  Parser get orderedList => new Parser((s, pos) {
    ParseResult testRes = orderedListMarkerTest.run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }
    int startIndex = num.parse(testRes.value[0].join());
    String indexSeparator = testRes.value[1];

    return (list((digit.many1 > string(indexSeparator + " ")).record) ^ (items) {
      IndexSeparator separator;
      switch(indexSeparator) {
        case '.':
          separator = IndexSeparator.DotSeparator;
          break;

        case ')':
          separator = IndexSeparator.ParenthesisSeparator;
          break;

        default:
          assert(false);
          separator = IndexSeparator.DotSeparator;
      }

      return [new OrderedList(items, separator, startIndex)];
    }).run(s, pos);
  });

  //
  // Document
  //

  Parser get document => (block.manyUntil(eof) ^ (res) => new Document(processParsedBlocks(res))) % "document";

  static CommonMarkParser DEFAULT = new CommonMarkParser();
}
