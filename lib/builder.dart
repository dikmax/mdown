library markdownBuilder;

import 'markdown.dart';

Iterable _buildList(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z) {
  List args = [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z];
  List result = [];
  for (var arg in args) {
    if (arg == null) {
      return result;
    }
    result.add(arg);
  }

  return result;
}

final Attr nullAttr = new Attr("", [], {});
Attr attr(id, classes, attributes) => new Attr(id, classes, attributes);

Document doc([Block a, Block b, Block c, Block d, Block e, Block f, Block g, Block h, Block i, Block j, Block k,
             Block l, Block m, Block n, Block o, Block p, Block q, Block r, Block s, Block t, Block u, Block v,
             Block w, Block x, Block y, Block z]) {
  return new Document(_buildList(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z));
}


/*
text :: String -> Inlines
text = fromList . map conv . breakBySpaces
  where breakBySpaces = groupBy sameCategory
        sameCategory x y = (is_space x && is_space y) ||
                           (not $ is_space x || is_space y)
        conv xs | all is_space xs = Space
        conv xs = Str xs
        is_space ' '  = True
        is_space '\n' = True
        is_space '\t' = True
        is_space _    = False
*/

Str str(String string) {
  return new Str(string);
}

Emph emph([Inline a, Inline b, Inline c, Inline d, Inline e, Inline f, Inline g, Inline h, Inline i, Inline j, Inline k,
          Inline l, Inline m, Inline n, Inline o, Inline p, Inline q, Inline r, Inline s, Inline t, Inline u, Inline v,
          Inline w, Inline x, Inline y, Inline z]) {
  return new Emph(_buildList(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z));
}

Strong strong([Inline a, Inline b, Inline c, Inline d, Inline e, Inline f, Inline g, Inline h, Inline i, Inline j,
              Inline k, Inline l, Inline m, Inline n, Inline o, Inline p, Inline q, Inline r, Inline s, Inline t,
              Inline u, Inline v, Inline w, Inline x, Inline y, Inline z]) {
  return new Strong(_buildList(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z));
}

Strikeout strikeout([Inline a, Inline b, Inline c, Inline d, Inline e, Inline f, Inline g, Inline h, Inline i, Inline j,
                    Inline k, Inline l, Inline m, Inline n, Inline o, Inline p, Inline q, Inline r, Inline s, Inline t,
                    Inline u, Inline v, Inline w, Inline x, Inline y, Inline z]) {
  return new Strikeout(_buildList(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z));
}

Superscript superscript([Inline a, Inline b, Inline c, Inline d, Inline e, Inline f, Inline g, Inline h, Inline i,
                        Inline j, Inline k, Inline l, Inline m, Inline n, Inline o, Inline p, Inline q, Inline r,
                        Inline s, Inline t, Inline u, Inline v, Inline w, Inline x, Inline y, Inline z]) {
  return new Superscript(_buildList(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z));
}

Subscript subscript([Inline a, Inline b, Inline c, Inline d, Inline e, Inline f, Inline g, Inline h, Inline i, Inline j,
                    Inline k, Inline l, Inline m, Inline n, Inline o, Inline p, Inline q, Inline r, Inline s, Inline t,
                    Inline u, Inline v, Inline w, Inline x, Inline y, Inline z]) {
  return new Subscript(_buildList(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z));
}

/*

smallcaps :: Inlines -> Inlines
smallcaps = singleton . SmallCaps . toList

singleQuoted :: Inlines -> Inlines
singleQuoted = quoted SingleQuote

doubleQuoted :: Inlines -> Inlines
doubleQuoted = quoted DoubleQuote

quoted :: QuoteType -> Inlines -> Inlines
quoted qt = singleton . Quoted qt . toList

cite :: [Citation] -> Inlines -> Inlines
cite cts = singleton . Cite cts . toList

-- | Inline code with attributes.
codeWith :: Attr -> String -> Inlines
codeWith attrs = singleton . Code attrs

-- | Plain inline code.
code :: String -> Inlines
code = codeWith nullAttr

*/

Code code(String code, [Attr attr]) => new Code(attr == null ? nullAttr : attr, code);

final Space space = new Space();

final NonBreakableSpace nbsp = new NonBreakableSpace();

final LineBreak linebreak = new LineBreak();

/*
-- | Inline math
math :: String -> Inlines
math = singleton . Math InlineMath

-- | Display math
displayMath :: String -> Inlines
displayMath = singleton . Math DisplayMath

rawInline :: String -> String -> Inlines
rawInline format = singleton . RawInline (Format format)
*/

Target target(String url, String title) => new Target(url, title);

Link link(Target tt, [Inline a, Inline b, Inline c, Inline d, Inline e, Inline f, Inline g, Inline h,
          Inline i, Inline j, Inline k, Inline l, Inline m, Inline n, Inline o, Inline p, Inline q, Inline r, Inline s,
          Inline t, Inline u, Inline v, Inline w, Inline x, Inline y, Inline z]) {
  return new Link(_buildList(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z),
    tt);
}

Image image(Target tt, [Inline a, Inline b, Inline c, Inline d, Inline e, Inline f, Inline g, Inline h,
          Inline i, Inline j, Inline k, Inline l, Inline m, Inline n, Inline o, Inline p, Inline q, Inline r, Inline s,
          Inline t, Inline u, Inline v, Inline w, Inline x, Inline y, Inline z]) {
  return new Image(_buildList(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z),
    tt);
}

/*

note :: Blocks -> Inlines
note = singleton . Note . toList

spanWith :: Attr -> Inlines -> Inlines
spanWith attr = singleton . Span attr . toList

-- Block list builders

*/

Para para([Inline a, Inline b, Inline c, Inline d, Inline e, Inline f, Inline g, Inline h, Inline i, Inline j, Inline k,
          Inline l, Inline m, Inline n, Inline o, Inline p, Inline q, Inline r, Inline s, Inline t, Inline u, Inline v,
          Inline w, Inline x, Inline y, Inline z]) {
  return new Para(_buildList(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z));
}

/*

plain :: Inlines -> Blocks
plain ils = if isNull ils
               then mempty
               else singleton . Plain . toList $ ils

*/

CodeBlock codeBlock(String code, [Attr attr]) {
  return new CodeBlock(attr == null ? nullAttr : attr, code);
}

/*
rawBlock :: String -> String -> Blocks
rawBlock format = singleton . RawBlock (Format format)

blockQuote :: Blocks -> Blocks
blockQuote = singleton . BlockQuote . toList

-- | Ordered list with attributes.
orderedListWith :: ListAttributes -> [Blocks] -> Blocks
orderedListWith attrs = singleton . OrderedList attrs .  map toList

-- | Ordered list with default attributes.
orderedList :: [Blocks] -> Blocks
orderedList = orderedListWith (1, DefaultStyle, DefaultDelim)

bulletList :: [Blocks] -> Blocks
bulletList = singleton . BulletList . map toList

definitionList :: [(Inlines, [Blocks])] -> Blocks
definitionList = singleton . DefinitionList .  map (toList *** map toList)

header :: Int  -- ^ Level
       -> Inlines
       -> Blocks
header = headerWith nullAttr

headerWith :: Attr -> Int -> Inlines -> Blocks
headerWith attr level = singleton . Header level attr . toList

horizontalRule :: Blocks
horizontalRule = singleton HorizontalRule

table :: Inlines               -- ^ Caption
      -> [(Alignment, Double)] -- ^ Column alignments and fractional widths
      -> [Blocks]              -- ^ Headers
      -> [[Blocks]]            -- ^ Rows
      -> Blocks
table caption cellspecs headers rows = singleton $
  Table (toList caption) aligns widths
      (map toList headers) (map (map toList) rows)
   where (aligns, widths) = unzip cellspecs

-- | A simple table without a caption.
simpleTable :: [Blocks]   -- ^ Headers
            -> [[Blocks]] -- ^ Rows
            -> Blocks
simpleTable headers = table mempty (mapConst defaults headers) headers
  where defaults = (AlignDefault, 0)

divWith :: Attr -> Blocks -> Blocks
divWith attr = singleton . Div attr . toList

mapConst :: Functor f => b -> f a -> f b
mapConst = fmap . const


 */