part of markdown;

class MarkdownParserOptions {
  final bool extAllSymbolsEscapable;
  final bool extInlineCodeAttributes;
  final bool extIntrawordUnderscores;

  const MarkdownParserOptions({
    this.extAllSymbolsEscapable: true,
    this.extInlineCodeAttributes: true,
    this.extIntrawordUnderscores: true
  });

  static const MarkdownParserOptions PANDOC = const MarkdownParserOptions();
  static const MarkdownParserOptions DEFAULT = PANDOC;
}

class MarkdownParser {
  final MarkdownParserOptions options;

  MarkdownParser([this.options = MarkdownParserOptions.DEFAULT]);

  Document parse(String s) => document.parse(s);

  // OptionsCheck

  Parser guardEnabled(bool option) => option ? success(null) : fail;
  Parser guardDisabled(bool option) => option ? fail : success(null);

  // Simple parsers

  // TODO move to unicode-parsers library
  bool isAlphaNum(String ch) => !isLetter(ch.runes.first) && !isDigit(ch.runes.first);

  Parser get escapedChar1 => char('\\') >
    ( guardEnabled(options.extAllSymbolsEscapable) > pred((ch) => !isAlphaNum(ch))
    | oneOf("\\`*_{}[]()>#+-.!~\"")
    );
  static Parser spaceChar = oneOf(" \t") % 'space';
  static Parser skipSpaces = spaceChar.skipMany;
  static Parser blankline = skipSpaces > newline % 'blankline';
  static Parser blanklines = blankline.many1 % 'blanklines';

  Parser get litChar => choice([
    escapedChar1,
    // TODO characterReference,
    noneOf("\n"),
    newline.notFollowedBy(blankline) > success(' ')
  ]);

  Parser get inlinesInBalancedBrackets => everythingBetween(char('['), char(']'), nested: true) ^
      (string) => groupInlines(inline.many1.run(string));

  List<Inline> trimInlines(List<Inline> inlines) {
    while (inlines.last == new Space()) {
      inlines.removeLast();
    }
    while (inlines.first == new Space()) {
      inlines.removeAt(0);
    }
    return inlines;
  }

  static Parser spnl = (skipSpaces > newline.maybe) > skipSpaces.notFollowedBy(char('\n'));

  // Basic combining parsers

  Parser many1Till(Parser parser, Parser end) => parser + parser.manyUntil(end) ^ (a, b) {
    List<Inline> res = [a];
    if (b.length > 0) {
      res.addAll(b);
    }
    return res;
  };

  Parser enclosed(Parser start, Parser end, Parser middle) {
    return (start.notFollowedBy(space) > many1Till(middle, end));
  }

  Parser notAfterString() {
    return new Parser((s, Position pos) {
      if (pos.character == 1) {
        return success(null).run(s, pos);
      }
      var prevpos = new Position(pos.offset - 1, pos.line, pos.character - 1);
      var result = alphanum.run(s, prevpos);

      if (result.isSuccess) {
        return fail.run(s, pos);
      } else {
        return success(null).run(s, pos);
      }
    });
  }

  // Identifier

  static Parser identifier = (letter + (alphanum | oneOf("-_:.")).many) ^ (a, b) {
    String res = a;
    if (b != null && b.length > 0) {
      res += b.join('');
    }
    return res;
  };

  // Attribute parsers

  static Parser identifierAttr = (char('#') > identifier) ^ (id) => B.attr(id, [], {});
  static Parser classAttr = (char('.') > identifier) ^ (cl) => B.attr("", [cl], {});
  Parser get keyValAttr => (identifier < char('=')) +
    choice([
        enclosed(char('"'), char('"'), litChar),
        enclosed(char('\''), char('\''), litChar),
        (escapedChar1 | noneOf(" \t\n\r}")).many
    ]) ^ (key, value) => B.attr("", [], {key: value.join('')});

  Parser get attribute => choice([
      identifierAttr,
      classAttr,
      keyValAttr
  ]);
  Parser get attributes => (char("{") > spnl) > ((attribute < spnl).many < char("}")) ^
      (Iterable c) => c.reduce((v, e) => v + e);

  // Inline parsers
  final Parser whitespace = (spaceChar + skipSpaces ^ (_1, _2) => new Space()) % "whitespace";
  final Parser str = alphanum.many1 ^ (chars) => new Str(chars.join(""));
  final Parser endline = newline.notFollowedBy(blankline) ^ (_) => new Space();
  final Parser symbol = noneOf("<\\\n\t ") ^ (ch) => new Str(ch);

  Parser inlinesBetween(Parser start, Parser end) {
    return start + inline + inline.manyUntil(end) ^ (a, b, c) {
      List<Inline> res = [b];
      if (c.length > 0) {
        res.addAll(c);
      }
      return res;
    };
  }

  // Code

  Parser code() {
    return new Parser((s, pos) {
      ParseResult start = char('`').many1.run(s, pos);
      if (!start.isSuccess) {
        return start;
      }
      ParseResult res = skipSpaces.run(s, start.position);
      if (!res.isSuccess) {
        return res;
      }

      Parser codeInner = (noneOf("`\n").many1 ^ (list) => list.join(''))
      | (char('`').many1 ^ (list) => list.join(''))
      | (char('\n').notFollowedBy(blankline) ^ (a) => ' ');
      Parser codeEnd = skipSpaces + string(start.value.join('')).notFollowedBy(char('`')) ^ (a, b) => null;

      ParseResult codeResult = (codeInner + codeInner.manyUntil(codeEnd) ^ (a, b) {
        List<Inline> res = [a];
        if (b.length > 0) {
          res.addAll(b);
        }
        return B.code(res.join(''));
      }).run(s, res.position);
      if (!codeResult.isSuccess) {
        return codeResult;
      }
      if (!options.extInlineCodeAttributes) {
        return codeResult;
      }
      ParseResult attrRes = (whitespace.maybe + attributes ^ (a, b) => b).run(s, codeResult.position);
      if (attrRes.isSuccess) {
        Code code = codeResult.value;
        code.attributes = attrRes.value;
        ParseResult res = attrRes.copy(value: code);
        return res;
      }
      return codeResult;
    });
  }

  // Emphasis or strong

  Parser strongOrEmphStar() {
    return new Parser((s, pos) {
      Parser p = (inlinesBetween(string("**"), string("**")) ^ (a) => new Strong(a))
      | (inlinesBetween(char("*"), char("*").notFollowedBy(char("*"))) ^ (a) => new Emph(a))
      | (inlinesBetween(char("*"), char("*")) ^ (a) => new Emph(a));
      return p.run(s, pos);
    });
  }
  Parser get endUnderscore => options.extIntrawordUnderscores
    ? char('_').notFollowedBy(alphanum)
    : char('_');
  Parser get startUnderscore => options.extIntrawordUnderscores
    ? notAfterString() + char('_') ^ (a, b) => null
    : char('_');
  Parser strongOrEmphUnderscore() {
    return new Parser((s, pos) {
      Parser p = (inlinesBetween(string("__"), string("__")) ^ (a) => new Strong(a))
      | (inlinesBetween(startUnderscore, endUnderscore.notFollowedBy(char("_"))) ^ (a) => new Emph(a))
      | (inlinesBetween(startUnderscore, endUnderscore) ^ (a) => new Emph(a));
      return p.run(s, pos);
    });
  }

  // Link


  static Parser parenthesizedChars = everythingBetween(char('('), char(')'), nested: true) ^ (chars) => '(' + chars.join('') + ')';

  // Get parsed inlines along with raw version
  Parser get reference => string("[^").notAhead > everythingBetween(char('['), char(']'), nested: true) ^
      (string) => [(inline.many1 ^ (a) => trimInlines(groupInlines(a))).parse(string), string];

  /*
  reference :: MarkdownParser (F Inlines, String)
    reference = do notFollowedBy' (string "[^")   -- footnote reference
               withRaw $ trimInlinesF <$> inlinesInBalancedBrackets

   */

  /*
  source :: MarkdownParser (String, String)
source = do
  char '('
  skipSpaces
  let urlChunk =
            try parenthesizedChars
        <|> (notFollowedBy (oneOf " )") >> (count 1 litChar))
        <|> try (many1 spaceChar <* notFollowedBy (oneOf "\"')"))
  let sourceURL = (unwords . words . concat) <$> many urlChunk
  let betweenAngles = try $
         char '<' >> manyTill litChar (char '>')
  src <- try betweenAngles <|> sourceURL
  tit <- option "" $ try $ spnl >> linkTitle
  skipSpaces
  char ')'
  return (escapeURI $ trimr src, tit)

   */

  Parser quotedTitle(c) => (char(c).notFollowedBy(spaces) > (noneOf("\\\n&" + c) | litChar).manyUntil(char(c))).orElse('');
  /*
  quotedTitle :: Char -> MarkdownParser String
quotedTitle c = try $ do
  char c
  notFollowedBy spaces
  let pEnder = try $ char c >> notFollowedBy (satisfy isAlphaNum)
  let regChunk = many1 (noneOf ['\\','\n','&',c]) <|> count 1 litChar
  let nestedChunk = (\x -> [c] ++ x ++ [c]) <$> quotedTitle c
  unwords . words . concat <$> manyTill (nestedChunk <|> regChunk) pEnder

   */
  Parser get linkTitle => quotedTitle('"') | quotedTitle('\'');

  Parser get urlChunk => parenthesizedChars
    | (oneOf(" )").notAhead > litChar)
    | (spaceChar.many1.notFollowedBy(oneOf("\"')")));
  Parser get sourceURL => urlChunk.many ^ (r) => r.join('');
  Parser get betweenAngles => char('<') > litChar.manyUntil(char('>')) ^ (r) => r.join('');
  Parser get source => (((char('(') > skipSpaces) >
    (((betweenAngles | sourceURL) + (spnl > linkTitle)) ^ B.target)) <
    skipSpaces) < char(')');

  bool allowLinks = true;

  Parser link() {
    return new Parser((s, pos) {
      if (!allowLinks) {
        return fail.run(s, pos);
      }

      allowLinks = false;

      ParseResult refRes = reference.run(s, pos);

      allowLinks = true;

      if (!refRes.isSuccess) {
        // This can't be.
        return refRes;
      }

      // TODO Add reference link (referenceLink parser)
      return regLink(refRes.value).run(s, refRes.position); // Add reference link

    });
  }

/*
link :: MarkdownParser (F Inlines)
link = try $ do
  st <- getState
  guard $ stateAllowLinks st
  setState $ st{ stateAllowLinks = False }
  (lab,raw) <- reference
  setState $ st{ stateAllowLinks = True }
  regLink B.link lab <|> referenceLink B.link (lab,raw)
 */

  Parser regLink(inlines) => source ^ (Target target) => new Link(inlines, target);

  /*
  regLink :: (String -> String -> Inlines -> Inlines)
        -> F Inlines -> MarkdownParser (F Inlines)
regLink constructor lab = try $ do
  (src, tit) <- source
  return $ constructor src tit <$> lab

   */
  // Inline definition

  Parser get inline => choice([
    whitespace,
    // bareURL,
    str,
    endline,
    code(),
    strongOrEmphStar(),
    strongOrEmphUnderscore(),
    // note,
    // cite,
    link(),
    // image,
    // math,
    // strikeout,
    // subscript,
    // superscript,
    // inlineNote, -- after superscript because of ^[link](/foo)^
    // autoLink,
    // spanHtml,
    // rawHtmlInline,
    // escapedChar,
    // rawLaTeXInline'
    // exampleRef
    // smart
    // return . B.singleton <$> charRef
    symbol
    // ltSign
  ]);


  // Block parsers

  List<Inline> groupInlines(Iterable<Inline> inlines) {
    List<Inline> result = [];
    Inline prev;
    for (Inline inline in inlines) {
      if (prev == null) {
        prev = inline;
        continue;
      }

      if (inline is Str && prev is Str) {
        (prev as Str).str += inline.str;
      } else {
        result.add(prev);
        prev = inline;
      }
    }

    if (prev != null) {
      result.add(prev);
    }

    return result;
  }

  Parser get para => (((newline > blanklines) > anyChar.manyUntil(newline)) ^
      (inlines) => new Para(groupInlines(inline.many1.run(inlines)))) % "para";
  Parser get plain => inline.many1 ^ ((inlines) => new Para(groupInlines(inlines)));

  // Block parsers
  Parser get block => choice([
      blanklines ^ (_) => null,
      para,
      plain
  ]) % "block";


  // Document
  Parser get document => (block.manyUntil(eof) ^ (res) => new Document(res.where((block) => block != null))) % "document";

  static MarkdownParser DEFAULT = new MarkdownParser();
}
