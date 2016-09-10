part of md_proc.src.parsers;

const int _tabCodeUnit = 9;
const int _newLineCodeUnit = 10;
const int _verticalTabCodeUnit = 11;
const int _formFeedCodeUnit = 12;
const int _carriageReturnCodeUnit = 13;
const int _spaceCodeUnit = 32;
const int _exclamationMarkCodeUnit = 33;
const int _doubleQuoteCodeUnit = 34;
const int _sharpCodeUnit = 35;
const int _dollarCodeUnit = 36;
const int _percentCodeUnit = 37;
const int _ampersandCodeUnit = 38;
const int _singleQuoteCodeUnit = 39;
const int _openParenCodeUnit = 40;
const int _closeParenCodeUnit = 41;
const int _starCodeUnit = 42;
const int _plusCodeUnit = 43;
const int _commaCodeUnit = 44;
const int _minusCodeUnit = 45;
const int _dotCodeUnit = 46;
const int _slashCodeUnit = 47;
const int _zeroCodeUnit = 48;
const int _nineCodeUnit = 57;
const int _colonCodeUnit = 58;
const int _semicolonCodeUnit = 59;
const int _lessThanCodeUnit = 60;
const int _equalCodeUnit = 61;
const int _greaterThanCodeUnit = 62;
const int _questionMarkCodeUnit = 63;
const int _atSignCodeUnit = 64;
const int _openBracketCodeUnit = 91;
const int _backslashCodeUnit = 92;
const int _closeBracketCodeUnit = 93;
const int _caretCodeUnit = 94;
const int _underscoreCodeUnit = 95;
const int _backtickCodeUnit = 96;
const int _openBraceCodeUnit = 123;
const int _verticalBarCodeUnit = 124;
const int _closeBraceCodeUnit = 125;
const int _tildeCodeUnit = 126;
const int _nonBreakableSpaceCodeUnit = 160;

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

Set<int> get _punctuation {
  if (_punctuationSet == null) {
    _punctuationSet = new Set<int>.from(
        <int>[
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
        ]
    );
    _punctuationSet.addAll(new List<int>.generate(0x70,
        (int index) => 0x2000 + index, growable: false));
    _punctuationSet.addAll(new List<int>.generate(0x80,
        (int index) => 0x2e00 + index, growable: false));
  }

  return _punctuationSet;
}
