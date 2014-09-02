part of markdown;

class MarkdownParser {
  final MarkdownParserOptions options;

  MarkdownParser([this.options = MarkdownParserOptions.DEFAULT]);

  Document parse(String s) => document.parse(s);

  // OptionsCheck

  Parser guardEnabled(bool option) => option ? success(null) : fail;

  Parser guardDisabled(bool option) => option ? fail : success(null);

  // Simple parsers

  // TODO move to unicode-parsers library
  bool isAlphaNum(String ch) => isLetter(ch.runes.first) || isDigit(ch.runes.first);

  Parser get escapedChar1 => char('\\') >
  ( (guardEnabled(options.allSymbolsEscapable) > pred((ch) => !isAlphaNum(ch)))
  | oneOf("\\`*_{}[]()>#+-.!~\"")
  );

  static Parser spaceChar = oneOf(" \t") % 'space';
  static Parser nonSpaceChar = noneOf("\t\n \r");
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

  Parser get anyLine => new Parser((s, Position pos) {
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
    print(result);
    return new ParseResult(s, new Expectations.empty(newPos), newPos, true, false, result);
  });

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

  Parser count(int l, Parser p) {
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

  // Identifier

  static Parser identifier = (letter + (alphanum | oneOf("-_:.")).many) ^ (a, b) {
    String res = a;
    if (b != null && b.length > 0) {
      res += b.join('');
    }
    return res;
  };

  // Attribute parsers

  static Parser identifierAttr = (char('#') > identifier) ^ (id) => B.attr(id, [], {
  });
  static Parser classAttr = (char('.') > identifier) ^ (cl) => B.attr("", [cl], {
  });

  Parser get keyValAttr => (identifier < char('=')) +
  choice([
      enclosed(char('"'), char('"'), litChar),
      enclosed(char('\''), char('\''), litChar),
      (escapedChar1 | noneOf(" \t\n\r}")).many
  ]) ^ (key, value) => B.attr("", [], {
      key: value.join('')
  });

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
    return new Parser((s, pos) {
      var i = inline;
      return (start + i + i.manyUntil(end) ^ (a, b, c) {
        List<Inline> res = [b];
        if (c.length > 0) {
          res.addAll(c);
        }
        return res;
      }).run(s, pos);
    });
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
      if (!options.inlineCodeAttributes) {
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

  Parser get endUnderscore => options.intrawordUnderscores
  ? char('_').notFollowedBy(alphanum)
  : char('_');

  Parser get startUnderscore => options.intrawordUnderscores
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

  Parser quotedTitle(c) => (char(c) > (noneOf("\\\n&" + c) | litChar).manyUntil(char(c))).orElse(['']) ^ (a) => a.join('');

  Parser get linkTitle => quotedTitle('"') | quotedTitle('\'');

  Parser get _urlChunk => parenthesizedChars
  | (oneOf(" )").notAhead > litChar)
  | (spaceChar.many1.notFollowedBy(oneOf("\"')")));

  Parser get _sourceURL => _urlChunk.many ^ (r) => r.join('');

  Parser get _betweenAngles => char('<') > litChar.manyUntil(char('>')) ^ (r) => r.join('');

  Parser get source => (((char('(') > skipSpaces) >
  (((_betweenAngles | _sourceURL) + (spnl > linkTitle)) ^ B.target)) <
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
      return (source ^ (Target target) => new Link(refRes.value[0], target)).run(s, refRes.position);
      // Add reference link
    });
  }

/*
-- a link like [this][ref] or [this][] or [this]
referenceLink :: (String -> String -> Inlines -> Inlines)
              -> (F Inlines, String) -> MarkdownParser (F Inlines)
referenceLink constructor (lab, raw) = do
  sp <- (True <$ lookAhead (char ' ')) <|> return False
  (ref,raw') <- try
           (skipSpaces >> optional (newline >> skipSpaces) >> reference)
           <|> return (mempty, "")
  let labIsRef = raw' == "" || raw' == "[]"
  let key = toKey $ if labIsRef then raw else raw'
  parsedRaw <- parseFromString (mconcat <$> many inline) raw'
  fallback <- parseFromString (mconcat <$> many inline) $ dropBrackets raw
  implicitHeaderRefs <- option False $
                         True <$ guardEnabled Ext_implicit_header_references
  let makeFallback = do
       parsedRaw' <- parsedRaw
       fallback' <- fallback
       return $ B.str "[" <> fallback' <> B.str "]" <>
                (if sp && not (null raw) then B.space else mempty) <>
                parsedRaw'
  return $ do
    keys <- asksF stateKeys
    case M.lookup key keys of
       Nothing        -> do
         headers <- asksF stateHeaders
         ref' <- if labIsRef then lab else ref
         if implicitHeaderRefs
            then case M.lookup ref' headers of
                   Just ident -> constructor ('#':ident) "" <$> lab
                   Nothing    -> makeFallback
            else makeFallback
       Just (src,tit) -> constructor src tit <$> lab
 */

  // Image

  // TODO readerDefaultImageExtension support
  // TODO Add reference link (referenceLink parser)
  Parser get image => ((char('!') > reference) + source) ^ (inlines, target) => new Image(inlines[0], target);

  // Strikeout

  Parser get strikeout => options.strikeout
  ? inlinesBetween(string('~~').notFollowedBy(char('~')) > noneOf('\t\n \r').lookAhead, string('~~')) ^ (i) => new Strikeout(i)
  : fail;

  // Subscript

  Parser get subscript => options.subscript
  ? new Parser((s, pos) {
    return (char('~') > many1Till(spaceChar.notAhead > inline, char('~')) ^ (i) => new Subscript(i)).run(s, pos);
  })
  : fail;

  Parser get superscript => options.superscript
  ? new Parser((s, pos) {
    return (char('^') > many1Till(spaceChar.notAhead > inline, char('^')) ^ (i) => new Superscript(i)).run(s, pos);
  })
  : fail;

  // Escaped char

  Parser escapedChar() {
    return new Parser((s, pos) {
      ParseResult res = escapedChar1.run(s, pos);
      if (!res.isSuccess) {
        return res;
      }

      switch (res.value) {
        case ' ':
          res = res.copy(value: new NonBreakableSpace());
          break;

        case '\n':
          if (options.escapedLineBreaks) {
            res = res.copy(value: new LineBreak());
          } else {
            return fail.run(s, pos);
          }
          break;

        default:
          res = res.copy(value: new Str(res.value));
      }

      return res;
    });
  }

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
      image,
      // math,
      strikeout,
      subscript,
      superscript,
      // inlineNote, -- after superscript because of ^[link](/foo)^
      // autoLink,
      // spanHtml,
      // rawHtmlInline,
      escapedChar(),
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

  // Para
  Parser get para => (((newline > blanklines) > anyChar.manyUntil(newline)) ^
      (inlines) => new Para(groupInlines(inline.many1.run(inlines)))) % "para";

  /*
  para :: MarkdownParser (F Blocks)
para = try $ do
  exts <- getOption readerExtensions
  result <- trimInlinesF . mconcat <$> many1 inline
  option (B.plain <$> result)
    $ try $ do
            newline
            (blanklines >> return mempty)
              <|> (guardDisabled Ext_blank_before_blockquote >> () <$ lookAhead blockQuote)
              <|> (guardEnabled Ext_backtick_code_blocks >> () <$ lookAhead codeBlockFenced)
              <|> (guardDisabled Ext_blank_before_header >> () <$ lookAhead header)
              <|> (guardEnabled Ext_lists_without_preceding_blankline >>
                       () <$ lookAhead listStart)
            return $ do
              result' <- result
              case B.toList result' of
                   [Image alt (src,tit)]
                     | Ext_implicit_figures `Set.member` exts ->
                        -- the fig: at beginning of title indicates a figure
                        return $ B.para $ B.singleton
                               $ Image alt (src,'f':'i':'g':':':tit)
                   _ -> return $ B.para result'

   */

  // Plain
  Parser get plain => inline.many1 ^ ((inlines) => new Para(groupInlines(inlines)));

  // Code Block Fenced

  Parser blockDelimiter(String c, [int len]) {
    if (len != null) {
      return (count(len, char(c)) > char(c).many) ^ (_) => len;
    } else {
      return (count(3, char(c)) > char(c).many) ^ (res) => res.length + 3;
    }
  }

  String toLanguageId(String id) {
    id = id.toLowerCase();
    switch (id) {
      case 'c++':
        return 'cpp';

      case 'objective-c':
        return 'objectivec';

      default:
        return id;
    }
  }

  Parser get codeBlockFenced => new Parser((s, pos) {
    var c;
    if (options.fencedCodeBlocks) {
      var testRes = char('~').lookAhead.run(s, pos);
      if (testRes.isSuccess) {
        c = '~';
      }
    }
    if (c == null && options.backtickCodeBlocks) {
      var testRes = char('`').lookAhead.run(s, pos);
      if (testRes.isSuccess) {
        c = '`';
      }
    }

    if (c == null) {
      // TODO expose _failure and _success functions
      fail.run(s, pos);
    }

    ParseResult startRes = blockDelimiter(c).run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    var size = startRes.value;
    ParseResult attrRes = (spaceChar.skipMany > ((guardEnabled(options.fencedCodeAttributes) > attributes) |
    (nonSpaceChar.many1 ^ (str) => B.attr("", [toLanguageId(str.join(''))], {
    })))).orElse(B.nullAttr).run(s, startRes.position);
    assert(attrRes.isSuccess);
    var attr = attrRes.value;
    return (((blankline > anyLine.manyUntil(blockDelimiter(c, size))) < blanklines) ^
        (lines) => B.codeBlock(lines.join('\n'), attr)).run(s, attrRes.position);
  });


  // Header

  Parser get header => /*setextHeader | */
  atxHeader % "header";

  /*
header :: MarkdownParser (F Blocks)
header = setextHeader <|> atxHeader <?> "header"
*/

  Parser get atxHeader => new Parser((s, pos) {
    Parser startParser = char('#').many1;
    if (options.fancyLists) {
      startParser = startParser.notFollowedBy(oneOf(".)"));
    }
    ParseResult startRes = startParser.run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    int level = startRes.value.length;
  });


  /*
atxHeader :: MarkdownParser (F Blocks)
atxHeader = try $ do
  level <- many1 (char '#') >>= return . length
  notFollowedBy $ guardEnabled Ext_fancy_lists >>
                  (char '.' <|> char ')') -- this would be a list
  skipSpaces
  text <- trimInlinesF . mconcat <$> many (notFollowedBy atxClosing >> inline)
  attr <- atxClosing
  attr' <- registerHeader attr (runF text defaultParserState)
  return $ B.headerWith attr' level <$> text

atxClosing :: MarkdownParser Attr
atxClosing = try $ do
  attr' <- option nullAttr
             (guardEnabled Ext_mmd_header_identifiers >> mmdHeaderIdentifier)
  skipMany (char '#')
  skipSpaces
  attr <- option attr'
             (guardEnabled Ext_header_attributes >> attributes)
  blanklines
  return attr

setextHeaderEnd :: MarkdownParser Attr
setextHeaderEnd = try $ do
  attr <- option nullAttr
          $ (guardEnabled Ext_mmd_header_identifiers >> mmdHeaderIdentifier)
           <|> (guardEnabled Ext_header_attributes >> attributes)
  blanklines
  return attr

mmdHeaderIdentifier :: MarkdownParser Attr
mmdHeaderIdentifier = do
  ident <- stripFirstAndLast . snd <$> reference
  skipSpaces
  return (ident,[],[])

setextHeader :: MarkdownParser (F Blocks)
setextHeader = try $ do
  -- This lookahead prevents us from wasting time parsing Inlines
  -- unless necessary -- it gives a significant performance boost.
  lookAhead $ anyLine >> many1 (oneOf setextHChars) >> blankline
  text <- trimInlinesF . mconcat <$> many1 (notFollowedBy setextHeaderEnd >> inline)
  attr <- setextHeaderEnd
  underlineChar <- oneOf setextHChars
  many (char underlineChar)
  blanklines
  let level = (fromMaybe 0 $ findIndex (== underlineChar) setextHChars) + 1
  attr' <- registerHeader attr (runF text defaultParserState)
  return $ B.headerWith attr' level <$> text

   */

  // Block parsers
  Parser get block => choice([
      blanklines ^ (_) => null,
      codeBlockFenced,
      // yamlMetaBlock,
      // guardEnabled Ext_latex_macros *> (macro >>= return . return)
      // bulletList
      // header
      // lhsCodeBlock
      // rawTeXBlock
      // divHtml
      // htmlBlock
      // table
      // lineBlock
      // codeBlockIndented
      // blockQuote
      // hrule
      // orderedList
      // definitionList
      // noteBlock
      // referenceKey
      // abbrevKey
      para,
      plain,

  ]) % "block";

  // Document
  Parser get document => (block.manyUntil(eof) ^ (res) => new Document(res.where((block) => block != null))) % "document";

  static MarkdownParser DEFAULT = new MarkdownParser();
}
