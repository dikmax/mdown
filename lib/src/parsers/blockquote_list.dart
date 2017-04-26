library mdown.src.parsers.blockquote_list;

import 'dart:collection';

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/standard_ast_factory.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/ast/enums.dart';
import 'package:mdown/src/ast/combining_nodes.dart';
import 'package:mdown/src/ast/unparsed_inlines.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/lookup.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

// Stack

class _StackItem {
  String unparsedContent = '';
  _ExtendedBlock block;
  _Marker marker;
  AbstractParser<Iterable<BlockNodeImpl>> innerBlocksParser;
  // Do not merge.
  bool afterEmpty = false;

  _StackItem(this.marker, this.innerBlocksParser) {
    block = marker.createBlock();
  }

  /// Returns `true` if block ends with blank line
  bool parse() {
    if (unparsedContent == '') {
      return false;
    }

    final ParseResult<Iterable<BlockNodeImpl>> result =
        innerBlocksParser.parse(unparsedContent, 0);
    assert(result.isSuccess);

    Iterable<BlockNodeImpl> blocks = result.value;
    final bool endsWithBlankline = blocks.last == null;

    while (blocks.isNotEmpty && blocks.last == null) {
      final List<BlockNodeImpl> b = blocks;
      b.removeLast();
    }

    if (!marker.isBlockquote && blocks.isNotEmpty && block is ListBlockImpl) {
      final ListBlockImpl listBlock = block as ListBlock;

      if (listBlock.items.isNotEmpty &&
          listBlock.items.last.contents.isEmpty &&
          blocks.elementAt(0) == null) {
        blocks = blocks.skip(1);
      }
      if (blocks.contains(null)) {
        listBlock.tight = false;
      }
    }

    blocks = blocks.where(_isNotBlockALinkReference);

    final BlockNode last = block.last;
    if (!this.afterEmpty && last is ParaImpl && blocks.first is ParaImpl) {
      // Merge paragraph.
      final UnparsedInlines inlines = last.contents;
      final ParaImpl para = blocks.first;
      final UnparsedInlines inlines2 = para.contents;
      inlines.contents += '\n' + inlines2.contents;
    } else {
      block.addToEnd(blocks);
    }

    unparsedContent = '';

    return endsWithBlankline;
  }

  void addItem(_Marker marker) {
    parse();
    block.addItem();
    this.marker = marker;
  }

  void addLine(String line) {
    unparsedContent += line + '\n';
  }

  bool addLazyLine(String line) {
    if (this.unparsedContent == '\n' || this.unparsedContent.endsWith('\n\n')) {
      return false;
    }
    parse();
    final BlockNode last = block.last;
    if (last != null && last is Para) {
      final int indent = skipIndent(line, 0);
      if (thematicBreakLookup.isFound(line, indent) ||
          atxHeadingLookup.isFound(line, indent) ||
          fencedCodeStartLookup.isFound(line, indent)) {
        // TODO add html block and link reference test
        return false;
      }
      final UnparsedInlines contents = last.contents;
      contents.contents += '\n' + line;
      return true;
    }

    return false;
  }

  void setTight(bool tight) {
    if (!marker.isBlockquote) {
      final ListBlockImpl listBlock = block as ListBlockImpl;
      listBlock.tight = tight;
    }
  }

  static bool _isNotBlockALinkReference(BlockNode block) =>
      block != null && block is! LinkReference;
}

class _Stack extends ListBase<_StackItem> {
  final List<_StackItem> _stack = <_StackItem>[];

  @override
  int get length => _stack.length;

  @override
  set length(int newLength) {
    _stack.length = newLength;
  }

  @override
  void add(_StackItem element) {
    if (_stack.isNotEmpty) {
      _stack.last.parse();
    }

    _stack.add(element);
  }

  @override
  void addAll(Iterable<_StackItem> all) {
    if (_stack.isNotEmpty) {
      _stack.last.parse();
    }

    _stack.addAll(all);
  }

  @override
  _StackItem operator [](int index) => _stack[index];

  @override
  void operator []=(int index, _StackItem value) {
    _stack[index] = value;
  }

  void addItem(_Marker marker) {
    assert(_stack.isNotEmpty);

    _stack.last.addItem(marker);
  }

  void addLine(String line) {
    assert(_stack.isNotEmpty);

    _stack.last.addLine(line);
  }

  bool addLazyLine(String line) {
    assert(_stack.isNotEmpty);

    return _stack.last.addLazyLine(line);
  }

  /// Parsing all unparsed blocks and reducing stack size to [length].
  /// Returns last removed block.
  void flush(int length, List<BlockNodeImpl> result) {
    while (this.length > length) {
      // If flushed block ends with empty line and it's not a blockquote,
      // then we need to shift this line one level up.
      _StackItem last = this.last;
      final bool moveBlankLineUp = last.parse() && !last.marker.isBlockquote;

      final BlockNode lastBlock = last.block;

      removeLast();

      if (this.isNotEmpty) {
        last = this.last;
        last.block.addToEnd(<BlockNodeImpl>[lastBlock]);
        if (moveBlankLineUp) {
          last.unparsedContent += '\n';
        }
      } else {
        result.add(lastBlock);
      }
    }
  }

  void setAfterEmpty(bool afterEmpty, [int skip = 0]) {
    Iterable<_StackItem> stack = _stack;
    if (skip > 0) {
      stack = _stack.skip(skip);
    }
    for (_StackItem stackItem in stack) {
      stackItem.afterEmpty = afterEmpty;
    }
  }

  void setTight(bool tight) {
    assert(_stack.isNotEmpty);

    _stack.last.setTight(tight);
  }
}

// Markers

abstract class _ExtendedBlock extends BlockNode {
  void addToEnd(Iterable<BlockNodeImpl> blocks);
  void addItem();
  BlockNode get last;
}

class _ExtendedBlockquote extends BlockquoteImpl implements _ExtendedBlock {
  _ExtendedBlockquote(Iterable<BlockNodeImpl> contents) : super(contents);

  @override
  void addToEnd(Iterable<BlockNodeImpl> blocks) {
    final List<BlockNode> c = contents;

    c.addAll(blocks);
  }

  @override
  void addItem() {}

  @override
  BlockNode get last => contents.isEmpty ? null : contents.last;
}

class _ExtendedOrderedList extends OrderedListImpl implements _ExtendedBlock {
  _ExtendedOrderedList(Iterable<ListItem> items, bool tight, int startIndex,
      IndexSeparator indexSeparator)
      : super(items, tight, startIndex, indexSeparator);

  @override
  void addToEnd(Iterable<BlockNodeImpl> blocks) {
    assert(items.isNotEmpty);

    final ListItem item = items.last;

    final List<BlockNode> c = item.contents;
    c.addAll(blocks);
  }

  @override
  void addItem() {
    assert(this.items.isNotEmpty);

    final NodeList<ListItem> items = this.items;

    items.add(astFactory.listItem(<BlockNodeImpl>[]));
  }

  @override
  BlockNode get last => items.isEmpty
      ? null
      : (items.last.contents.isEmpty ? null : items.last.contents.last);
}

class _ExtendedUnorderedList extends UnorderedListImpl
    implements _ExtendedBlock {
  _ExtendedUnorderedList(
      Iterable<ListItem> items, bool tight, BulletType bulletType)
      : super(items, tight, bulletType);

  @override
  void addToEnd(Iterable<BlockNodeImpl> blocks) {
    assert(items.isNotEmpty);

    final ListItem item = items.last;

    final List<BlockNode> c = item.contents;

    c.addAll(blocks);
  }

  @override
  void addItem() {
    assert(this.items.isNotEmpty);

    final NodeList<ListItem> items = this.items;

    items.add(astFactory.listItem(<BlockNodeImpl>[]));
  }

  @override
  BlockNode get last => items.isEmpty
      ? null
      : (items.last.contents.isEmpty ? null : items.last.contents.last);
}

abstract class _Marker {
  int startIndent;
  int endIndent;
  int offset;
  bool isBlockquote;
  bool isList;

  _Marker(this.startIndent, this.endIndent, this.offset, bool blockquote)
      : isBlockquote = blockquote,
        isList = !blockquote;

  _ExtendedBlock createBlock([Iterable<BlockNodeImpl> contents]);

  bool isSame(_Marker marker);
}

class _BlockquoteMarker extends _Marker {
  _BlockquoteMarker(int startIndent, int endIndent, int offset)
      : super(startIndent, endIndent, offset, true);

  @override
  _ExtendedBlock createBlock([Iterable<BlockNodeImpl> contents]) {
    return new _ExtendedBlockquote(contents ?? <BlockNodeImpl>[]);
  }

  @override
  bool isSame(_Marker marker) => marker.isBlockquote;
}

class _UnorderedListMarker extends _Marker {
  BulletType bullet;

  _UnorderedListMarker(this.bullet, int startIndent, int endIndent, int offset)
      : super(startIndent, endIndent, offset, false);

  @override
  _ExtendedBlock createBlock([Iterable<BlockNodeImpl> contents]) {
    final List<ListItem> items = <ListItem>[
      astFactory.listItem(contents ?? <BlockNodeImpl>[])
    ];
    return new _ExtendedUnorderedList(items, true, bullet);
  }

  @override
  bool isSame(_Marker marker) =>
      marker is _UnorderedListMarker && marker.bullet == bullet;
}

class _OrderedListMarker extends _Marker {
  IndexSeparator indexSeparator;
  int startIndex;

  _OrderedListMarker(this.indexSeparator, this.startIndex, int startIndent,
      int endIndent, int offset)
      : super(startIndent, endIndent, offset, false);

  @override
  _ExtendedBlock createBlock([Iterable<BlockNodeImpl> contents]) {
    final List<ListItem> items = <ListItem>[
      astFactory.listItem(contents ?? <BlockNodeImpl>[])
    ];

    return new _ExtendedOrderedList(items, true, startIndex, indexSeparator);
  }

  @override
  bool isSame(_Marker marker) {
    return marker is _OrderedListMarker &&
        marker.indexSeparator == indexSeparator;
  }
}

// Parser

class _InnerBlocksParser extends AbstractParser<Iterable<BlockNodeImpl>> {
  Map<int, List<AbstractParser<BlockNodeImpl>>> _blockParsers;

  List<AbstractParser<BlockNodeImpl>> _blockParsersRest;

  _InnerBlocksParser(ParsersContainer container) : super(container);

  @override
  void init() {
    _blockParsers = new HashMap<int, List<AbstractParser<BlockNodeImpl>>>();

    for (int char in <int>[starCodeUnit, minusCodeUnit, underscoreCodeUnit]) {
      _blockParsers[char] = <AbstractParser<BlockNodeImpl>>[
        container.thematicBreakParser
      ];
    }

    _blockParsers[sharpCodeUnit] = <AbstractParser<BlockNodeImpl>>[
      container.atxHeadingParser
    ];

    for (int char in <int>[spaceCodeUnit, tabCodeUnit]) {
      _blockParsers[char] = <AbstractParser<BlockNodeImpl>>[
        container.indentedCodeParser
      ];
    }

    for (int char in <int>[tildeCodeUnit, backtickCodeUnit]) {
      _blockParsers[char] = <AbstractParser<BlockNodeImpl>>[
        container.fencedCodeParser
      ];
    }

    if (container.options.rawHtml) {
      _blockParsers[lessThanCodeUnit] = <AbstractParser<BlockNodeImpl>>[
        container.htmlBlockParser,
        container.htmlBlock7Parser
      ];
    }

    if (container.options.rawTex) {
      _blockParsers[backslashCodeUnit] = <AbstractParser<BlockNodeImpl>>[
        container.rawTexParser
      ];
    }

    // Rest of block parsers
    _blockParsersRest = <AbstractParser<BlockNodeImpl>>[];
    if (container.options.pipeTables) {
      _blockParsersRest.add(container.pipeTablesParser);
    }
    _blockParsersRest.add(container.paraSetextHeadingParser);
  }

  @override
  ParseResult<Iterable<BlockNodeImpl>> parse(String text, int offset) {
    int offset = 0;
    final List<BlockNodeImpl> blocks = <BlockNodeImpl>[];

    final int length = text.length;
    while (offset < length) {
      final int firstChar = getBlockFirstChar(text, offset);

      if (firstChar == -1) {
        // End of input
        break;
      }

      if (firstChar == openBracketCodeUnit) {
        // Special treatment for link references.
        // TODO we don't need it
        final ParseResult<LinkReferenceImpl> res =
            container.linkReferenceParser.parse(text, offset);
        if (res.isSuccess) {
          final String referenceString = res.value.normalizedReference;
          if (!container.references.containsKey(referenceString)) {
            container.references[referenceString] = res.value;
          }
          blocks.add(res.value);
          offset = res.offset;
          continue;
        }
      } else if (firstChar == spaceCodeUnit ||
          firstChar == tabCodeUnit ||
          firstChar == newLineCodeUnit ||
          firstChar == carriageReturnCodeUnit) {
        final ParseResult<BlockNodeImpl> res =
            container.blanklineParser.parse(text, offset);

        if (res.isSuccess) {
          blocks.add(null);
          offset = res.offset;
          continue;
        }
      }
      if (_blockParsers.containsKey(firstChar)) {
        bool found = false;
        for (AbstractParser<BlockNodeImpl> parser in _blockParsers[firstChar]) {
          final ParseResult<BlockNodeImpl> res = parser.parse(text, offset);
          if (res.isSuccess) {
            if (res.value != null) {
              if (res.value is CombiningBlockNodeImpl) {
                final CombiningBlockNodeImpl combining = res.value;
                blocks.addAll(combining.list);
              } else {
                blocks.add(res.value);
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

      for (AbstractParser<BlockNodeImpl> parser in _blockParsersRest) {
        final ParseResult<BlockNodeImpl> res = parser.parse(text, offset);
        if (res.isSuccess) {
          if (res.value != null) {
            if (res.value is CombiningBlockNodeImpl) {
              final CombiningBlockNodeImpl combining = res.value;
              blocks.addAll(combining.list);
            } else {
              blocks.add(res.value);
            }
          }
          offset = res.offset;
          break;
        }
      }
    }

    return new ParseResult<Iterable<BlockNodeImpl>>.success(blocks, offset);
  }
}

/// Parser for blockquotes and lists.
class BlockquoteListParser extends AbstractParser<BlockNodeImpl> {
  _InnerBlocksParser _innerBlocksParser;

  /// Constructor.
  BlockquoteListParser(ParsersContainer container) : super(container) {
    _innerBlocksParser = new _InnerBlocksParser(container);
  }

  @override
  void init() {
    _innerBlocksParser.init();
  }

  static final RegExp _markerRegExp = new RegExp(r'[>+\-*]|\d{1,9}[.)]');

  _Marker _markerFromString(String marker, int start, int end, int offset) {
    if (marker == '>') {
      return new _BlockquoteMarker(start, end, offset);
    }
    if (marker.length == 1) {
      return new _UnorderedListMarker(
          bulletTypeFromCodeUnit(marker.codeUnitAt(0)), start, end, offset);
    }

    final IndexSeparator indexSeparator =
        indexSeparatorFromCodeUnit(marker.codeUnitAt(marker.length - 1));
    final int startIndex = int.parse(marker.substring(0, marker.length - 1));
    return new _OrderedListMarker(
        indexSeparator, startIndex, start, end, offset);
  }

  List<_Marker> _getMarkers(String line, [int indent = 0, int offset = 0]) {
    int ind = indent;
    int off = offset;
    final List<_Marker> result = <_Marker>[];

    final int length = line.length;
    while (off < length) {
      while (off < length) {
        final int codeUnit = line.codeUnitAt(off);
        if (codeUnit == spaceCodeUnit) {
          ind++;
          off++;
        } else if (codeUnit == tabCodeUnit) {
          ind = ((ind >> 2) + 1) << 2; // (indent / 4 + 1) * 4
          off++;
        } else {
          break;
        }
      }

      if (off == length) {
        break;
      }

      final Match match = _markerRegExp.matchAsPrefix(line, off);
      if (match == null) {
        if (result.isNotEmpty) {
          // Blocks indent should counted from first block indent, but
          // only if it not exceeds 3 spaces.
          if (ind < result.last.endIndent + 4) {
            result.last.endIndent = ind;
          }
        }
        break; // No Marker found.
      }

      off = match.end;
      final int startIndent = ind;
      final String markerString = match[0];
      ind += markerString.length;
      if (off < length) {
        final int codeUnit = line.codeUnitAt(off);
        if (codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit) {
          result.add(_markerFromString(
              markerString, startIndent, ind + 1, off + 1));
          if (codeUnit == spaceCodeUnit) {
            ind++;
            off++;
          } else {
            ind = ((ind >> 2) + 1) << 2; // (indent / 4 + 1) * 4
            off++;
          }
        } else if (markerString == '>') {
          result.add(new _BlockquoteMarker(startIndent, ind + 1, off));
        } else {
          // Can't be a marker
          break;
        }
      } else {
        result.add(
            _markerFromString(markerString, startIndent, ind + 1, off));
        break;
      }
    }

    return result;
  }

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    int off = offset;
    final _Stack stack = new _Stack();
    final List<BlockNodeImpl> result = <BlockNodeImpl>[];

    final int length = text.length;
    while (off < length) {
      final ParseResult<String> lineResult =
          container.lineParser.parse(text, off);
      assert(lineResult.isSuccess);

      Iterable<_Marker> markers = _getMarkers(lineResult.value, 0, 0);

      if (markers.isEmpty && stack.isEmpty) {
        // No marker found and we at the top.
        // What we parsing isn't a list or blockquote.
        break;
      }

      // Matching stack with correspondent marker items.
      //
      // Possible cases on each comparison step:
      //
      // 1. Stack: blockquote, marker: blockquote (*)
      // 2. Stack: blockquote, marker: list (*)
      // 3. Stack: blockquote, marker: none
      // 4. Stack: list, marker: any, lot space between (*)
      // 5. Stack: list, marker: same list (*)
      // 6. Stack: list, marker: any other (*)
      // 7. Stack: list, marker: none
      // 8. Stack: none, marker: any
      //
      // Cases with (*) are processed in main while loop.
      // Other cases are dealt with, when we run out of element
      // in one of lists.

      int stackIndex = 0;
      int markersIndex = 0;

      /// Rightmost blockquote marker. We need it to proper empty
      /// line calculations.
      int blockquoteIndex = -1;

      int indent = 0;

      /// -1 if not applied, other shows lowest level on which can be used.
      /// Usually it's blockquoteIndex + 1.
      int lazyLineMode = -1;

      while (stackIndex < stack.length && markersIndex < markers.length) {
        final _StackItem stackItem = stack[stackIndex];
        final _Marker marker = markers.elementAt(markersIndex);

        if (stackItem.marker.isBlockquote) {
          if (marker.isBlockquote) {
            // Case 1. Stack: blockquote, marker: blockquote.
            // Going to next iteration: stack++, marker++.

            blockquoteIndex = stackIndex;

            if (markersIndex == 0) {
              indent = marker.endIndent;
            } else {
              indent += marker.endIndent -
                  markers.elementAt(markersIndex - 1).endIndent;
            }

            stackIndex++;
            markersIndex++;
            continue;
          } else {
            // Case 2. Stack: blockquote, marker: list

            if (marker.startIndent > indent + 3) {
              // Case 2a. list is over-indented
              // Going to lazy line mode. Treat rest as text.
              lazyLineMode = blockquoteIndex + 1;
              blockquoteIndex = stackIndex;

              markers = markers.take(markersIndex);
              break;
            }

            // Case 2b. List is normally indented.
            // Drop stack from this point. Stop iteration
            stack.flush(stackIndex, result);
            break;
          }
        } else {
          final int markerIndent = marker.endIndent - indent;

          final int markerSize = marker.endIndent - marker.startIndent - 1;

          int stackMarkerIndent = stackItem.marker.endIndent;
          if (stackIndex > 0) {
            stackMarkerIndent -= stack[stackIndex - 1].marker.endIndent;
          }

          if (markerIndent > stackMarkerIndent + markerSize) {
            // Case 4. Stack: list, marker: any, lot space between
            // Move to next item in stack, stack++, increase indent.

            // +markerSize in condition used to account for additional space
            // required to start new level.

            indent += stackMarkerIndent;
            stackIndex++;
            continue;
          }

          final String thematicTest = stackIndex > 0
              ? lineResult.value.substring(stack[stackIndex - 1].marker.offset)
              : lineResult.value;

          // Checking for thematic break;
          final int thematicTestIndent = skipIndent(thematicTest, 0);
          if (thematicBreakLookup.isFound(thematicTest, thematicTestIndent)
              && thematicTestIndent < stack.last.marker.endIndent) {
            // This line should be treated as standalone thematic break.
            stack.flush(stackIndex, result);
            markers = markers.take(markersIndex);
            break;
          }

          if (marker.isSame(stackItem.marker)) {
            // Case 5. Stack: list, marker: same list
            // It's new item on same level. Dropping rest of stack.
            // And stop here too!

            stack.flush(stackIndex + 1, result);
            if (stack.last.afterEmpty) {
              // We have empty line between list items, list is loose.
              stack.setTight(false);
            }
            // And adding new item.
            stack.addItem(marker);
            stackIndex++;
            markersIndex++;
            break;
          } else {
            // Case 6. Stack: list, marker: any other
            // New list/blockquote on same level
            // Flushing stack as we starting list instead.
            stack.flush(stackIndex, result);
            break;
          }
        }
      }

      // Here we've processed whole stack or whole markers list, or both

      if (markers.isEmpty && stack.isEmpty) {
        // No marker found and we at the top.
        // Most likely thematic break had broke parsing.
        break;
      }

      String lineRest;
      bool isEmpty;

      if (stackIndex < stack.length) {
        // Going through rest of stack. Cases 3 and 7.

        lineRest = markers.isNotEmpty
            ? lineResult.value.substring(markers.last.offset)
            : lineResult.value;
        isEmpty = isOnlyWhitespace(lineRest);

        while (stackIndex < stack.length) {
          final _StackItem stackItem = stack[stackIndex];

          if (stackItem.marker.isBlockquote) {
            // Case 3. Stack: blockquote, marker: none
            // Skip marker and go to lazy line mode.
            lazyLineMode = stackIndex;

            if (isEmpty) {
              stack.flush(stackIndex, result);
            }
            break;
          } else {
            // Case 7. Stack: list, marker: none
            // Trying to detect lazy line mode by amount of space.

            if (isEmpty) {
              stack..setAfterEmpty(true, blockquoteIndex + 1)..addLine('');
              break;
            }

            int stackMarkerIndent = stackItem.marker.endIndent;
            if (stackIndex > 0) {
              stackMarkerIndent -= stack[stackIndex - 1].marker.endIndent;
            }

            final String lineRestWithoutIndent =
                removeIndent(lineRest, stackMarkerIndent, false);
            if (lineRestWithoutIndent == null) {
              // Where's not enough space for strict line.
              lazyLineMode = stackIndex;
              break;
            }

            // Ok, enough space, next iteration.
            lineRest = lineRestWithoutIndent;
            stackIndex++;
          }
        }
      } else if (markersIndex < markers.length) {
        // Case 8. stack: none, marker: any
        // Adding rest of markers

        for (_Marker marker in markers.skip(markersIndex)) {
          String thematicTest;
          if (stack.isNotEmpty) {
            if (stack.last.marker.offset < lineResult.value.length) {
              thematicTest =
                  lineResult.value.substring(stack.last.marker.offset);
            } else {
              thematicTest = '';
            }
          } else {
            thematicTest = lineResult.value;
          }

          // Checking for thematic break;
          final int thematicTestIndent = skipIndent(thematicTest, 0);
          if (thematicBreakLookup.isFound(thematicTest, thematicTestIndent)
              && thematicTestIndent < stack.last.marker.endIndent) {
            // This line should be treated as standalone thematic break.
            break;
          }

          if (marker.startIndent >= indent + 4) {
            break;
          }

          if (stack.isNotEmpty && stack.last.afterEmpty) {
            stack.last.setTight(false);
          }

          stack.add(new _StackItem(marker, _innerBlocksParser));
          if (markersIndex == 0) {
            indent = marker.endIndent;
          } else {
            indent += marker.endIndent -
                markers.elementAt(markersIndex - 1).endIndent;
          }
          markersIndex++;
          if (marker.isBlockquote) {
            blockquoteIndex = stack.length - 1;
          }
        }

        lineRest = lineResult.value.substring(stack.last.marker.offset);
        if (lineResult.value.codeUnitAt(markers.last.offset - 1) ==
            tabCodeUnit) {
          lineRest = ' ' * (4 - (markers.last.endIndent - 1) % 4) +
              lineRest; // TODO (4 - (startIndent & 3)) ???
        }
        isEmpty = isOnlyWhitespace(lineRest);

        if (isEmpty) {
          if (stack.isNotEmpty) {
            stack.addLine('');
          }
        }
      } else {
        lineRest = markers.isNotEmpty
            ? lineResult.value.substring(markers.last.offset)
            : lineResult.value;
        isEmpty = isOnlyWhitespace(lineRest);

        if (isEmpty) {
          if (stack.isNotEmpty) {
            stack.addLine('');
          }
        }
      }

      if (!isEmpty) {
        if (lazyLineMode >= 0) {
          // Treat line as lazy, and do not parse it.
          final String lazyLine = trimLeft(lineRest);
          while (stack.length - 1 >= lazyLineMode &&
              !stack.addLazyLine(lazyLine)) {
            stack.flush(stack.length - 1, result);
          }
          if (stack.length - 1 >= lazyLineMode) {
            // Lazy line was applied
            stack.setAfterEmpty(false);
            off = lineResult.offset;
            continue;
          }

          // Otherwise switching to strict mode.

          if (stack.isEmpty) {
            // But we can't apply strict line if stack is empty.
            // It is a separate block then.
            break;
          }
        }

        // Strict mode
        if (stack.last.unparsedContent == '\n\n') {
          // List item without content which follows empty line.
          // Remove that list item.

          stack.flush(stack.length - 1, result);

          if (stack.isEmpty) {
            break;
          }
        }

        // If contains tab for indented code line, then replace with spaces.
        final int startCodeIndent = stack.last.marker.endIndent;
        final String lineRestWithoutCodeIndent =
            removeIndent(lineRest, 4, false, startCodeIndent);
        if (lineRestWithoutCodeIndent != null) {
          lineRest = (' ' * 4) + lineRestWithoutCodeIndent;
        }

        // Adding line to stack
        stack..addLine(lineRest)..setAfterEmpty(false);
      }

      off = lineResult.offset;
    }

    if (stack.isNotEmpty) {
      stack.flush(0, result);
    }

    if (result.isEmpty) {
      return const ParseResult<BlockNodeImpl>.failure();
    }
    if (result.length == 1) {
      return new ParseResult<BlockNodeImpl>.success(result.single, off);
    }

    return new ParseResult<BlockNodeImpl>.success(
        new CombiningBlockNodeImpl(result), off);
  }
}
