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

class _ListStackItem {
  int indent;
  int subIndent;
  ListBlock block;
  bool tight;

  _ListStackItem(this.indent, this.subIndent, this.block, [this.tight = true]);
}

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
      list,
      codeBlockIndented,
      codeBlockFenced,
      rawHtml,
      linkReference,
      blockquote,
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

  Parser get codeBlockIndented => (indentedLine +
    ((indentedLine | (blanklines + indentedLine) ^ (b, l) => b.join('') + l).many)) ^
      (f, c) => new IndentedCodeBlock(stripTrailingNewlines(f + c.join('')) + '\n');

  //
  // Fenced code
  //

  Parser get openFence => new Parser((s, pos) {
    Parser fenceStartParser = (skipNonindentSpaces + (string('~~~') | string('```'))).list;
    ParseResult fenceStartRes = fenceStartParser.run(s, pos);
    if (!fenceStartRes.isSuccess) {
      return fenceStartRes;
    }
    int indent = fenceStartRes.value[0];
    String fenceChar = fenceStartRes.value[1][0];
    FenceType fenceType = FenceType.BacktickFence;
    if (fenceChar == '~') {
      fenceType = FenceType.TildeFence;
    }

    Parser infoStringParser = ((skipSpaces > noneOf("\n " + fenceChar).many) < noneOf("\n" + fenceChar).many) < newline;
    Parser topFenceParser = (char(fenceChar).many + infoStringParser).list;
    ParseResult topFenceRes = topFenceParser.run(s, fenceStartRes.position);
    if (!topFenceRes.isSuccess) {
      return topFenceRes;
    }

    int fenceSize = topFenceRes.value[0].length + 3;
    String infoString = topFenceRes.value[1].join();
    return topFenceRes.copy(value: [indent, fenceChar, fenceSize, infoString]);
  });

  Parser get codeBlockFenced => new Parser((s, pos) {
    ParseResult openFenceRes = openFence.run(s, pos);
    if (!openFenceRes.isSuccess) {
      return openFenceRes;
    }
    int indent = openFenceRes.value[0];
    String fenceChar = openFenceRes.value[1];
    int fenceSize = openFenceRes.value[2];
    String infoString = openFenceRes.value[3];

    FenceType fenceType = FenceType.BacktickFence;
    if (fenceChar == '~') {
      fenceType = FenceType.TildeFence;
    }

    Parser lineParser = anyLine;
    if (indent > 0) {
      lineParser = atMostSpaces(indent) > lineParser;
    }
    Parser endFenceParser = (((skipSpaces > string(fenceChar * fenceSize)) > char(fenceChar).many) > skipSpaces) > newline;
    Parser restParser = (lineParser.manyUntil(endFenceParser) ^
        (lines) => [new FencedCodeBlock(lines.map((i) => i + '\n').join(), fenceType, fenceSize, new InfoString(infoString))])
      | (lineParser.manyUntil(eof) ^ (List lines) {
        // If fenced code block is ended by eof trim last two new lines;
        if (lines.length > 0 && lines.last == "") {
          lines.removeLast();
        }
        return [new FencedCodeBlock(lines.join('\n'), fenceType, fenceSize, new InfoString(infoString))];
      });

    return restParser.run(s, openFenceRes.position);
  });

  // TODO fenced block in list parser

  Parser listCodeBlockFenced(int listIndentValue) => new Parser((s, pos) {
    assert(listIndentValue > 0);
    Parser listIndent = string(" " * listIndentValue);
    ParseResult openFenceRes = (listIndent.maybe > openFence).run(s, pos);
    if (!openFenceRes.isSuccess) {
      return openFenceRes;
    }
    int indent = openFenceRes.value[0];
    String fenceChar = openFenceRes.value[1];
    int fenceSize = openFenceRes.value[2];
    String infoString = openFenceRes.value[3];

    FenceType fenceType = FenceType.BacktickFence;
    if (fenceChar == '~') {
      fenceType = FenceType.TildeFence;
    }

    // TODO

    Parser endFenceParser = ((((listIndent > skipSpaces) > string(fenceChar * fenceSize)) > char(fenceChar).many) > skipSpaces) > newline;
    Parser lineParser;
    if (indent > 0) {
      lineParser = (listIndent > atMostSpaces(indent)) > anyLine;
    } else {
      lineParser = listIndent > anyLine;
    }

    Position position = openFenceRes.position;
    List<String> res = [];
    while (true) {
      ParseResult endParserRes = (endFenceParser | eof).run(s, position);
      if (endParserRes.isSuccess) {
        position = endParserRes.position;
        break;
      }

      ParseResult lineParserRes = (lineParser | (blankline ^ (_) => "")).run(s, position);
      if (!lineParserRes.isSuccess) {
        break;
      }

      res.add(lineParserRes.value + "\n");
      position = lineParserRes.position;
    }

    return success([new FencedCodeBlock(res.join(), fenceType, fenceSize, new InfoString(infoString))]).run(s, position);
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
        /*| (oneOf('+-*') > char(' '))*/)); // TODO uncomment after lists are implemented
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

  static const _LIST_TYPE_ORDERED = 0;
  static const _LIST_TYPE_UNORDERED = 1;
  static ParserAccumulator3 get orderedListMarkerTest => skipNonindentSpaces + digit.many1 + oneOf('.)');
  static ParserAccumulator2 get unorderedListMarkerTest => skipNonindentSpaces.notFollowedBy(hrule) + oneOf('-+*');
  static Parser get listMarkerTest => (((orderedListMarkerTest ^ (sp, d, c) => [_LIST_TYPE_ORDERED, sp, d, c])
    | (unorderedListMarkerTest ^ (sp, c) => [_LIST_TYPE_UNORDERED, sp, c])) + (char("\n") | char(' ').many1)).list;

  Parser get list => new Parser((s, pos) {
    List<_ListStackItem> stack = [];

    int getSubIndent() => stack.length > 0 ? stack.last.subIndent : 0;
    int getIndent() => stack.length > 0 ? stack.last.indent : 0;
    bool getTight() => stack.length > 0 ? stack.last.tight : true;
    void setTight(bool tight) {
      if (stack.length > 0) {
        stack.last.tight = tight;
      }
    }

    void convertToTight(bool tight, Iterable<ListItem> items) {
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
    }

    bool closeParagraph = false;
    List<Block> blocks = [];
    List<String> buffer = [];
    void buildBuffer() {
      String s = buffer.map((l) => l + "\n").join();
      List<Block> innerBlocks;
      if (s == "\n" && blocks.length == 0) {
        // Test for empty items
        blocks = [new Plain(new _UnparsedInlines(""))]; // TODO replace with inlines
        buffer = [];
        return;
      }
      if (getTight()) {
        ParseResult innerRes = (blockTight.manyUntil(eof) ^ (res) => processParsedBlocks(res)).run(s);
        if (innerRes.isSuccess) {
          innerBlocks = innerRes.value;
        } else {
          setTight(false);
        }
      }

      if (!getTight()) {
        innerBlocks = (block.manyUntil(eof) ^ (res) => processParsedBlocks(res)).parse(s);
      }
      if (!closeParagraph && innerBlocks.length > 0 && innerBlocks.first is Para &&
          acceptLazy(blocks, ((innerBlocks.first as Para).contents as _UnparsedInlines).raw)) {
        innerBlocks.removeAt(0);
      }
      if (innerBlocks.length > 0) {
        blocks.addAll(innerBlocks);
      }
      buffer = [];
    }

    void addToListItem(ListItem item, Iterable<Block> c) {
      if (item.contents is List) {
        (item.contents as List).addAll(c);
        return;
      }
      List<Block> contents = new List.from(item.contents);
      contents.addAll(c);
      item.contents = contents;
    }

    bool addListItem(int type, {IndexSeparator indexSeparator, BulletType bulletType}) {
      bool success = false;
      if (stack.length == 0) {
        return false;
      }
      ListBlock block = stack.last.block;
      if (type == _LIST_TYPE_ORDERED && block is OrderedList && block.indexSeparator == indexSeparator) {
        success = true;
      }
      if (type == _LIST_TYPE_UNORDERED && block is UnorderedList && block.bulletType == bulletType) {
        success = true;
      }
      if (success) {
        buildBuffer();
        addToListItem(block.items.last, blocks);
        blocks = [];
        if (block.items is List) {
          (block.items as List).add(new ListItem([]));
        } else {
          List<ListItem> list = new List.from(block.items);
          list.add(new ListItem([]));
          block.items = list;
        }
      }
      return success;
    }

    Position getNewPositionAfterListMarker(ParseResult res) {
      if (res.value[1] == "\n" || res.value[1].length <= 4) {
        return res.position;
      } else {
        int diff = res.value[1].length - 1;
        return new Position(res.position.offset - diff, res.position.line, res.position.character - diff);
      }
    }

    Position position = pos;

    bool nextLevel = true;

    while (true) {
      ParseResult eofRes = eof.run(s, position);
      if (eofRes.isSuccess) {
        // End of input reached
        break;
      }

      // Test for inner elements
      ParseResult blanklineRes = blankline.run(s, position);
      if (blanklineRes.isSuccess) {
        if (closeParagraph) {
          break;
        }
        closeParagraph = true;
        position = blanklineRes.position;
        continue;
      }

      // TODO lazy line support

      if (position.character == 1 && getSubIndent() > 0) {
        // Waiting for indent
        ParseResult indentRes = string(" " * getSubIndent()).run(s, position);
        if (indentRes.isSuccess) {
          position = indentRes.position;
          nextLevel = true;
        } else {
          nextLevel = false;
          while (getIndent() > 0) {
            ParseResult indentRes = string(" " * getIndent()).run(s, position);
            if (indentRes.isSuccess) {
              position = indentRes.position;
              break;
            }
            convertToTight(getTight(), stack.last.block.items);
            stack.removeLast();
          }
        }
      }

      // Test marker start
      ParseResult markerRes = listMarkerTest.run(s, position);
      if (markerRes.isSuccess) {
        int type = markerRes.value[0][0];
        IndexSeparator indexSeparator = (type == _LIST_TYPE_ORDERED ? IndexSeparator.fromChar(markerRes.value[0][3]) : null);
        int startIndex = type == _LIST_TYPE_ORDERED ? int.parse(markerRes.value[0][2].join(), onError: (_) => 1) : 1;
        BulletType bulletType = (type == _LIST_TYPE_UNORDERED ? BulletType.fromChar(markerRes.value[0][2]) : null);

        if (!nextLevel) {

          bool addSuccess = addListItem(type, indexSeparator: indexSeparator, bulletType: bulletType);
          if (!addSuccess) {
            if (stack.length == 1) {
              // It's a new list on top level. Stopping here
              break;
            }
            // New list on same level
            stack.removeLast();
          } else {
            // TODO update offsets in stack
            position = getNewPositionAfterListMarker(markerRes);
            continue;
          }
        }

        // Flush buffer
        if (stack.length > 0 && (buffer.length > 0 || blocks.length > 0)) {
          buildBuffer();
          addToListItem(stack.last.block.items.last, blocks);
          blocks = [];
        }

        ListBlock newListBlock;
        int subIndent;
        if (type == _LIST_TYPE_ORDERED) {
          newListBlock = new OrderedList([new ListItem([])], indexSeparator, startIndex);
          subIndent = markerRes.value[0][1] + markerRes.value[0][2].length + 1;
        } else {
          newListBlock = new UnorderedList([new ListItem([])], bulletType);
          subIndent = markerRes.value[0][1] + 1;
        }

        if (stack.length > 0) {
          addToListItem(stack.last.block.items.last, [newListBlock]);
        }

        int indent = getIndent();
        if (markerRes.value[1] == "\n" || markerRes.value[1].length > 4) {
          stack.add(new _ListStackItem(indent, indent + subIndent + 1, newListBlock));
        } else {
          stack.add(new _ListStackItem(indent, indent + subIndent + markerRes.value[1].length, newListBlock));
        }
        position = getNewPositionAfterListMarker(markerRes);
        nextLevel = true;
        continue;
      } else if (stack.length == 0) {
        // That was first marker test and it's failed
        return markerRes;
      }

      if (position.character > 1) {
        // Fenced code block
        ParseResult openFenceRes = openFence.run(s, position);
        if (openFenceRes.isSuccess) {
          if (buffer.length > 0) {
            buildBuffer();
          }

          int indent = openFenceRes.value[0];
          String fenceChar = openFenceRes.value[1];
          int fenceSize = openFenceRes.value[2];
          String infoString = openFenceRes.value[3];

          FenceType fenceType = FenceType.BacktickFence;
          if (fenceChar == '~') {
            fenceType = FenceType.TildeFence;
          }

          position = openFenceRes.position;

          Parser indentParser = string(" " * getSubIndent());
          Parser endFenceParser = (((skipSpaces > string(fenceChar * fenceSize)) > char(fenceChar).many) > skipSpaces) > newline;
          Parser lineParser = anyLine;
          if (indent > 0) {
            lineParser = atMostSpaces(indent) > lineParser;
          }

          List<String> code = [];
          while (true) {
            ParseResult eofRes = eof.run(s, position);
            if (eofRes.isSuccess) {
              break;
            }

            ParseResult blanklineRes = blankline.run(s, position);
            if (blanklineRes.isSuccess) {
              position = blanklineRes.position;
              code.add("");
              continue;
            }

            ParseResult indentRes = indentParser.run(s, position);
            if (!indentRes.isSuccess) {
              break;
            }
            position = indentRes.position;

            ParseResult endFenceRes = endFenceParser.run(s, position);
            if (endFenceRes.isSuccess) {
              position = endFenceRes.position;
              break;
            }

            ParseResult lineRes = lineParser.run(s, position);
            if (!lineRes.isSuccess) {
              break;
            }
            code.add(lineRes.value);
            position = lineRes.position;
          }

          blocks.add(new FencedCodeBlock(code.map((i) => i + '\n').join(), fenceType, fenceSize, new InfoString(infoString)));
          closeParagraph = false;
          continue;
        }

        // Strict line
        ParseResult lineRes = anyLine.run(s, position);
        assert(lineRes.isSuccess);
        if (closeParagraph) {
          buffer.add("");
          closeParagraph = false;
        }
        buffer.add(lineRes.value);
        position = lineRes.position;
      } else {
        break;
      }
    }


    if (stack.length > 0) {
      if (buffer.length > 0 || blocks.length > 0) {
        buildBuffer();
        addToListItem(stack.last.block.items.last, blocks);
      }

      stack.forEach((_ListStackItem stackItem) {
        convertToTight(stackItem.tight, stackItem.block.items);
      });

      return success([stack.first.block]).run(s, position);
    } else {
      return fail.run(s, pos);
    }


  });

  /*
  static Parser listFirstLine(int indent, Parser marker) => (atMostSpaces(indent).notFollowedBy(hrule) + marker + anyLine).list;
  static Parser listStrictLine(int indent) => string(" " * indent) > anyLine;
  static Parser listLazyLine(int indent) => atMostSpaces(indent - 1).notFollowedBy(char(' ')) > anyLine;
  static Parser listFencedCodeStartTest(int indent) =>
    (string(" " * indent) + (char(' ') | unorderedListMarkerTest | orderedListMarkerTest).many + (string('```') | string('~~~')) + anyLine).list;
  static Parser listLine(int indent, Parser marker) => // There are three types of lines in list
    (listFirstLine(indent - 1, marker) ^ (l) => [0,  l[0], l[1], l[2]]) // List item start
    | (blankline ^ (l) => [3])                                          // Blank line
    | (listFencedCodeStartTest(indent) ^ (l) => [4, l[0], l[1], l[2], l[3]]) // Special case for fenced code, because it can
                                                                        //   have more than 1 blank line inside
    | (listStrictLine(indent) ^ (l) => [1, l])                          // List item strict continuation
    | (listLazyLine(indent) ^ (l) => [2, l]);                           // List item lazy continuation


  int _listStackPosition;
  List<int> _listStack;
  void _clearListStack() {
    _listStackPosition = -1;
    _listStack = [];
  }
  int _getListStackPosition() {
    ++_listStackPosition;
    return _listStackPosition;
  }
  void _updateListStack(int position, int indent) {
    if (position + 1 > _listStack.length) {
      _listStack.add(indent);
    }
    if (position + 1 < _listStack.length) {
      _listStack.removeRange(position, _listStack.length);
    }
  }

  Parser list(Parser marker) => new Parser((s, pos) {
    ParseResult firstLineRes = listFirstLine(TAB_STOP - 1, marker).run(s, pos);
    if (!firstLineRes.isSuccess) {
      return firstLineRes;
    }

    List<ListItem> items = [];
    List<Block> blocks = [];
    String line = firstLineRes.value[2];
    Position position = pos;
    List<String> buffer = [];

    int indent = firstLineRes.value[0] + firstLineRes.value[1].length;
    int size = min(line.length, 4);
    String substring = line.substring(0, size);
    if (substring != "    ") {
      indent += size - substring.trimLeft().length;
    }

    ParseResult testForFencedCodeBlockAsFirstListBlock(res, indentLength, markerStr) {
      // Line could be fenced code block start
      var codeTestResult = ((orderedListMarkerTest | unorderedListMarkerTest).many.record < openFence).run(line + "\n");
      if (!codeTestResult.isSuccess) {
        buffer.add(line);
      } else {
        int codeIndent = indentLength + markerStr.length + codeTestResult.value.length;

        Parser codeParser = listCodeBlockFenced(codeIndent).record;
        var codeStartPosition = new Position(position.offset + codeIndent, position.line, position.character + codeIndent);
        // TODO fix position
        ParseResult codeResult = codeParser.run(s, codeStartPosition);
        print(s);
        if (codeResult.isSuccess) {
          int i = indentLength + markerStr.length;
          buffer.addAll((codeTestResult.value + codeResult.value).split('\n').map((String l) {
            if (l.substring(0, min(i, l.length)) == " " * i) {
              return l.substring(min(i, l.length), l.length);
            } else {
              return l;
            }
          }));
          res = codeResult;
        } else {
          buffer.add(line);
        }
      }

      return res;
    }

    firstLineRes = testForFencedCodeBlockAsFirstListBlock(firstLineRes, firstLineRes.value[0], firstLineRes.value[1]);
    position = firstLineRes.position;

    bool closeParagraph = false;
    bool tight = true;


    void buildBuffer() {
      String s = buffer.map((l) => l + "\n").join();
      List<Block> innerBlocks;
      if (s == "\n" && blocks.length == 0) {
        // Test for empty items
        blocks = [new Plain(new _UnparsedInlines(""))]; // TODO replace with inlines
        buffer = [];
        return;
      }
      if (tight) {
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

    bool addAtLevel(List<Block> blocks, Iterable<Block> add, int level) {
      if (level == 1) {
        blocks.addAll(add);
        return true;
      } else if (blocks.last is ListBlock) {
        return addAtLevel(blocks.last.items.last.contents, add, level - 1);
      }

      return false;
    }

    int stackPosition = _getListStackPosition();
    _updateListStack(stackPosition, indent);

    Position lastNonBlankPosition = position;
    loop: while (true) {
      ParseResult res = listLine(indent, marker).run(s, position);
      if (!res.isSuccess) {
        break;
      }

      switch (res.value[0]) {
        case 0: // New list item start
          // TODO merge with first line code
          if (closeParagraph) {
            tight = false;
          }
          closeParagraph = true;
          addItem();

          line = res.value[3];
          indent = res.value[1] + res.value[2].length;
          int size = min(line.length, 4);
          String substring = line.substring(0, size);
          if (substring != "    ") {
            indent += size - substring.trimLeft().length;
          }

          print(res);
          res = testForFencedCodeBlockAsFirstListBlock(res, res.value[1], res.value[2]);

          _updateListStack(stackPosition, indent);

          closeParagraph = false;
          // TODO there also could start code block
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

        case 4: // Possible fenced code start
          print(res);
          if (buffer.length > 0) {
            buildBuffer();

            ParseResult codeResult;
            while (_listStack.length > 0) {
              var codeIndent = _listStack.reduce((a, b) => a + b);
              Parser codeParser = listCodeBlockFenced(codeIndent);
              codeResult = codeParser.run(s, position);
              if (codeResult.isSuccess) {
                break;
              }

              _listStack.removeLast();
            }

            if (codeResult == null || !codeResult.isSuccess) {
              String line = res.value[1];

              int size = min(line.length, indent);
              String substring = line.substring(0, size);
              if (substring != " " * size) {
                break loop;
              }

              buffer.add(line.substring(size, line.length));
              closeParagraph = false;
              break;
            }

            addAtLevel(blocks, codeResult.value, _listStack.length);
            res = codeResult;
            closeParagraph = false;
          }
          break;
      }

      position = res.position;
      if (res.value[0] != 3) {
        lastNonBlankPosition = position;
      }
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

    return firstLineRes.copy(position: lastNonBlankPosition, value: items);
  });

  Parser get unorderedList => new Parser((s, pos) {
    ParseResult testRes = unorderedListMarkerTest.run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }
    String markerChar = testRes.value;

    return (list((char(markerChar) > (char(' ') | char('\n').lookAhead)).record) ^ (items) {
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

    return (list(((digit.many1 > char(indexSeparator)) > (char(' ') | char('\n').lookAhead)).record) ^ (items) {
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
  });*/

  //
  // Document
  //

  Parser get document => (block.manyUntil(eof) ^ (res) => new Document(processParsedBlocks(res))) % "document";

  static CommonMarkParser DEFAULT = new CommonMarkParser();
}
