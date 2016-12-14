library md_proc.src.parsers.inline_structure;

import 'dart:collection';
import 'dart:math';
import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/bit_set.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/inlines.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/container.dart';

class _Delim {
  final int charCode;
  int count;
  final bool canOpen;
  final bool canClose;

  // Used for unmatched single quote
  bool matched = false;

  /// Required for subscript and superscript as they cannot contain space.
  bool containsSpace = false;
  Inlines inlines = new Inlines();

  _Delim(this.charCode, this.count, this.canOpen, this.canClose);

  int countCloses(_Delim delim) {
    if (charCode != delim.charCode) {
      return 0;
    }
    // ignore: undefined_identifier
    if (charCode == singleQuoteCodeUnit || charCode == doubleQuoteCodeUnit) {
      return 1; // Always closes.
    }
    if ((canClose || delim.canOpen) && (count + delim.count) % 3 == 0) {
      return 0;
    }

    return min(count, delim.count);
  }
}

/// Space inline
class _EscapedSpace extends Inline {
  static final _EscapedSpace _instance = new _EscapedSpace._internal();

  /// Constructor
  factory _EscapedSpace() {
    return _instance;
  }

  _EscapedSpace._internal();

  @override
  String toString() => "_EscapedSpace";

  @override
  bool operator ==(dynamic obj) => obj is _EscapedSpace;

  @override
  int get hashCode => 0;
}

/// Tab inline
class _EscapedTab extends Inline {
  static final _EscapedTab _instance = new _EscapedTab._internal();

  /// Constructor
  factory _EscapedTab() {
    return _instance;
  }

  _EscapedTab._internal();

  @override
  String toString() => "_EscapedTab";

  @override
  bool operator ==(dynamic obj) => obj is _EscapedTab;

  @override
  int get hashCode => 0;
}

/// Parsing emphasis, strongs, smartquotes, etc.
class InlineStructureParser extends AbstractParser<Inlines> {
  Set<int> _delimitersChars;

  Set<int> _intrawordDelimetersChars;

  Map<int, List<AbstractParser<Iterable<Inline>>>> _inlineParsers;

  /// Constructor.
  InlineStructureParser(ParsersContainer container) : super(container) {
    this._delimitersChars = new BitSet(256);
    this._delimitersChars.addAll(<int>[starCodeUnit, underscoreCodeUnit]);

    this._intrawordDelimetersChars = new BitSet(256);
    this._intrawordDelimetersChars.add(starCodeUnit);

    if (container.options.smartPunctuation) {
      _delimitersChars..add(singleQuoteCodeUnit)..add(doubleQuoteCodeUnit);
    }

    if (container.options.strikeout) {
      _delimitersChars.add(tildeCodeUnit);
    }

    if (container.options.subscript) {
      _delimitersChars.add(tildeCodeUnit);
      _intrawordDelimetersChars.add(tildeCodeUnit);
    }

    if (container.options.superscript) {
      _delimitersChars.add(caretCodeUnit);
      _intrawordDelimetersChars.add(caretCodeUnit);
    }
  }

  @override
  void init() {
    _inlineParsers = new HashMap<int, List<AbstractParser<Iterable<Inline>>>>();

    _inlineParsers[spaceCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[tabCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[backslashCodeUnit] = <AbstractParser<Iterable<Inline>>>[];
    if (container.options.texMathSingleBackslash) {
      _inlineParsers[backslashCodeUnit]
          .add(container.texMathSingleBackslashParser);
    }
    if (container.options.texMathDoubleBackslash) {
      _inlineParsers[backslashCodeUnit]
          .add(container.texMathDoubleBackslashParser);
    }
    _inlineParsers[backslashCodeUnit].add(container.escapesParser);

    _inlineParsers[ampersandCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.entityParser
    ];

    _inlineParsers[backtickCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.inlineCodeParser
    ];

    _inlineParsers[openBracketCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.linkImageParser
    ];

    _inlineParsers[lessThanCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.autolinkParser
    ];

    if (container.options.rawHtml) {
      _inlineParsers[lessThanCodeUnit].add(container.inlineHtmlParser);
    }

    if (container.options.smartPunctuation) {
      _inlineParsers[dotCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.ellipsisParser
      ];

      _inlineParsers[minusCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.mnDashParser
      ];
    }

    if (container.options.texMathDollars) {
      _inlineParsers[dollarCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.texMathDollarsParser
      ];
    }
  }

  _Delim _scanDelims(String text, int offset) {
    final int charCode = text.codeUnitAt(offset);
    if (!_delimitersChars.contains(charCode)) {
      return null;
    }

    int endOffset = offset + 1;
    final int length = text.length;
    while (endOffset < length && text.codeUnitAt(endOffset) == charCode) {
      endOffset++;
    }

    final int count = endOffset - offset;

    if (count > 1 &&
        (charCode == tildeCodeUnit && !container.options.strikeout ||
            charCode == caretCodeUnit)) {
      // Subscript and superscript can only go alone.
      return new _Delim(charCode, count, false, false);
    }

    int codeUnitBefore = newLineCodeUnit;
    int i = 1;
    while (offset - i >= 0) {
      final int codeUnit = text.codeUnitAt(offset - i);
      if (!_intrawordDelimetersChars.contains(codeUnit)) {
        codeUnitBefore = codeUnit;
        break;
      }
      i++;
    }

    int codeUnitAfter = newLineCodeUnit;
    i = 0;
    while (endOffset + i < length) {
      final int codeUnit = text.codeUnitAt(endOffset + i);
      if (!_intrawordDelimetersChars.contains(codeUnit)) {
        codeUnitAfter = codeUnit;
        break;
      }
      i++;
    }

    final bool spaceAfter = spaces.contains(codeUnitAfter);
    final bool spaceBefore = spaces.contains(codeUnitBefore);
    final bool punctuationAfter = punctuation.contains(codeUnitAfter);
    final bool punctuationBefore = punctuation.contains(codeUnitBefore);

    final bool leftFlanking =
        !spaceAfter && (!punctuationAfter || spaceBefore || punctuationBefore);
    final bool rightFlanking =
        !spaceBefore && (!punctuationBefore || spaceAfter || punctuationAfter);

    bool canOpen = leftFlanking;
    bool canClose = rightFlanking;
    if (charCode == underscoreCodeUnit) {
      canOpen = canOpen && (!rightFlanking || punctuationBefore);
      canClose = canClose && (!leftFlanking || punctuationAfter);
    } else if (charCode == singleQuoteCodeUnit ||
        charCode == doubleQuoteCodeUnit) {
      canOpen = canOpen && !rightFlanking;
    }

    return new _Delim(charCode, count, canOpen, canClose);
  }

  Inlines _buildStack(List<_Delim> stack, int skip) {
    final Inlines result = new Inlines();
    final Iterable<_Delim> list = skip > 0 ? stack.skip(skip) : stack;
    for (_Delim delim in list) {
      if (delim.count > 0) {
        final int charCode = delim.charCode;
        if (charCode == singleQuoteCodeUnit) {
          result.addAll(new List<Inline>.filled(delim.count,
              delim.matched ? new SingleOpenQuote() : new Apostrophe()));
        } else if (charCode == doubleQuoteCodeUnit) {
          result.addAll(
              new List<Inline>.filled(delim.count, new DoubleOpenQuote()));
        } else {
          result.add(new Str(new String.fromCharCode(charCode) * delim.count));
        }
      }
      result.addAll(delim.inlines);
    }
    stack.length = skip;

    return result;
  }

  /// Replaces _EscapedSpace and _EscapedTab with correspondent inlines.
  Inlines unescapeSpaces(Iterable<Inline> items, bool success) {
    final Inlines result = new Inlines();
    for (Inline item in items) {
      if (item is _EscapedSpace) {
        if (!success) {
          result.add(new Str('\\'));
        }
        result.add(new Space());
      } else if (item is _EscapedTab) {
        if (!success) {
          result.add(new Str('\\'));
        }
        result.add(new Tab());
      } else {
        if (item is Strong) {
          item.contents = unescapeSpaces(item.contents, success);
        } else if (item is Emph) {
          item.contents = unescapeSpaces(item.contents, success);
        } else if (item is Strikeout) {
          item.contents = unescapeSpaces(item.contents, success);
        } else if (item is Link) {
          item.label = unescapeSpaces(item.label, success);
        } else if (item is Image) {
          item.label = unescapeSpaces(item.label, success);
        }
        result.add(item);
      }
    }
    return result;
  }

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    final _Delim delim = _scanDelims(text, offset);

    offset += delim.count;

    if (!delim.canOpen) {
      final int charCode = delim.charCode;
      List<Inline> result;
      if (charCode == singleQuoteCodeUnit) {
        result = new List<Inline>.filled(delim.count, new Apostrophe());
      } else if (charCode == doubleQuoteCodeUnit) {
        result = new List<Inline>.filled(delim.count, new DoubleCloseQuote());
      } else {
        result = <Inline>[
          new Str(new String.fromCharCode(charCode) * delim.count)
        ];
      }

      return new ParseResult<Inlines>.success(new Inlines.from(result), offset);
    }

    final List<_Delim> stack = <_Delim>[delim];

    Inlines result = new Inlines();

    final int length = text.length;
    while (offset < length && stack.length > 0) {
      final _Delim delim = _scanDelims(text, offset);
      if (delim != null) {
        if (delim.canClose) {
          if (delim.charCode == singleQuoteCodeUnit ||
              delim.charCode == doubleQuoteCodeUnit) {
            int openDelimIndex = stack.length - 1;
            while (openDelimIndex >= 0) {
              final _Delim openDelim = stack[openDelimIndex];
              if (openDelim.charCode == delim.charCode) {
                openDelim.matched = true;
                break;
              }
              openDelimIndex--;
            }

            stack.last.inlines.addAll(new List<Inline>.filled(
                delim.count,
                delim.charCode == singleQuoteCodeUnit
                    ? new SingleCloseQuote()
                    : new DoubleCloseQuote()));

            offset += delim.count;
            delim.count = 0;
          } else {
            // Going down through stack, and searching delimiter to close.
            int countCloses = 0;
            int openDelimIndex = stack.length - 1;
            while (openDelimIndex >= 0 && delim.count > 0) {
              final _Delim openDelim = stack[openDelimIndex];
              countCloses = openDelim.countCloses(delim);
              if (countCloses > 0) {
                final _Delim openDelim = stack[openDelimIndex];
                if (openDelimIndex < stack.length - 1) {
                  final Inlines inner = _buildStack(stack, openDelimIndex + 1);
                  openDelim.inlines.addAll(inner);
                }

                Inlines itemRes = openDelim.inlines;

                switch (delim.charCode) {
                  case tildeCodeUnit:
                    int delimsLeft = countCloses;
                    while (delimsLeft >= 2) {
                      itemRes = new Inlines.single(new Strikeout(itemRes));
                      delimsLeft -= 2;
                    }
                    if (delimsLeft == 1) {
                      if (container.options.subscript) {
                        if (!openDelim.containsSpace) {
                          itemRes = unescapeSpaces(itemRes, true);
                          itemRes = new Inlines.single(new Subscript(itemRes));
                        } else {
                          itemRes.insert(0, new Str('~'));
                          itemRes.add(new Str('~'));
                        }
                      } else {
                        itemRes.insert(0, new Str('~'));
                        itemRes.add(new Str('~'));
                      }
                    }
                    break;

                  case caretCodeUnit:
                    if (!openDelim.containsSpace) {
                      itemRes = unescapeSpaces(itemRes, true);
                      itemRes = new Inlines.single(new Superscript(itemRes));
                    } else {
                      itemRes.insert(0, new Str('^'));
                      itemRes.add(new Str('^'));
                    }
                    break;

                  case underscoreCodeUnit:
                  case starCodeUnit:
                    int delimsLeft = countCloses;
                    if ((delimsLeft & 1) == 1) {
                      itemRes = new Inlines.single(new Emph(itemRes));
                      delimsLeft--;
                    }

                    while (delimsLeft > 0) {
                      itemRes = new Inlines.single(new Strong(itemRes));
                      delimsLeft -= 2;
                    }
                    break;
                }
                openDelim.inlines = itemRes;

                openDelim.count -= countCloses;
                if (openDelim.count == 0) {
                  final Inlines itemRes = _buildStack(stack, stack.length - 1);
                  if (stack.length == 0) {
                    result.addAll(itemRes);
                  } else {
                    stack.last.inlines.addAll(itemRes);
                  }
                }

                offset += countCloses;
                delim.count -= countCloses;
              }
              openDelimIndex--;
            }
          }
        }

        if (delim.count > 0) {
          if (delim.canOpen) {
            stack.add(delim);
          } else {
            final Inlines inlines =
                stack.length == 0 ? result : stack.last.inlines;
            inlines.add(
                new Str(new String.fromCharCode(delim.charCode) * delim.count));
          }
        }

        offset += delim.count;
        continue;
      }

      final int codeUnit = text.codeUnitAt(offset);

      // Special processing for subscript and superscript.
      // They cannot contain unescaped spaces.
      if (container.options.subscript || container.options.superscript) {
        // Check for space inside subscript or superscript
        if (codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit) {
          for (_Delim delim in stack) {
            delim.containsSpace = true;
          }
        } else if (codeUnit == backslashCodeUnit) {
          if (offset + 1 < length) {
            final int codeUnit2 = text.codeUnitAt(offset + 1);
            if (codeUnit2 == spaceCodeUnit || codeUnit2 == tabCodeUnit) {
              stack.last.inlines.add(codeUnit2 == spaceCodeUnit
                  ? new _EscapedSpace()
                  : new _EscapedTab());
              offset += 2;
              continue;
            }
          }
        }
      }

      if (codeUnit == exclamationMarkCodeUnit &&
          offset + 1 < length &&
          text.codeUnitAt(offset + 1) == openBracketCodeUnit) {
        // Exclamation mark without bracket means nothing.
        final ParseResult<Inlines> res =
            container.linkImageParser.parse(text, offset);
        if (res.isSuccess) {
          if (res.value.length > 0) {
            stack.last.inlines.addAll(res.value);
          }
          offset = res.offset;
          continue;
        }
      } else if (_inlineParsers.containsKey(codeUnit)) {
        bool found = false;
        for (AbstractParser<Inlines> parser in _inlineParsers[codeUnit]) {
          final ParseResult<Inlines> res = parser.parse(text, offset);
          if (res.isSuccess) {
            if (res.value.length > 0) {
              stack.last.inlines.addAll(res.value);
            }
            offset = res.offset;
            found = true;
            break;
          }
        }

        if (found) {
          continue;
        }
      }

      final ParseResult<Inlines> res = container.strParser.parse(text, offset);
      assert(res.isSuccess);

      if (res.value.length > 0) {
        stack.last.inlines.addAll(res.value);
      }
      offset = res.offset;
    }

    result.addAll(_buildStack(stack, 0));

    if (container.options.subscript || container.options.superscript) {
      result = unescapeSpaces(result, false);
    }

    return new ParseResult<Inlines>.success(result, offset);
  }
}
