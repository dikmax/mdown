part of markdown;

// Other parsers
final Parser spaceChar = oneOf(" \t") % 'space';
final Parser skipSpaces = spaceChar.skipMany;

final Parser spnl = (skipSpaces > newline.maybe) > skipSpaces.notFollowedBy(char('\n'));

final Parser identifier = (letter + (alphanum | oneOf("-_:.")).many) ^ (a, b) {
  String res = a;
  if (b != null && b.length > 0) {
    res += b.join('');
  }
  return res;
};
final Parser identifierAttr = char('#') + identifier ^ (a, id) => B.attr(id, [], {});
/*

identifier :: MarkdownParser String
identifier = do
  first <- letter
  rest <- many $ alphaNum <|> oneOf "-_:."
  return (first:rest)

identifierAttr :: MarkdownParser (Attr -> Attr)
identifierAttr = try $ do
  char '#'
  result <- identifier
  return $ \(_,cs,kvs) -> (result,cs,kvs)

classAttr :: MarkdownParser (Attr -> Attr)
classAttr = try $ do
  char '.'
  result <- identifier
  return $ \(id',cs,kvs) -> (id',cs ++ [result],kvs)

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


  attribute :: MarkdownParser (Attr -> Attr)
attribute = identifierAttr <|> classAttr <|> keyValAttr <|> specialAttr

   */
final Parser attribute = choice([
    identifierAttr
]);
//final Parser attributes = ((char("{") > spnl) > (attribute < spnl).many) < char("}");
final Parser attributes = char("{") + spnl + (attribute + spnl ^ (a, b) => a).many + char("}") ^ (a, b, Iterable c, d) {
  return c.reduce((v, e) => v + e);
};


Parser<Document> getParser({bool extInlineCodeAttributes: true,
                           bool extIntrawordUnderscores: true}) {
  final Parser blankline = skipSpaces > newline % 'blankline';
  final Parser blanklines = blankline.many1 % 'blanklines';

  // Inline parsers
  Parser inline; // Defined later
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
      if (!extInlineCodeAttributes) {
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
  Parser endUnderscore = extIntrawordUnderscores
    ? char('_').notFollowedBy(alphanum)
    : char('_');
  Parser startUnderscore = extIntrawordUnderscores
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

  inline = choice([
      whitespace,
      strongOrEmphStar(),
      strongOrEmphUnderscore(),
      str,
      endline,
      code(),
      symbol
  ]);

  final Parser para = (newline + blanklines + anyChar.manyUntil(newline) ^ (_1, _2, inlines) {
    return new Para(inline.run(inlines));
  }) % "para";
  final Parser plain = inline.many1 ^ ((inlines) => new Para(inlines));

  // Block parsers
  final Parser block = choice([
      blanklines ^ (_) => null,
      para,
      plain
  ]) % "block";

  return (block.manyUntil(eof) ^ (res) => new Document(res.where((block) => block != null))) % "document";
}
