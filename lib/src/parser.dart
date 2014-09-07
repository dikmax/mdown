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


  //
  // Aux parsers
  //

  static Parser spaceChar = oneOf(" \t") % 'space';
  static Parser skipSpaces = spaceChar.skipMany;
  static Parser blankline = skipSpaces > newline % 'blankline';
  static Parser blanklines = blankline.many1 % 'blanklines';
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
      atxHeader
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
    String text = textRes.value.join();
    return textRes.copy(value: [new Header(level, B.nullAttr, [new Str(text)])]);
  });

  // Document
  Parser get document => (block.manyUntil(eof) ^ (res) => new Document(flatten(res))) % "document";

  static CommonMarkParser DEFAULT = new CommonMarkParser();
}
