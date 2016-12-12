library md_proc.src.parsers.blockquote_list;

import 'dart:collection';
import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/inlines.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/common.dart';
import 'package:md_proc/src/parsers/container.dart';
import 'package:md_proc/src/parsers/link_reference.dart';

// Stack

class _StackItem {
  String unparsedContent = '';
  _ExtendedBlock block;
  _Marker marker;
  AbstractParser<Iterable<Block>> innerBlocksParser;
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

    final ParseResult<Iterable<Block>> result =
        innerBlocksParser.parse(unparsedContent, 0);
    assert(result.isSuccess);

    Iterable<Block> blocks = result.value;
    final bool endsWithBlankline = blocks.last == null;

    while (blocks.length > 0 && blocks.last == null) {
      final List<Block> b = blocks;
      b.removeLast();
    }

    if (!marker.isBlockquote && blocks.length > 0 && block is ListBlock) {
      final ListBlock listBlock = block as ListBlock;

      if (listBlock.items.length > 0 &&
          listBlock.items.last.contents.length == 0 &&
          blocks.elementAt(0) == null) {
        blocks = blocks.skip(1);
      }
      if (blocks.contains(null)) {
        listBlock.tight = false;
      }
    }

    blocks = blocks.where(_isNotBlockALinkReference);

    final Block last = block.last;
    if (!this.afterEmpty && last is Para && blocks.first is Para) {
      // Merge paragraph.
      final UnparsedInlines inlines = last.contents;
      final Para para = blocks.first;
      final UnparsedInlines inlines2 = para.contents;
      inlines.raw += '\n' + inlines2.raw;
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
    final Block last = block.last;
    if (last != null && last is Para) {
      if (thematicBreakTest.hasMatch(line) ||
          atxHeadingTest.hasMatch(line) ||
          fencedCodeStartTest.hasMatch(line)) {
        // TODO add html block and link reference test
        return false;
      }
      final UnparsedInlines contents = last.contents;
      contents.raw += '\n' + line;
      return true;
    }

    return false;
  }

  void setTight(bool tight) {
    if (!marker.isBlockquote) {
      final ListBlock listBlock = block as ListBlock;
      listBlock.tight = tight;
    }
  }

  static bool _isNotBlockALinkReference(Block block) =>
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
    if (_stack.length > 0) {
      _stack.last.parse();
    }

    _stack.add(element);
  }

  @override
  void addAll(Iterable<_StackItem> all) {
    if (_stack.length > 0) {
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
    assert(_stack.length > 0);

    _stack.last.addItem(marker);
  }

  void addLine(String line) {
    assert(_stack.length > 0);

    _stack.last.addLine(line);
  }

  bool addLazyLine(String line) {
    assert(_stack.length > 0);

    return _stack.last.addLazyLine(line);
  }

  /// Parsing all unparsed blocks and reducing stack size to [length].
  /// Returns last removed block.
  void flush(int length, List<Block> result) {
    while (this.length > length) {
      // If flushed block ends with empty line we need to shift
      // this line one level up.
      final bool moveBlankLineUp = last.parse();

      final Block lastBlock = last.block;
      removeLast();

      if (this.length > 0) {
        last.block.addToEnd(<Block>[lastBlock]);
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
    assert(_stack.length > 0);

    _stack.last.setTight(tight);
  }
}

// Markers

abstract class _ExtendedBlock extends Block {
  void addToEnd(Iterable<Block> blocks);
  void addItem();
  Block get last;
}

class _ExtendedBlockquote extends Blockquote implements _ExtendedBlock {
  _ExtendedBlockquote(Iterable<Block> contents) : super(contents);

  @override
  void addToEnd(Iterable<Block> blocks) {
    final List<Block> c = contents;

    c.addAll(blocks);
  }

  @override
  void addItem() {}

  @override
  Block get last => contents.length == 0 ? null : contents.last;
}

class _ExtendedOrderedList extends OrderedList implements _ExtendedBlock {
  _ExtendedOrderedList(Iterable<ListItem> items,
      {bool tight: false,
      IndexSeparator indexSeparator: IndexSeparator.dot,
      int startIndex: 1})
      : super(items,
            tight: tight,
            indexSeparator: indexSeparator,
            startIndex: startIndex);

  @override
  void addToEnd(Iterable<Block> blocks) {
    assert(items.length != 0);

    final ListItem item = items.last;

    final List<Block> c = item.contents;
    c.addAll(blocks);
  }

  @override
  void addItem() {
    assert(this.items.length != 0);

    final List<ListItem> items = this.items;

    items.add(new ListItem(<Block>[]));
  }

  @override
  Block get last => items.length == 0
      ? null
      : (items.last.contents.length == 0 ? null : items.last.contents.last);
}

class _ExtendedUnorderedList extends UnorderedList implements _ExtendedBlock {
  _ExtendedUnorderedList(Iterable<ListItem> items,
      {BulletType bulletType: BulletType.minus, bool tight: false})
      : super(items, tight: tight, bulletType: bulletType);

  @override
  void addToEnd(Iterable<Block> blocks) {
    assert(items.length != 0);

    final ListItem item = items.last;

    final List<Block> c = item.contents;

    c.addAll(blocks);
  }

  @override
  void addItem() {
    assert(this.items.length != 0);

    final List<ListItem> items = this.items;

    items.add(new ListItem(<Block>[]));
  }

  @override
  Block get last => items.length == 0
      ? null
      : (items.last.contents.length == 0 ? null : items.last.contents.last);
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

  _ExtendedBlock createBlock([Iterable<Block> contents]);

  bool isSame(_Marker marker);
}

class _BlockquoteMarker extends _Marker {
  _BlockquoteMarker(int startIndent, int endIndent, int offset)
      : super(startIndent, endIndent, offset, true);

  @override
  _ExtendedBlock createBlock([Iterable<Block> contents]) {
    return new _ExtendedBlockquote(contents ?? <Block>[]);
  }

  @override
  bool isSame(_Marker marker) => marker.isBlockquote;
}

class _UnorderedListMarker extends _Marker {
  BulletType bullet;

  _UnorderedListMarker(this.bullet, int startIndent, int endIndent, int offset)
      : super(startIndent, endIndent, offset, false);

  @override
  _ExtendedBlock createBlock([Iterable<Block> contents]) {
    final List<ListItem> items = <ListItem>[
      new ListItem(contents ?? <Block>[])
    ];
    return new _ExtendedUnorderedList(items, bulletType: bullet, tight: true);
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
  _ExtendedBlock createBlock([Iterable<Block> contents]) {
    final List<ListItem> items = <ListItem>[
      new ListItem(contents ?? <Block>[])
    ];

    return new _ExtendedOrderedList(items,
        indexSeparator: indexSeparator, startIndex: startIndex, tight: true);
  }

  @override
  bool isSame(_Marker marker) {
    return marker is _OrderedListMarker &&
        marker.indexSeparator == indexSeparator;
  }
}

// Parser

class _InnerBlocksParser extends AbstractParser<Iterable<Block>> {
  Map<int, List<AbstractParser<Iterable<Block>>>> _blockParsers;

  _InnerBlocksParser(ParsersContainer container) : super(container);

  @override
  void init() {
    _blockParsers = new HashMap<int, List<AbstractParser<Iterable<Block>>>>();

    for (int char in <int>[starCodeUnit, minusCodeUnit, underscoreCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.thematicBreakParser
      ];
    }

    _blockParsers[sharpCodeUnit] = <AbstractParser<Iterable<Block>>>[
      container.atxHeadingParser
    ];

    for (int char in <int>[spaceCodeUnit, tabCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.indentedCodeParser
      ];
    }

    for (int char in <int>[tildeCodeUnit, backtickCodeUnit]) {
      _blockParsers[char] = <AbstractParser<Iterable<Block>>>[
        container.fencedCodeParser
      ];
    }

    if (container.options.rawHtml) {
      _blockParsers[lessThanCodeUnit] = <AbstractParser<Iterable<Block>>>[
        container.htmlBlockParser,
        container.htmlBlock7Parser
      ];
    }

    if (container.options.rawTex) {
      _blockParsers[backslashCodeUnit] = <AbstractParser<Iterable<Block>>>[
        container.rawTexParser
      ];
    }
  }

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    int offset = 0;
    final List<Block> blocks = <Block>[];

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
        final ParseResult<LinkReference> res =
            container.linkReferenceParser.parse(text, offset);
        if (res.isSuccess) {
          if (!container.references.containsKey(res.value.reference)) {
            container.references[res.value.reference] = res.value.target;
          }
          blocks.add(res.value);
          offset = res.offset;
          continue;
        }
      } else if (firstChar == spaceCodeUnit ||
          firstChar == tabCodeUnit ||
          firstChar == newLineCodeUnit ||
          firstChar == carriageReturnCodeUnit) {
        final ParseResult<Iterable<Block>> res =
            container.blanklineParser.parse(text, offset);

        if (res.isSuccess) {
          blocks.add(null);
          offset = res.offset;
          continue;
        }
      }
      if (_blockParsers.containsKey(firstChar)) {
        bool found = false;
        for (AbstractParser<Iterable<Block>> parser
            in _blockParsers[firstChar]) {
          final ParseResult<Iterable<Block>> res = parser.parse(text, offset);
          if (res.isSuccess) {
            if (res.value.length > 0) {
              blocks.addAll(res.value);
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

      final ParseResult<Iterable<Block>> res =
          container.paraSetextHeadingParser.parse(text, offset);
      assert(res.isSuccess);

      if (res.value.length > 0) {
        blocks.addAll(res.value);
      }
      offset = res.offset;
    }

    return new ParseResult<Iterable<Block>>.success(blocks, offset);
  }
}

/// Parser for blockquotes and lists.
class BlockquoteListParser extends AbstractParser<Iterable<Block>> {
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
          BulletType.fromChar(marker), start, end, offset);
    }

    final IndexSeparator indexSeparator =
        IndexSeparator.fromChar(marker[marker.length - 1]);
    final int startIndex = int.parse(marker.substring(0, marker.length - 1));
    return new _OrderedListMarker(
        indexSeparator, startIndex, start, end, offset);
  }

  List<_Marker> _getMarkers(String line, [int indent = 0, int offset = 0]) {
    final List<_Marker> result = <_Marker>[];

    final int length = line.length;
    while (offset < length) {
      while (offset < length) {
        final int codeUnit = line.codeUnitAt(offset);
        if (codeUnit == spaceCodeUnit) {
          indent++;
          offset++;
        } else if (codeUnit == tabCodeUnit) {
          indent = ((indent >> 2) + 1) << 2; // (indent / 4 + 1) * 4
          offset++;
        } else {
          break;
        }
      }

      if (offset == length) {
        break;
      }

      final Match match = _markerRegExp.matchAsPrefix(line, offset);
      if (match == null) {
        if (result.length > 0) {
          // Blocks indent should counted from first block indent, but
          // only if it not exceeds 3 spaces.
          if (indent < result.last.endIndent + 4) {
            result.last.endIndent = indent;
          }
        }
        break; // No Marker found.
      }

      offset = match.end;
      final int startIndent = indent;
      final String markerString = match[0];
      indent += markerString.length;
      if (offset < length) {
        final int codeUnit = line.codeUnitAt(offset);
        if (codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit) {
          result.add(_markerFromString(
              markerString, startIndent, indent + 1, offset + 1));
          if (codeUnit == spaceCodeUnit) {
            indent++;
            offset++;
          } else {
            indent = ((indent >> 2) + 1) << 2; // (indent / 4 + 1) * 4
            offset++;
          }
        } else if (markerString == '>') {
          result.add(new _BlockquoteMarker(startIndent, indent + 1, offset));
        } else {
          // Can't be a marker
          break;
        }
      } else {
        result.add(
            _markerFromString(markerString, startIndent, indent + 1, offset));
        break;
      }
    }

    return result;
  }

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    final _Stack stack = new _Stack();
    final List<Block> result = <Block>[];

    final int length = text.length;
    while (offset < length) {
      final ParseResult<String> lineResult =
          container.lineParser.parse(text, offset);
      assert(lineResult.isSuccess);

      Iterable<_Marker> markers = _getMarkers(lineResult.value, 0, 0);

      if (markers.length == 0 && stack.length == 0) {
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

      /// Rightmost blockquote marker. We need it to proper empty line calculations.
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
          final Match match = thematicBreakTest.firstMatch(thematicTest);
          if (match != null && match[1].length < stack.last.marker.endIndent) {
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

      if (markers.length == 0 && stack.length == 0) {
        // No marker found and we at the top.
        // Most likely thematic break had broke parsing.
        break;
      }

      String lineRest;
      bool isEmpty;

      if (stackIndex < stack.length) {
        // Going through rest of stack. Cases 3 and 7.

        lineRest = markers.length > 0
            ? lineResult.value.substring(markers.last.offset)
            : lineResult.value;
        isEmpty = emptyLineRegExp.hasMatch(lineRest);

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
              stack.setAfterEmpty(true, blockquoteIndex + 1);
              stack.addLine('');
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
          if (stack.length > 0) {
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
          final Match match = thematicBreakTest.firstMatch(thematicTest);
          if (match != null && match[1].length < stack.last.marker.endIndent) {
            // This line should be treated as standalone thematic break.
            break;
          }

          if (marker.startIndent >= indent + 4) {
            break;
          }

          if (stack.length > 0 && stack.last.afterEmpty) {
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
        isEmpty = emptyLineRegExp.hasMatch(lineRest);

        if (isEmpty) {
          if (stack.length > 0) {
            stack.addLine('');
          }
        }
      } else {
        lineRest = markers.length > 0
            ? lineResult.value.substring(markers.last.offset)
            : lineResult.value;
        isEmpty = emptyLineRegExp.hasMatch(lineRest);

        if (isEmpty) {
          if (stack.length > 0) {
            stack.addLine('');
          }
        }
      }

      if (!isEmpty) {
        if (lazyLineMode >= 0) {
          // Treat line as lazy, and do not parse it.
          final String lazyLine = lineRest.trimLeft(); // TODO to not trim nbsp.
          while (stack.length - 1 >= lazyLineMode &&
              !stack.addLazyLine(lazyLine)) {
            stack.flush(stack.length - 1, result);
          }
          if (stack.length - 1 >= lazyLineMode) {
            // Lazy line was applied
            stack.setAfterEmpty(false);
            offset = lineResult.offset;
            continue;
          }

          // Otherwise switching to strict mode.

          if (stack.length == 0) {
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

          if (stack.length == 0) {
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
        stack.addLine(lineRest);

        stack.setAfterEmpty(false);
      }

      offset = lineResult.offset;
    }

    if (stack.isNotEmpty) {
      stack.flush(0, result);
    }

    if (result.isEmpty) {
      return const ParseResult<Iterable<Block>>.failure();
    }

    return new ParseResult<Iterable<Block>>.success(result, offset);
  }
}
