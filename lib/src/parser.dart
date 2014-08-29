part of markdown;

class MarkdownParserOptions {
  final bool extInlineCodeAttributes;
  final bool extIntrawordUnderscores;

  const MarkdownParserOptions({this.extInlineCodeAttributes: true,
                 this.extIntrawordUnderscores: true});

  static const MarkdownParserOptions PANDOC = const MarkdownParserOptions();
  static const MarkdownParserOptions DEFAULT = PANDOC;
}

class MarkdownParser {
  final MarkdownParserOptions options;

  MarkdownParser([this.options = MarkdownParserOptions.DEFAULT]);

  Document parse(String s) => document.parse(s);

  // Simple parsers

  /*
escapedChar' :: MarkdownParser Char
escapedChar' = try $ do
  char '\\'
  (guardEnabled Ext_all_symbols_escapable >> satisfy (not . isAlphaNum))
     <|> oneOf "\\`*_{}[]()>#+-.!~\""

 */

  static Parser spaceChar = oneOf(" \t") % 'space';
  static Parser skipSpaces = spaceChar.skipMany;
  static Parser blankline = skipSpaces > newline % 'blankline';
  static Parser blanklines = blankline.many1 % 'blanklines';


//final litChar =
/*
litChar :: MarkdownParser Char
litChar = escapedChar'
       <|> characterReference
       <|> noneOf "\n"
       <|> try (newline >> notFollowedBy blankline >> return ' ')

 */

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

  // Attributes

  static Parser identifier = (letter + (alphanum | oneOf("-_:.")).many) ^ (a, b) {
    String res = a;
    if (b != null && b.length > 0) {
      res += b.join('');
    }
    return res;
  };
  static Parser identifierAttr = (char('#') > identifier) ^ (id) => B.attr(id, [], {});
  static Parser classAttr = (char('.') > identifier) ^ (cl) => B.attr("", [cl], {});
  /*final Parser keyValAttr = (identifier < char('=')) +
  ( enclosed(char('"'), char('"'), litChar) )*/
/*


keyValAttr :: MarkdownParser (Attr -> Attr)
keyValAttr = try $ do
  key <- identifier
  char '='
  val <- enclosed (char '"') (char '"') litChar
     <|> enclosed (char '\'') (char '\'') litChar
     <|> many (escapedChar' <|> noneOf " \t\n\r}")
  return $ \(id',cs,kvs) -> (id',cs,kvs ++ [(key,val)])

specialAttr :: MarkdownParser (Attr -> Attr)
specialAttr = do
  char '-'
  return $ \(id',cs,kvs) -> (id',cs ++ ["unnumbered"],kvs)


   */
  static Parser attribute = choice([
      identifierAttr,
      classAttr
  ]);
  static Parser attributes = (char("{") > spnl) > ((attribute < spnl).many < char("}")) ^
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
  /*
  code :: MarkdownParser (F Inlines)
  code = try $ do
    starts <- many1 (char '`')
    skipSpaces
    result <- many1Till (many1 (noneOf "`\n") <|> many1 (char '`') <|>
                         (char '\n' >> notFollowedBy' blankline >> return " "))
                        (try (skipSpaces >> count (length starts) (char '`') >>
                        notFollowedBy (char '`')))
    attr <- option ([],[],[]) (try $ guardEnabled Ext_inline_code_attributes >>
                                     optional whitespace >> attributes)
    return $ return $ B.codeWith attr $ trim $ concat result

   */

  // Emphasis or strong

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

  // Inline definition

  Parser get inline => choice([
                  whitespace,
                  strongOrEmphStar(),
                  strongOrEmphUnderscore(),
                  str,
                  endline,
                  code(),
                  symbol
                  ]);


  // Block parsers

  Parser get para => (newline + blanklines + anyChar.manyUntil(newline) ^ (_1, _2, inlines) {
    return new Para(inline.run(inlines));
  }) % "para";
  Parser get plain => inline.many1 ^ ((inlines) => new Para(inlines));

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
