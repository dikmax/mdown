library mdown.src.parsers.inline_structure;

import 'dart:collection';
import 'dart:math';

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/ast/combining_nodes.dart';
import 'package:mdown/src/ast/replacing_visitor.dart';
import 'package:mdown/src/bit_set.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

class _Delim {
  _Delim(this.charCode, this.count, {this.canOpen, this.canClose});

  final int charCode;
  int count;
  final bool canOpen;
  final bool canClose;

  // Used for unmatched single quote
  bool matched = false;

  /// Required for subscript and superscript as they cannot contain space.
  bool containsSpace = false;
  List<InlineNodeImpl> inlines = <InlineNodeImpl>[];

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
  R accept<R>(AstVisitor<R> visitor) {
    if (visitor is ExcapedInlinesVisitor) {
      final ExcapedInlinesVisitor<R> v = visitor;
      return v.visitEscapedSpace(this);
    }
    return null;
  }

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Tab inline
class EscapedTab extends InlineNodeImpl {
  @override
  R accept<R>(AstVisitor<R> visitor) {
    if (visitor is ExcapedInlinesVisitor) {
      final ExcapedInlinesVisitor<R> v = visitor;
      return v.visitEscapedTab(this);
    }
    return null;
  }

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Extended visitor for UnparsedInlines.
abstract class ExcapedInlinesVisitor<R> extends AstVisitor<R> {
  /// Visits escaped space.
  R visitEscapedSpace(EscapedSpace node);

  /// Visits escaped tab.
  R visitEscapedTab(EscapedTab node);
}

/// Replaces [EscapedSpace] and [EscapedTab] with correspondent inlines.
class ReplaceEscapedVisitor extends ListReplacingAstVisitor
    implements ExcapedInlinesVisitor<List<AstNodeImpl>> {
  /// Constructs new visitor. Set [success] to true if parsing was successful.
  ReplaceEscapedVisitor({this.success});

  /// Is parsing was successful.
  final bool success;

  @override
  List<AstNodeImpl> visitEscapedSpace(EscapedSpace node) {
    final List<InlineNodeImpl> result = <InlineNodeImpl>[];
    if (!success) {
      result.add(StrImpl('\\'));
    }
    result.add(SpaceImpl(1));

    return result;
  }

  @override
  List<AstNodeImpl> visitEscapedTab(EscapedTab node) {
    final List<InlineNodeImpl> result = <InlineNodeImpl>[];
    if (!success) {
      result.add(StrImpl('\\'));
    }
    result.add(TabImpl(1));

    return result;
  }
}

final ReplacingAstVisitor _failureVisitor =
    ReplacingAstVisitor(ReplaceEscapedVisitor(success: false));

final ReplacingAstVisitor _successVisitor =
    ReplacingAstVisitor(ReplaceEscapedVisitor(success: true));

/// Parsing emphasis, strongs, smartquotes, etc.
class InlineStructureParser extends AbstractParser<InlineNodeImpl> {
  /// Constructor.
  InlineStructureParser(ParsersContainer container) : super(container) {
    _delimitersChars = BitSet(256)
      ..addAll(<int>[starCodeUnit, underscoreCodeUnit]);

    _intrawordDelimetersChars = BitSet(256)..add(starCodeUnit);

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

  Set<int> _delimitersChars;

  Set<int> _intrawordDelimetersChars;

  Map<int, List<AbstractParser<InlineNodeImpl>>> _inlineParsers;

  @override
  void init() {
    _inlineParsers = HashMap<int, List<AbstractParser<InlineNodeImpl>>>();

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
      return _Delim(charCode, count, canOpen: false, canClose: false);
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

      // Single quote cannot open after `]` or `)`.
      if (charCode == singleQuoteCodeUnit &&
          (codeUnitBefore == closeParenCodeUnit ||
              codeUnitBefore == closeBracketCodeUnit)) {
        canOpen = false;
      }
    }

    return _Delim(charCode, count, canOpen: canOpen, canClose: canClose);
  }

  List<InlineNodeImpl> _buildStack(List<_Delim> stack, int skip) {
    final List<InlineNodeImpl> result = <InlineNodeImpl>[];
    final Iterable<_Delim> list = skip > 0 ? stack.skip(skip) : stack;
    for (final _Delim delim in list) {
      if (delim.count > 0) {
        final int charCode = delim.charCode;
        if (charCode == singleQuoteCodeUnit) {
          result.addAll(List<InlineNodeImpl>.filled(
              delim.count,
              SmartCharImpl(delim.matched
                  ? SmartCharType.singleOpenQuote
                  : SmartCharType.apostrophe)));
        } else if (charCode == doubleQuoteCodeUnit) {
          result.addAll(List<InlineNodeImpl>.filled(
              delim.count, SmartCharImpl(SmartCharType.doubleOpenQuote)));
        } else {
          result.add(StrImpl(String.fromCharCode(charCode) * delim.count));
        }
      }
      result.addAll(delim.inlines);
    }
    stack.length = skip;

    return result;
  }

  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    int off = offset;
    final _Delim delim = _scanDelims(text, off);

    off += delim.count;

    if (!delim.canOpen) {
      final int charCode = delim.charCode;
      if (charCode == singleQuoteCodeUnit || charCode == doubleQuoteCodeUnit) {
        if (delim.count == 1) {
          return ParseResult<InlineNodeImpl>.success(
              SmartCharImpl(charCode == singleQuoteCodeUnit
                  ? SmartCharType.apostrophe
                  : SmartCharType.doubleCloseQuote),
              off);
        } else {
          return ParseResult<InlineNodeImpl>.success(
              CombiningInlineNodeImpl(List<InlineNodeImpl>.filled(
                  delim.count,
                  SmartCharImpl(charCode == singleQuoteCodeUnit
                      ? SmartCharType.apostrophe
                      : SmartCharType.doubleCloseQuote))),
              off);
        }
      } else {
        return ParseResult<InlineNodeImpl>.success(
            StrImpl(String.fromCharCode(charCode) * delim.count), off);
      }
    }

    final List<_Delim> stack = <_Delim>[delim];

    List<InlineNodeImpl> result = <InlineNodeImpl>[];

    final int length = text.length;
    while (off < length && stack.isNotEmpty) {
      final _Delim delim = _scanDelims(text, off);
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

            stack.last.inlines.addAll(List<InlineNodeImpl>.filled(
                delim.count,
                SmartCharImpl(charCode == singleQuoteCodeUnit
                    ? SmartCharType.singleCloseQuote
                    : SmartCharType.doubleCloseQuote)));

            off += delim.count;
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
                      itemRes = <InlineNodeImpl>[StrikeoutImpl(itemRes)];
                      delimsLeft -= 2;
                    }
                    if (delimsLeft == 1) {
                      if (container.options.subscript) {
                        if (!openDelim.containsSpace) {
                          final List<InlineNodeImpl> replaced =
                              List<InlineNodeImpl>.from(
                                  _successVisitor.visitInlineNodeList(itemRes));
                          itemRes = replaced ?? itemRes;

                          itemRes = <InlineNodeImpl>[SubscriptImpl(itemRes)];
                        } else {
                          itemRes
                            ..insert(0, StrImpl('~'))
                            ..add(StrImpl('~'));
                        }
                      } else {
                        itemRes
                          ..insert(0, StrImpl('~'))
                          ..add(StrImpl('~'));
                      }
                    }
                    break;

                  case caretCodeUnit:
                    if (!openDelim.containsSpace) {
                      final List<InlineNode> replaced =
                          _successVisitor.visitInlineNodeList(itemRes);
                      itemRes = <InlineNodeImpl>[SuperscriptImpl(replaced)];
                    } else {
                      itemRes
                        ..insert(0, StrImpl('^'))
                        ..add(StrImpl('^'));
                    }
                    break;

                  case underscoreCodeUnit:
                  case starCodeUnit:
                    int delimsLeft = countCloses;

                    while (delimsLeft > 1) {
                      itemRes = <InlineNodeImpl>[StrongImpl(itemRes)];
                      delimsLeft -= 2;
                    }

                    if ((delimsLeft & 1) == 1) {
                      itemRes = <InlineNodeImpl>[EmphasisImpl(itemRes)];
                      delimsLeft--;
                    }

                    break;
                }
                openDelim
                  ..inlines = itemRes
                  ..count -= countCloses;
                if (openDelim.count == 0) {
                  final List<InlineNodeImpl> itemRes =
                      _buildStack(stack, stack.length - 1);
                  if (stack.isEmpty) {
                    result.addAll(itemRes);
                  } else {
                    stack.last.inlines.addAll(itemRes);
                  }
                }

                off += countCloses;
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
                stack.isEmpty ? result : stack.last.inlines;
            if (charCode == singleQuoteCodeUnit) {
              inlines.addAll(List<InlineNodeImpl>.filled(
                  delim.count,
                  SmartCharImpl(delim.matched
                      ? SmartCharType.singleOpenQuote
                      : SmartCharType.apostrophe)));
            } else if (charCode == doubleQuoteCodeUnit) {
              inlines.addAll(List<InlineNodeImpl>.filled(
                  delim.count, SmartCharImpl(SmartCharType.doubleOpenQuote)));
            } else {
              inlines.add(StrImpl(String.fromCharCode(charCode) * delim.count));
            }
          }
        }

        off += delim.count;
        continue;
      }

      final int codeUnit = text.codeUnitAt(off);

      // Special processing for subscript and superscript.
      // They cannot contain unescaped spaces.
      if (container.options.subscript || container.options.superscript) {
        // Check for space inside subscript or superscript
        if (codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit) {
          for (final _Delim delim in stack) {
            delim.containsSpace = true;
          }
        } else if (codeUnit == backslashCodeUnit) {
          if (off + 1 < length) {
            final int codeUnit2 = text.codeUnitAt(off + 1);
            if (codeUnit2 == spaceCodeUnit || codeUnit2 == tabCodeUnit) {
              stack.last.inlines.add(
                  codeUnit2 == spaceCodeUnit ? EscapedSpace() : EscapedTab());
              off += 2;
              continue;
            }
          }
        }
      }

      if (codeUnit == exclamationMarkCodeUnit &&
          off + 1 < length &&
          text.codeUnitAt(off + 1) == openBracketCodeUnit) {
        // Exclamation mark without bracket means nothing.
        final ParseResult<InlineNodeImpl> res =
            container.linkImageParser.parse(text, off);
        if (res.isSuccess) {
          stack.last.inlines.add(res.value);
          off = res.offset;
          continue;
        }
      } else if (_inlineParsers.containsKey(codeUnit)) {
        bool found = false;
        for (final AbstractParser<InlineNodeImpl> parser
            in _inlineParsers[codeUnit]) {
          final ParseResult<InlineNodeImpl> res = parser.parse(text, off);
          if (res.isSuccess) {
            if (res.value != null) {
              if (res.value is CombiningInlineNodeImpl) {
                final CombiningInlineNodeImpl combining = res.value;
                stack.last.inlines.addAll(combining.list);
              } else {
                stack.last.inlines.add(res.value);
              }
            }
            off = res.offset;
            found = true;
            break;
          }
        }

        if (found) {
          continue;
        }
      }

      final ParseResult<InlineNodeImpl> res =
          container.strParser.parse(text, off);
      assert(res.isSuccess, 'strParser should always succeed');

      stack.last.inlines.add(res.value);
      off = res.offset;
    }

    result.addAll(_buildStack(stack, 0));

    if (container.options.subscript || container.options.superscript) {
      result = List<InlineNodeImpl>.from(
          _failureVisitor.visitInlineNodeList(result));
    }

    if (result.isEmpty) {
      return ParseResult<InlineNodeImpl>.success(null, off);
    } else if (result.length == 1) {
      return ParseResult<InlineNodeImpl>.success(result.single, off);
    }
    return ParseResult<InlineNodeImpl>.success(
        CombiningInlineNodeImpl(result), off);
  }
}
