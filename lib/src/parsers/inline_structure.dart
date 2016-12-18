library mdown.src.parsers.inline_structure;

import 'dart:collection';
import 'dart:math';

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/ast/combining_nodes.dart';
import 'package:mdown/src/ast/enums.dart';
import 'package:mdown/src/ast/replacing_visitor.dart';
import 'package:mdown/src/bit_set.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

class _Delim {
  final int charCode;
  int count;
  final bool canOpen;
  final bool canClose;

  // Used for unmatched single quote
  bool matched = false;

  /// Required for subscript and superscript as they cannot contain space.
  bool containsSpace = false;
  List<InlineNodeImpl> inlines = <InlineNodeImpl>[];

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
class EscapedSpace extends InlineNodeImpl {
  @override
  // ignore: avoid_as
  R accept<R>(AstVisitor<R> visitor) => (visitor as ReplaceEscapedVisitor)
      .visitEscapedSpace(this);

  // TODO: implement childEntities
  @override
  Iterable<AstNode> get childEntities => null;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Tab inline
class EscapedTab extends InlineNodeImpl {
  @override
  // ignore: avoid_as
  R accept<R>(AstVisitor<R> visitor) => (visitor as ReplaceEscapedVisitor)
      .visitEscapedTab(this);

  // TODO: implement childEntities
  @override
  Iterable<AstNode> get childEntities => null;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Replaces [EscapedSpace] and [EscapedTab] with correspondent inlines.
class ReplaceEscapedVisitor extends ListReplacingAstVisitor {
  final bool _success;

  /// Constructs new visitor. Set [_success] to true if parsing was successful.
  ReplaceEscapedVisitor(this._success);

  visitEscapedSpace(EscapedSpace node) {
    final List<InlineNodeImpl> result = <InlineNodeImpl>[];
    if (!_success) {
      result.add(new StrImpl('\\'));
    }
    result.add(new SpaceImpl(1));

    return result;
  }

  visitEscapedTab(EscapedTab node) {
    final List<InlineNodeImpl> result = <InlineNodeImpl>[];
    if (!_success) {
      result.add(new StrImpl('\\'));
    }
    result.add(new TabImpl(1));

    return result;
  }
}

final ReplacingAstVisitor _failureVisitor =
    new ReplacingAstVisitor(new ReplaceEscapedVisitor(false));

final ReplacingAstVisitor _successVisitor =
    new ReplacingAstVisitor(new ReplaceEscapedVisitor(true));

/// Parsing emphasis, strongs, smartquotes, etc.
class InlineStructureParser extends AbstractParser<InlineNodeImpl> {
  Set<int> _delimitersChars;

  Set<int> _intrawordDelimetersChars;

  Map<int, List<AbstractParser<InlineNodeImpl>>> _inlineParsers;

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
    _inlineParsers = new HashMap<int, List<AbstractParser<InlineNodeImpl>>>();

    _inlineParsers[spaceCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[tabCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[backslashCodeUnit] = <AbstractParser<InlineNodeImpl>>[];
    if (container.options.texMathSingleBackslash) {
      _inlineParsers[backslashCodeUnit]
          .add(container.texMathSingleBackslashParser);
    }
    if (container.options.texMathDoubleBackslash) {
      _inlineParsers[backslashCodeUnit]
          .add(container.texMathDoubleBackslashParser);
    }
    _inlineParsers[backslashCodeUnit].add(container.escapesParser);

    _inlineParsers[ampersandCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.entityParser
    ];

    _inlineParsers[backtickCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.inlineCodeParser
    ];

    _inlineParsers[openBracketCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.linkImageParser
    ];

    _inlineParsers[lessThanCodeUnit] = <AbstractParser<InlineNodeImpl>>[
      container.autolinkParser
    ];

    if (container.options.rawHtml) {
      _inlineParsers[lessThanCodeUnit].add(container.inlineHtmlParser);
    }

    if (container.options.smartPunctuation) {
      _inlineParsers[dotCodeUnit] = <AbstractParser<InlineNodeImpl>>[
        container.ellipsisParser
      ];

      _inlineParsers[minusCodeUnit] = <AbstractParser<InlineNodeImpl>>[
        container.mnDashParser
      ];
    }

    if (container.options.texMathDollars) {
      _inlineParsers[dollarCodeUnit] = <AbstractParser<InlineNodeImpl>>[
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

    final bool leftFlanking = !spaceAfter &&
        !(punctuationAfter && !spaceBefore && !punctuationBefore);
    final bool rightFlanking = !spaceBefore &&
        !(punctuationBefore && !spaceAfter && !punctuationAfter);

    bool canOpen = leftFlanking;
    bool canClose = rightFlanking;
    if (charCode == underscoreCodeUnit ||
        charCode == singleQuoteCodeUnit ||
        charCode == doubleQuoteCodeUnit) {
      canOpen = canOpen && (!rightFlanking || punctuationBefore);
      canClose = canClose && (!leftFlanking || punctuationAfter);
    }

    return new _Delim(charCode, count, canOpen, canClose);
  }

  List<InlineNodeImpl> _buildStack(List<_Delim> stack, int skip) {
    final List<InlineNodeImpl> result = <InlineNodeImpl>[];
    final Iterable<_Delim> list = skip > 0 ? stack.skip(skip) : stack;
    for (_Delim delim in list) {
      if (delim.count > 0) {
        final int charCode = delim.charCode;
        if (charCode == singleQuoteCodeUnit) {
          result.addAll(new List<InlineNodeImpl>.filled(
              delim.count,
              new SmartCharImpl(delim.matched
                  ? SmartCharType.singleOpenQuote
                  : SmartCharType.apostrophe)));
        } else if (charCode == doubleQuoteCodeUnit) {
          result.addAll(new List<InlineNodeImpl>.filled(
              delim.count, new SmartCharImpl(SmartCharType.doubleOpenQuote)));
        } else {
          result.add(
              new StrImpl(new String.fromCharCode(charCode) * delim.count));
        }
      }
      result.addAll(delim.inlines);
    }
    stack.length = skip;

    return result;
  }

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    final _Delim delim = _scanDelims(text, offset);

    offset += delim.count;

    if (!delim.canOpen) {
      final int charCode = delim.charCode;
      if (charCode == singleQuoteCodeUnit || charCode == doubleQuoteCodeUnit) {
        if (delim.count == 1) {
          return new ParseResult<InlineNodeImpl>.success(
              new SmartCharImpl(charCode == singleQuoteCodeUnit
                  ? SmartCharType.apostrophe
                  : SmartCharType.doubleCloseQuote),
              offset);
        } else {
          return new ParseResult<InlineNodeImpl>.success(
              new CombiningInlineNodeImpl(new List<InlineNodeImpl>.filled(
                  delim.count,
                  new SmartCharImpl(charCode == singleQuoteCodeUnit
                      ? SmartCharType.apostrophe
                      : SmartCharType.doubleCloseQuote))),
              offset);
        }
      } else {
        return new ParseResult<InlineNodeImpl>.success(
            new StrImpl(new String.fromCharCode(charCode) * delim.count),
            offset);
      }
    }

    final List<_Delim> stack = <_Delim>[delim];

    List<InlineNodeImpl> result = <InlineNodeImpl>[];

    final int length = text.length;
    while (offset < length && stack.length > 0) {
      final _Delim delim = _scanDelims(text, offset);
      if (delim != null) {
        final int charCode = delim.charCode;
        if (delim.canClose) {
          if (charCode == singleQuoteCodeUnit ||
              charCode == doubleQuoteCodeUnit) {
            int openDelimIndex = stack.length - 1;
            while (openDelimIndex >= 0) {
              final _Delim openDelim = stack[openDelimIndex];
              if (openDelim.charCode == charCode) {
                openDelim.matched = true;
                break;
              }
              openDelimIndex--;
            }

            stack.last.inlines.addAll(new List<InlineNodeImpl>.filled(
                delim.count,
                new SmartCharImpl(charCode == singleQuoteCodeUnit
                    ? SmartCharType.singleCloseQuote
                    : SmartCharType.doubleCloseQuote)));

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
                  final List<InlineNodeImpl> inner =
                      _buildStack(stack, openDelimIndex + 1);
                  openDelim.inlines.addAll(inner);
                }

                List<InlineNodeImpl> itemRes = openDelim.inlines;

                switch (charCode) {
                  case tildeCodeUnit:
                    int delimsLeft = countCloses;
                    while (delimsLeft >= 2) {
                      itemRes = <InlineNodeImpl>[new StrikeoutImpl(itemRes)];
                      delimsLeft -= 2;
                    }
                    if (delimsLeft == 1) {
                      if (container.options.subscript) {
                        if (!openDelim.containsSpace) {
                          final List<InlineNodeImpl> replaced =
                              new List<InlineNodeImpl>.from(
                                  _successVisitor.visitInlineNodeList(itemRes));
                          itemRes = replaced ?? itemRes;

                          itemRes = <InlineNodeImpl>[
                            new SubscriptImpl(itemRes)
                          ];
                        } else {
                          itemRes.insert(0, new StrImpl('~'));
                          itemRes.add(new StrImpl('~'));
                        }
                      } else {
                        itemRes.insert(0, new StrImpl('~'));
                        itemRes.add(new StrImpl('~'));
                      }
                    }
                    break;

                  case caretCodeUnit:
                    if (!openDelim.containsSpace) {
                      final List<InlineNode> replaced =
                          _successVisitor.visitInlineNodeList(itemRes);
                      itemRes = <InlineNodeImpl>[new SuperscriptImpl(replaced)];
                    } else {
                      itemRes.insert(0, new StrImpl('^'));
                      itemRes.add(new StrImpl('^'));
                    }
                    break;

                  case underscoreCodeUnit:
                  case starCodeUnit:
                    int delimsLeft = countCloses;
                    if ((delimsLeft & 1) == 1) {
                      itemRes = <InlineNodeImpl>[
                        new EmphasisImpl(itemRes,
                            emphasisDelimiterTypeFromCodeUnit(charCode))
                      ];
                      delimsLeft--;
                    }

                    while (delimsLeft > 0) {
                      itemRes = <InlineNodeImpl>[
                        new StrongImpl(itemRes,
                            emphasisDelimiterTypeFromCodeUnit(charCode))
                      ];
                      delimsLeft -= 2;
                    }
                    break;
                }
                openDelim.inlines = itemRes;

                openDelim.count -= countCloses;
                if (openDelim.count == 0) {
                  final List<InlineNodeImpl> itemRes =
                      _buildStack(stack, stack.length - 1);
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
            final List<InlineNodeImpl> inlines =
                stack.length == 0 ? result : stack.last.inlines;
            if (charCode == singleQuoteCodeUnit) {
              inlines.addAll(new List<InlineNodeImpl>.filled(
                  delim.count,
                  new SmartCharImpl(delim.matched
                      ? SmartCharType.singleOpenQuote
                      : SmartCharType.apostrophe)));
            } else if (charCode == doubleQuoteCodeUnit) {
              inlines.addAll(new List<InlineNodeImpl>.filled(delim.count,
                  new SmartCharImpl(SmartCharType.doubleOpenQuote)));
            } else {
              inlines.add(
                  new StrImpl(new String.fromCharCode(charCode) * delim.count));
            }
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
                  ? new EscapedSpace()
                  : new EscapedTab());
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
        final ParseResult<InlineNodeImpl> res =
            container.linkImageParser.parse(text, offset);
        if (res.isSuccess) {
          stack.last.inlines.add(res.value);
          offset = res.offset;
          continue;
        }
      } else if (_inlineParsers.containsKey(codeUnit)) {
        bool found = false;
        for (AbstractParser<InlineNodeImpl> parser
            in _inlineParsers[codeUnit]) {
          final ParseResult<InlineNodeImpl> res = parser.parse(text, offset);
          if (res.isSuccess) {
            if (res.value != null) {
              if (res.value is CombiningInlineNodeImpl) {
                final CombiningInlineNodeImpl combining = res.value;
                stack.last.inlines.addAll(combining.list);
              } else {
                stack.last.inlines.add(res.value);
              }
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

      final ParseResult<InlineNodeImpl> res =
          container.strParser.parse(text, offset);
      assert(res.isSuccess);

      stack.last.inlines.add(res.value);
      offset = res.offset;
    }

    result.addAll(_buildStack(stack, 0));

    if (container.options.subscript || container.options.superscript) {
      result = new List<InlineNodeImpl>.from(
          _failureVisitor.visitInlineNodeList(result));
    }

    if (result.isEmpty) {
      return new ParseResult<InlineNodeImpl>.success(null, offset);
    } else if (result.length == 1) {
      return new ParseResult<InlineNodeImpl>.success(result.single, offset);
    }
    return new ParseResult<InlineNodeImpl>.success(
        new CombiningInlineNodeImpl(result), offset);
  }
}
