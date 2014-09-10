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


// CommonMark parser
class CommonMarkParser {
  static const int TAB_STOP = 4;

  CommonMarkParser();

  Map<String, Target> _references;
  List<_UnparsedInlines> _unparsedInlines;

  Map<String, Target> get references => _references; // TODO remove later

  Document parse(String s) {
    // TODO separate preprocess option

    _references = {};
    _unparsedInlines = [];

    var doc = document.parse(preprocess(s) + "\n\n");

    // TODO parse inlines
    return doc;

  }

  // Preprocess

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

  List<Block> precessParsedBlocks(Iterable blocks) {
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


  // HTML

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
      para
  ]);

  // Horizontal rule

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

  // ATX Header

  Parser get atxHeader => new Parser((s, pos) {
    Parser startParser = ((skipNonindentSpaces > char('#').many1) < spaceChar) < skipSpaces;
    ParseResult startRes = startParser.run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    int level = startRes.value.length;
    if (level > 6) {
      return fail.run(s, pos);
    }
    ParseResult textRes = anyChar.manyUntil(char('#').many > newline).run(s, startRes.position);
    if (!textRes.isSuccess) {
      return textRes;
    }
    String raw = textRes.value.join();
    // TODO parse inlines

    _UnparsedInlines inlines = new _UnparsedInlines(raw.trim());
    _unparsedInlines.add(inlines);
    return textRes.copy(value: [new AtxHeader(level, inlines)]);
  });

  // Setext Header

  static const String setextHChars = "=-";

  Parser get setextHeader => new Parser((s, pos) {
    ParseResult res = (((skipNonindentSpaces > anyLine) +
      (skipNonindentSpaces > oneOf(setextHChars).many1)).list < blankline).run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    String raw = res.value[0];
    int level = res.value[1][0] == '=' ? 1 : 2;
    // TODO parse inlines

    _UnparsedInlines inlines = new _UnparsedInlines(raw.trim());
    _unparsedInlines.add(inlines);
    return res.copy(value: [new SetextHeader(level, inlines)]);
  });

  // Indented code

  Parser get indentedLine => (indentSpaces > anyLine) ^ (line) => line + "\n";

  Parser get codeBlockIndented =>
    ((indentedLine | (blanklines + indentedLine) ^ (b, l) => b.join('') + l).many1 < blanklines.maybe) ^
        (c) => new IndentedCodeBlock(stripTrailingNewlines(c.join('')) + '\n');

  // Fenced code

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
    Parser endFenceParser = ((skipSpaces > string(fenceChar * fenceSize)) > skipSpaces) > newline;
    Parser restParser = lineParser.manyUntil(endFenceParser) ^
        (lines) => [new FencedCodeBlock(lines.join('\n') + '\n', new InfoString(infoString))];

    return restParser.run(s, topFenceRes.position);
  });

  // Raw html block

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

  // Link reference

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
    Parser end = blankline | hrule;
    ParseResult res = (end.notAhead > anyLine).many1.run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    _UnparsedInlines inlines = new _UnparsedInlines(res.value.join("\n").trim());
    _unparsedInlines.add(inlines);
    return (blankline.many ^ (_) => new Para(inlines)).run(s, res.position);
  });

  //
  // Document
  //

  Parser get document => (block.manyUntil(eof) ^ (res) => new Document(precessParsedBlocks(res))) % "document";

  static CommonMarkParser DEFAULT = new CommonMarkParser();
}
