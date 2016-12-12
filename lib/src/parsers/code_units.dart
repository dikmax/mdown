part of md_proc.src.parsers;

/// Code unit for `\t`.
const int _tabCodeUnit = 9;

/// Code unit for `\r`.
const int _newLineCodeUnit = 10;

/// Code unit for `\v`.
const int _verticalTabCodeUnit = 11;

/// Code unit for `\f`.
const int _formFeedCodeUnit = 12;

/// Code unit for `\n`.
const int _carriageReturnCodeUnit = 13;

/// Code unit for ` `.
const int _spaceCodeUnit = 32;

/// Code unit for `!`.
const int _exclamationMarkCodeUnit = 33;

/// Code unit for `"`.
const int _doubleQuoteCodeUnit = 34;

/// Code unit for `#`.
const int _sharpCodeUnit = 35;

/// Code unit for `$`.
const int _dollarCodeUnit = 36;

/// Code unit for `%`.
const int _percentCodeUnit = 37;

/// Code unit for `&`.
const int _ampersandCodeUnit = 38;

/// Code unit for `'`.
const int _singleQuoteCodeUnit = 39;

/// Code unit for `(`.
const int _openParenCodeUnit = 40;

/// Code unit for `)`.
const int _closeParenCodeUnit = 41;

/// Code unit for `*`.
const int _starCodeUnit = 42;

/// Code unit for `+`.
const int _plusCodeUnit = 43;

/// Code unit for `,`.
const int _commaCodeUnit = 44;

/// Code unit for `-`.
const int _minusCodeUnit = 45;

/// Code unit for `.`.
const int _dotCodeUnit = 46;

/// Code unit for `/`.
const int _slashCodeUnit = 47;

/// Code unit for `0`.
const int _zeroCodeUnit = 48;

/// Code unit for `9`.
const int _nineCodeUnit = 57;

/// Code unit for `:`.
const int _colonCodeUnit = 58;

/// Code unit for `;`.
const int _semicolonCodeUnit = 59;

/// Code unit for `<`.
const int _lessThanCodeUnit = 60;

/// Code unit for `=`.
const int _equalCodeUnit = 61;

/// Code unit for `>`.
const int _greaterThanCodeUnit = 62;

/// Code unit for `?`.
const int _questionMarkCodeUnit = 63;

/// Code unit for `@`.
const int _atSignCodeUnit = 64;

/// Code unit for `[`.
const int _openBracketCodeUnit = 91;

/// Code unit for `\`.
const int _backslashCodeUnit = 92;

/// Code unit for `]`.
const int _closeBracketCodeUnit = 93;

/// Code unit for `^`.
const int _caretCodeUnit = 94;

/// Code unit for `_`.
const int _underscoreCodeUnit = 95;

/// Code unit for `` ` ``.
const int _backtickCodeUnit = 96;

/// Code unit for `{`.
const int _openBraceCodeUnit = 123;

/// Code unit for `|`.
const int _verticalBarCodeUnit = 124;

/// Code unit for `}`.
const int _closeBraceCodeUnit = 125;

/// Code unit for `~`.
const int _tildeCodeUnit = 126;

/// Code unit for `&nbsp;`.
const int _nonBreakableSpaceCodeUnit = 160;

/// Unicode space chars.
final Set<int> _spaces = new Set<int>.from(<int>[
  _formFeedCodeUnit,
  _spaceCodeUnit,
  _newLineCodeUnit,
  _carriageReturnCodeUnit,
  _tabCodeUnit,
  _verticalTabCodeUnit,
  _nonBreakableSpaceCodeUnit,
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
Set<int> get _punctuation {
  if (_punctuationSet == null) {
    _punctuationSet = new Set<int>.from(<int>[
      _backslashCodeUnit,
      _singleQuoteCodeUnit,
      _exclamationMarkCodeUnit,
      _doubleQuoteCodeUnit,
      _sharpCodeUnit,
      _dollarCodeUnit,
      _percentCodeUnit,
      _ampersandCodeUnit,
      _openParenCodeUnit,
      _closeParenCodeUnit,
      _starCodeUnit,
      _plusCodeUnit,
      _commaCodeUnit,
      _minusCodeUnit,
      _dotCodeUnit,
      _slashCodeUnit,
      _colonCodeUnit,
      _semicolonCodeUnit,
      _lessThanCodeUnit,
      _equalCodeUnit,
      _greaterThanCodeUnit,
      _questionMarkCodeUnit,
      _atSignCodeUnit,
      _openBracketCodeUnit,
      _closeBracketCodeUnit,
      _caretCodeUnit,
      _underscoreCodeUnit,
      _backtickCodeUnit,
      _openBraceCodeUnit,
      _verticalBarCodeUnit,
      _closeBraceCodeUnit,
      _tildeCodeUnit
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
