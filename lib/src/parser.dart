part of markdown;

// CommonMark parser
class CommonMarkParser {
  static const int TAB_STOP = 4;

  CommonMarkParser();

  Document parse(String s) {
    // TODO separate preprocess option

    return document.parse(preprocess(s) + "\n\n");
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
  static Parser skipSpaces = spaceChar.skipMany;
  static Parser blankline = skipSpaces > newline % 'blankline';
  static Parser blanklines = blankline.many1 % 'blanklines';
  Parser get indentSpaces => count(TAB_STOP, char(' ')) | char('\t') % "indentation";
  Parser get skipNonindentSpaces => atMostSpaces(TAB_STOP - 1).notFollowedBy(char(' '));

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

  //
  // Blocks
  //

  Parser<List<Block>> get block => choice([
      blanklines ^ (_) => [],
      hrule,
      atxHeader,
      setextHeader,
      codeBlockIndented
  ]);

  // Horizontal rule

  static const String hruleChars = '*-_';

  static Parser get hrule => new Parser((s, pos) {
    ParseResult startRes = (skipSpaces > oneOf(hruleChars)).run(s, pos);
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

    return textRes.copy(value: [new Header(level, B.nullAttr, [new Str(raw)])]);
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

    return res.copy(value: [new Header(level, B.nullAttr, [new Str(raw)])]);
  });

  // Indented code

  Parser get indentedLine => (indentSpaces > anyLine) ^ (line) => line + "\n";

  Parser get codeBlockIndented =>
    ((indentedLine | (blanklines + indentedLine) ^ (b, l) => b.join('') + l).many1 < blanklines.maybe) ^
        (c) => B.codeBlock(stripTrailingNewlines(c.join('')) + '\n', B.nullAttr);

  //
  // Document
  //

  Parser get document => (block.manyUntil(eof) ^ (res) => new Document(flatten(res))) % "document";

  static CommonMarkParser DEFAULT = new CommonMarkParser();
}
