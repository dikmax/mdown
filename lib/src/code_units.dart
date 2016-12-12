library md_proc.src.code_units;

/// Code unit for `\t`.
const int tabCodeUnit = 9;

/// Code unit for `\r`.
const int newLineCodeUnit = 10;

/// Code unit for `\v`.
const int verticalTabCodeUnit = 11;

/// Code unit for `\f`.
const int formFeedCodeUnit = 12;

/// Code unit for `\n`.
const int carriageReturnCodeUnit = 13;

/// Code unit for ` `.
const int spaceCodeUnit = 32;

/// Code unit for `!`.
const int exclamationMarkCodeUnit = 33;

/// Code unit for `"`.
const int doubleQuoteCodeUnit = 34;

/// Code unit for `#`.
const int sharpCodeUnit = 35;

/// Code unit for `$`.
const int dollarCodeUnit = 36;

/// Code unit for `%`.
const int percentCodeUnit = 37;

/// Code unit for `&`.
const int ampersandCodeUnit = 38;

/// Code unit for `'`.
const int singleQuoteCodeUnit = 39;

/// Code unit for `(`.
const int openParenCodeUnit = 40;

/// Code unit for `)`.
const int closeParenCodeUnit = 41;

/// Code unit for `*`.
const int starCodeUnit = 42;

/// Code unit for `+`.
const int plusCodeUnit = 43;

/// Code unit for `,`.
const int commaCodeUnit = 44;

/// Code unit for `-`.
const int minusCodeUnit = 45;

/// Code unit for `.`.
const int dotCodeUnit = 46;

/// Code unit for `/`.
const int slashCodeUnit = 47;

/// Code unit for `0`.
const int zeroCodeUnit = 48;

/// Code unit for `9`.
const int nineCodeUnit = 57;

/// Code unit for `:`.
const int colonCodeUnit = 58;

/// Code unit for `;`.
const int semicolonCodeUnit = 59;

/// Code unit for `<`.
const int lessThanCodeUnit = 60;

/// Code unit for `=`.
const int equalCodeUnit = 61;

/// Code unit for `>`.
const int greaterThanCodeUnit = 62;

/// Code unit for `?`.
const int questionMarkCodeUnit = 63;

/// Code unit for `@`.
const int atSignCodeUnit = 64;

/// Code unit for `[`.
const int openBracketCodeUnit = 91;

/// Code unit for `\`.
const int backslashCodeUnit = 92;

/// Code unit for `]`.
const int closeBracketCodeUnit = 93;

/// Code unit for `^`.
const int caretCodeUnit = 94;

/// Code unit for `_`.
const int underscoreCodeUnit = 95;

/// Code unit for `` ` ``.
const int backtickCodeUnit = 96;

/// Code unit for `{`.
const int openBraceCodeUnit = 123;

/// Code unit for `|`.
const int verticalBarCodeUnit = 124;

/// Code unit for `}`.
const int closeBraceCodeUnit = 125;

/// Code unit for `~`.
const int tildeCodeUnit = 126;

/// Code unit for `&nbsp;`.
const int nonBreakableSpaceCodeUnit = 160;

/// Unicode space chars.
final Set<int> spaces = new Set<int>.from(<int>[
  formFeedCodeUnit,
  spaceCodeUnit,
  newLineCodeUnit,
  carriageReturnCodeUnit,
  tabCodeUnit,
  verticalTabCodeUnit,
  nonBreakableSpaceCodeUnit,
  0x1680,
  0x180e,
  0x2000,
  0x2001,
  0x2002,
  0x2003,
  0x2004,
  0x2005,
  0x2006,
  0x2007,
  0x2008,
  0x2009,
  0x200a,
  0x2028,
  0x2029,
  0x202f,
  0x205f,
  0x3000,
  0xfeff,
]);

Set<int> _punctuationSet;

/// Unicode puctuation chars.
Set<int> get punctuation {
  if (_punctuationSet == null) {
    _punctuationSet = new Set<int>.from(<int>[
      backslashCodeUnit,
      singleQuoteCodeUnit,
      exclamationMarkCodeUnit,
      doubleQuoteCodeUnit,
      sharpCodeUnit,
      dollarCodeUnit,
      percentCodeUnit,
      ampersandCodeUnit,
      openParenCodeUnit,
      closeParenCodeUnit,
      starCodeUnit,
      plusCodeUnit,
      commaCodeUnit,
      minusCodeUnit,
      dotCodeUnit,
      slashCodeUnit,
      colonCodeUnit,
      semicolonCodeUnit,
      lessThanCodeUnit,
      equalCodeUnit,
      greaterThanCodeUnit,
      questionMarkCodeUnit,
      atSignCodeUnit,
      openBracketCodeUnit,
      closeBracketCodeUnit,
      caretCodeUnit,
      underscoreCodeUnit,
      backtickCodeUnit,
      openBraceCodeUnit,
      verticalBarCodeUnit,
      closeBraceCodeUnit,
      tildeCodeUnit
    ]);
    _punctuationSet.addAll(new List<int>.generate(
        0x70, (int index) => 0x2000 + index,
        growable: false));
    _punctuationSet.addAll(new List<int>.generate(
        0x80, (int index) => 0x2e00 + index,
        growable: false));
  }

  return _punctuationSet;
}
