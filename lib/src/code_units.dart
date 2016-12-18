library mdown.src.code_units;

import 'package:mdown/src/bit_set.dart';

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

/// Character 'A'.
const int bigACharCode = 65;

/// Character 'B'.
const int bigBCharCode = 66;

/// Character 'C'.
const int bigCCharCode = 67;

/// Character 'D'.
const int bigDCharCode = 68;

/// Character 'E'.
const int bigECharCode = 69;

/// Character 'F'.
const int bigFCharCode = 70;

/// Character 'G'.
const int bigGCharCode = 71;

/// Character 'H'.
const int bigHCharCode = 72;

/// Character 'I'.
const int bigICharCode = 73;

/// Character 'L'.
const int bigLCharCode = 76;

/// Character 'M'.
const int bigMCharCode = 77;

/// Character 'N'.
const int bigNCharCode = 78;

/// Character 'O'.
const int bigOCharCode = 79;

/// Character 'P'.
const int bigPCharCode = 80;

/// Character 'Q'.
const int bigQCharCode = 81;

/// Character 'R'.
const int bigRCharCode = 82;

/// Character 'S'.
const int bigSCharCode = 83;

/// Character 'T'.
const int bigTCharCode = 84;

/// Character 'U'.
const int bigUCharCode = 85;

/// Character 'Y'.
const int bigYCharCode = 89;

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

/// Character 'a'.
const int smallACharCode = 97;

/// Character 'b'.
const int smallBCharCode = 98;

/// Character 'c'.
const int smallCCharCode = 99;

/// Character 'd'.
const int smallDCharCode = 100;

/// Character 'e'.
const int smallECharCode = 101;

/// Character 'f'.
const int smallFCharCode = 102;

/// Character 'g'.
const int smallGCharCode = 103;

/// Character 'h'.
const int smallHCharCode = 104;

/// Character 'i'.
const int smallICharCode = 105;

/// Character 'l'.
const int smallLCharCode = 108;

/// Character 'm'.
const int smallMCharCode = 109;

/// Character 'n'.
const int smallNCharCode = 110;

/// Character 'o'.
const int smallOCharCode = 111;

/// Character 'p'.
const int smallPCharCode = 112;

/// Character 'q'.
const int smallQCharCode = 113;

/// Character 'r'.
const int smallRCharCode = 114;

/// Character 's'.
const int smallSCharCode = 115;

/// Character 't'.
const int smallTCharCode = 116;

/// Character 'u'.
const int smallUCharCode = 117;

/// Character 'y'.
const int smallYCharCode = 121;

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

Set<int> _spacesSet;

/// Unicode space chars.
Set<int> get spaces {
  if (_spacesSet == null) {
    _spacesSet = new BitSet(65536);
    _spacesSet.addAll(<int>[
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
  }

  return _spacesSet;
}

Set<int> _punctuationSet;

/// Unicode puctuation chars.
Set<int> get punctuation {
  if (_punctuationSet == null) {
    _punctuationSet = new BitSet(0x3000);
    _punctuationSet.addAll(<int>[
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
