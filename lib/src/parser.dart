part of markdownf;

class MarkdownParser {
  final MarkdownParserExtensions extensions;
  MarkdownParserOptions options;

  MarkdownParser([this.extensions = MarkdownParserExtensions.DEFAULT, this.options]) {
    if (options == null) {
      options = new MarkdownParserOptions();
    }
  }

  Document parse(String s) => document.parse(s);

  // OptionsCheck

  // TODO Remove guards
  Parser guardEnabled(bool option) => option ? success(null) : fail;

  Parser guardDisabled(bool option) => option ? fail : success(null);

  // Aux methods

  String stripTrailingNewlines(String str) {
    var l = str.length;
    while (l > 0 && str[l - 1] == '\n') {
      --l;
    }
    return str.substring(0, l);
  }

  // Simple parsers

  // TODO move to unicode-parsers library
  bool isAlphaNum(String ch) => isLetter(ch.runes.first) || isDigit(ch.runes.first);

  Parser get escapedChar1 => char('\\') >
    ( (guardEnabled(extensions.allSymbolsEscapable) > pred((ch) => !isAlphaNum(ch)))
    | oneOf("\\`*_{}[]()>#+-.!~\"")
    );

  static Parser spaceChar = oneOf(" \t") % 'space';
  static Parser nonSpaceChar = noneOf("\t\n \r");
  static Parser skipSpaces = spaceChar.skipMany;
  static Parser blankline = skipSpaces > newline % 'blankline';
  static Parser blanklines = blankline.many1 % 'blanklines';
  Parser get skipNonindentSpaces => atMostSpaces(options.tabStop - 1).notFollowedBy(char(' '));

  /*
  skipNonindentSpaces :: MarkdownParser Int
skipNonindentSpaces = do
  tabStop <- getOption readerTabStop
  atMostSpaces (tabStop - 1) <* notFollowedBy (char ' ')

   */

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

  /*
  atMostSpaces :: Int -> MarkdownParser Int
atMostSpaces n
  | n > 0     = (char ' ' >> (+1) <$> atMostSpaces (n-1)) <|> return 0
  | otherwise = return 0
   */

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

  // TODO check dependent rules and make them static
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

  static Parser spnl = (skipSpaces > newline.maybe) > skipSpaces.notFollowedBy(char('\n'));

  Parser get indentSpaces => count(options.tabStop, char(' ')) | char('\t') % "indentation";

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
      if (!extensions.inlineCodeAttributes) {
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

  Parser get endUnderscore => extensions.intrawordUnderscores
  ? char('_').notFollowedBy(alphanum)
  : char('_');

  Parser get startUnderscore => extensions.intrawordUnderscores
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

  Parser get strikeout => extensions.strikeout
  ? inlinesBetween(string('~~').notFollowedBy(char('~')) > noneOf('\t\n \r').lookAhead, string('~~')) ^ (i) => new Strikeout(i)
  : fail;

  // Subscript

  Parser get subscript => extensions.subscript
  ? new Parser((s, pos) {
    return (char('~') > many1Till(spaceChar.notAhead > inline, char('~')) ^ (i) => new Subscript(i)).run(s, pos);
  })
  : fail;

  Parser get superscript => extensions.superscript
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
          if (extensions.escapedLineBreaks) {
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
      } else if (inline is! Space || prev is! Space) {
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

  // Fenced code block

  static Parser blockDelimiter(String c, [int len]) {
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
    if (extensions.fencedCodeBlocks) {
      var testRes = char('~').lookAhead.run(s, pos);
      if (testRes.isSuccess) {
        c = '~';
      }
    }
    if (c == null && extensions.backtickCodeBlocks) {
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
    ParseResult attrRes = (spaceChar.skipMany > ((guardEnabled(extensions.fencedCodeAttributes) > attributes) |
    (nonSpaceChar.many1 ^ (str) => B.attr("", [toLanguageId(str.join(''))], {
    })))).orElse(B.nullAttr).run(s, startRes.position);
    assert(attrRes.isSuccess);
    var attr = attrRes.value;
    return (((blankline > anyLine.manyUntil(blockDelimiter(c, size))) < blanklines) ^
        (lines) => B.codeBlock(lines.join('\n'), attr)).run(s, attrRes.position);
  });


  // Header

  Parser get header => setextHeader | atxHeader % "header";

  Parser get atxHeader => new Parser((s, pos) {
    Parser startParser = char('#').many1;
    if (extensions.fancyLists) {
      startParser = startParser.notFollowedBy(oneOf(".)"));
    }
    ParseResult startRes = startParser.run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    int level = startRes.value.length;
    ParseResult textRes = (atxClosing.notAhead > inline).many.run(s, startRes.position);
    assert(textRes.isSuccess);
    var text = trimInlines(groupInlines(textRes.value));
    ParseResult attrRes = atxClosing.run(s, textRes.position);
    assert(attrRes.isSuccess);
    var attr = attrRes.value;
    // attr' <- registerHeader attr (runF text defaultParserState)
    return attrRes.copy(value: new Header(level, attr, text));
  });

  Parser get atxClosing => new Parser((s, pos) {
    Attr attr = B.nullAttr;
    ParseResult res;
    Position start = pos;
    if (extensions.mmdHeaderIdentifiers) {
      res = mmdHeaderIdentifier.run(s, pos);
      if (res.isSuccess) {
        attr = res.value;
        start = res.position;
      }
    }
    res = (char('#').skipMany > skipSpaces).run(s, start);
    assert(res.isSuccess);
    if (extensions.headerAttributes) {
      res = attributes.run(s, res.position);
      if (res.isSuccess) {
        attr = res.value;
      }
    }
    res = blanklines.run(s, res.position);
    if (!res.isSuccess) {
      return res.copy(position: pos);
    }
    return res.copy(value: attr);
  });

  Parser get mmdHeaderIdentifier => (reference < skipSpaces) ^ (v) => new Attr(v[1], [], {});

  static const String setextHChars = "=-";

  Parser get setextHeader => new Parser((s, pos) {
    // Lookahead test
    ParseResult testRes = ((anyLine > oneOf(setextHChars).many1) > blankline).lookAhead.run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }

    ParseResult textRes = (setextHeaderEnd.notAhead > inline).many1.run(s, pos);
    if (!textRes.isSuccess) {
      return textRes;
    }
    var text = trimInlines(groupInlines(textRes.value));

    var attrRes = setextHeaderEnd.run(s, textRes.position);
    if (!attrRes.isSuccess) {
      return attrRes;
    }
    var attr = attrRes.value;

    var levelRes = (oneOf(setextHChars).many1 ^ (v) => v[0] == '=' ? 1 : 2).run(s, attrRes.position);
    if (!levelRes.isSuccess) {
      return levelRes;
    }
    int level = levelRes.value;

    //   attr' <- registerHeader attr (runF text defaultParserState)
    return (blanklines ^ (_) => new Header(level, attr, text)).run(s, levelRes.position);
  });

  Parser get setextHeaderEnd => new Parser((s, pos) {
    Attr attr = B.nullAttr;
    ParseResult res;
    Position start = pos;
    if (extensions.mmdHeaderIdentifiers) {
      res = mmdHeaderIdentifier.run(s, start);
      if (res.isSuccess) {
        attr = res.value;
        start = res.position;
      }
    }
    if (extensions.headerAttributes) {
      res = attributes.run(s, start);
      if (res.isSuccess) {
        attr = res.value;
        start = res.position;
      }
    }
    res = blankline.run(s, start);
    if (res.isSuccess) {
      return res.copy(value: attr);
    } else {
      return res.copy(position: pos);
    }
  });

  // Indented code blocks

  Parser get indentedLine => (indentSpaces > anyLine) ^ (line) => line + "\n";

  Parser get codeBlockIndented =>
    ((indentedLine | (blanklines + indentedLine) ^ (b, l) => b.join('') + l).many1 < blanklines.maybe) ^ (c) =>
      B.codeBlock(stripTrailingNewlines(c.join('')), B.attr("", options.indentedCodeClasses, {}));

  // Hrule

  static const String hruleChars = '*-_';

  static Parser get hrule => new Parser((s, pos) {
    ParseResult startRes = (skipSpaces > oneOf(hruleChars)).run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    var start = startRes.value;

    return ((((count(2, skipSpaces > char(start)) > (spaceChar | char(start)).skipMany) > newline) > blanklines.maybe) >
      success(new HorizontalRule())).run(s, startRes.position);
  });

  // Lists

  Parser get bulletList => listItem(bulletListStart).many1 ^ (items) => new BulletList(items);
  /*
  bulletList :: MarkdownParser (F Blocks)
bulletList = do
  items <- fmap sequence $ many1 $ listItem  bulletListStart
  return $ B.bulletList <$> fmap compactify' items
   */

  Parser listItem(Parser start) => new Parser((s, pos) {
    ParseResult firstRes = rawListItem(start).run(s, pos);
    if (!firstRes.isSuccess) {
      return firstRes;
    }
    var first = firstRes.value;

    ParseResult<List<String>> continuationsRes = listContinuation.many.run(s, firstRes.position);

    // TODO context

    String raw = first + continuationsRes.value.join("");

    print(raw);

    List<Block> blocks = block.many1.parse(raw);

    return continuationsRes.copy(value: blocks);
  });

  /*
  listItem :: MarkdownParser a
         -> MarkdownParser (F Blocks)
listItem start = try $ do
  first <- rawListItem start
  continuations <- many listContinuation
  -- parsing with ListItemState forces markers at beginning of lines to
  -- count as list item markers, even if not separated by blank space.
  -- see definition of "endline"
  state <- getState
  let oldContext = stateParserContext state
  setState $ state {stateParserContext = ListItemState}
  -- parse the extracted block, which may contain various block elements:
  let raw = concat (first:continuations)
  contents <- parseFromString parseBlocks raw
  updateState (\st -> st {stateParserContext = oldContext})
  return contents

   */

  /**
   * parse raw text for one list item, excluding start marker and continuations
   */
  Parser rawListItem(Parser start) =>
    ((start > listLineCommon) + ((listStart | blankline).notAhead > listLine).many + blankline.many) ^
      (first, rest, blanks) => first + rest.join('') + blanks.join(''); // TODO

  /*
rawListItem :: MarkdownParser a
            -> MarkdownParser String
rawListItem start = try $ do
  start
  first <- listLineCommon
  rest <- many (notFollowedBy listStart >> notFollowedBy blankline >> listLine)
  blanks <- many blankline
  return $ unlines (first:rest) ++ blanks
   */

  // TODO support for html comments
  static Parser listLineCommon = anyLine ^ (l) => l + '\n';

  /*
  listLineCommon :: MarkdownParser String
listLineCommon = concat <$> manyTill
              (  many1 (satisfy $ \c -> c /= '\n' && c /= '<')
             <|> liftM snd (htmlTag isCommentTag)
             <|> count 1 anyChar
              ) newline
   */

  Parser get listStart => bulletListStart; /*| anyOrderedListStart */
  /*
  listStart :: MarkdownParser ()
listStart = bulletListStart <|> (anyOrderedListStart >> return ())

   */

  Parser get bulletListStart => new Parser((s, pos) {
    var startPosParser = (newline.maybe > position) ^
        (Position pos) => pos.character;
    var startPosRes = startPosParser.run(s, pos);
    if (!startPosRes.isSuccess) {
      return startPosRes;
    }
    int startPos = startPosRes.value;

    var endPosParser = ((skipNonindentSpaces.notFollowedBy(hrule) > bulletListMarker) > position) ^
        (Position pos) => pos.character;
    var endPosRes = endPosParser.run(s, startPosRes.position);
    if (!endPosRes.isSuccess) {
      return endPosRes;
    }
    int endPos = endPosRes.value;

    var restParser = ((newline | spaceChar).lookAhead > atMostSpaces(options.tabStop - (endPos - startPos))) ^ (_) => null;
    return restParser.run(s, endPosRes.position);
  });

  static Parser bulletListMarker = oneOf('-+*');

  /*
bulletListStart :: MarkdownParser ()
bulletListStart = try $ do
  optional newline -- if preceded by a Plain block in a list context
  startpos <- sourceColumn <$> getPosition
  skipNonindentSpaces
  notFollowedBy' (() <$ hrule)     -- because hrules start out just like lists
  satisfy isBulletListMarker
  endpos <- sourceColumn <$> getPosition
  tabStop <- getOption readerTabStop
  lookAhead (newline <|> spaceChar)
  () <$ atMostSpaces (tabStop - (endpos - startpos))
   */

  Parser get listLine => (((indentSpaces > spaceChar.many) > listStart).notAhead > indentSpaces.maybe) > listLineCommon;

  /*
  listLine :: MarkdownParser String
listLine = try $ do
  notFollowedBy' (do indentSpaces
                     many spaceChar
                     listStart)
  notFollowedByHtmlCloser
  optional (() <$ indentSpaces)
  listLineCommon
   */

  /**
   * continuation of a list item - indented and separated by blankline
   * or (in compact lists) endline.
   * note: nested lists are parsed as continuations
   */

  Parser get listContinuation => ((indentSpaces.lookAhead > listContinuationLine.many1) + blankline.many) ^
    (result, blanks) => (result..addAll(blanks)).join('');

  /*
-- continuation of a list item - indented and separated by blankline
-- or (in compact lists) endline.
-- note: nested lists are parsed as continuations
listContinuation :: MarkdownParser String
listContinuation = try $ do
  lookAhead indentSpaces
  result <- many1 listContinuationLine
  blanks <- many blankline
  return $ concat result ++ blanks
`   */
  Parser get listContinuationLine => (((blankline | listStart).notAhead > indentSpaces.maybe) > anyLine) ^
      (str) => str + '\n';
  /*
  listContinuationLine :: MarkdownParser String
listContinuationLine = try $ do
  notFollowedBy blankline
  notFollowedBy' listStart
  notFollowedByHtmlCloser
  optional indentSpaces
  result <- anyLine
  return $ result ++ "\n"

   */
  //
  // Block parsers
  //

  Parser get block => choice([
      blanklines ^ (_) => null,
      codeBlockFenced,
      // yamlMetaBlock,
      // guardEnabled Ext_latex_macros *> (macro >>= return . return)
      bulletList,
      header,
      // lhsCodeBlock
      // rawTeXBlock
      // divHtml
      // htmlBlock
      // table
      // lineBlock
      codeBlockIndented,
      // blockQuote
      hrule,
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

  static MarkdownParser PANDOC = new MarkdownParser(MarkdownParserExtensions.PANDOC);
  static MarkdownParser PHPEXTRA = new MarkdownParser(MarkdownParserExtensions.PHPEXTRA);
  static MarkdownParser GITHUB = new MarkdownParser(MarkdownParserExtensions.GITHUB);
  static MarkdownParser MMD = new MarkdownParser(MarkdownParserExtensions.MMD);
  static MarkdownParser STRICT = new MarkdownParser(MarkdownParserExtensions.STRICT);

  static MarkdownParser DEFAULT = new MarkdownParser();
}
