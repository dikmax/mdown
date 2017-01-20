library mdown.src.parsers.pipe_tables;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/ast/unparsed_inlines.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';
import 'package:mdown/src/parsers/line.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/code_units.dart';

/// Parser for pipe tables.
class PipeTablesParser extends AbstractParser<BlockNodeImpl> {
  /// Constructor.
  PipeTablesParser(ParsersContainer container) : super(container);

  @override
  ParseResult<BlockNodeImpl> parse(String text, int offset) {
    final ParseResult<String> firstLineResult =
        container.lineParser.parse(text, offset);
    assert(firstLineResult.isSuccess);
    final List<String> firstLineColumns =
        _splitToColumns(firstLineResult.value);
    offset = firstLineResult.offset;
    final int length = text.length;

    List<Alignment> alignment = _getAlignment(firstLineColumns);

    List<TableCell> headers;

    if (alignment == null) {
      // First line is probably a header.
      final ParseResult<String> secondLineResult =
          container.lineParser.parse(text, offset);
      if (!secondLineResult.isSuccess) {
        return new ParseResult<BlockNodeImpl>.failure();
      }

      offset = secondLineResult.offset;
      final List<String> secondLineColumns =
          _splitToColumns(secondLineResult.value);
      alignment = _getAlignment(secondLineColumns);
      if (alignment == null) {
        // No description here too.
        return new ParseResult<BlockNodeImpl>.failure();
      }

      headers = _parseRow(firstLineColumns);
      if (headers == null) {
        // No headers on first line.
        return new ParseResult<BlockNodeImpl>.failure();
      }
    }

    final List<List<TableCell>> cells = <List<TableCell>>[];
    // Parsing cells
    while (offset < length) {
      final ParseResult<String> lineResult =
          container.lineParser.parse(text, offset);
      if (!lineResult.isSuccess) {
        break;
      }

      if (isOnlyWhitespace(lineResult.value)) {
        break;
      }

      final List<String> columns = _splitToColumns(lineResult.value);
      final List<TableCellImpl> row = _parseRow(columns);
      if (row == null) {
        break;
      }

      cells.add(row);
      offset = lineResult.offset;
    }

    return new ParseResult<BlockNodeImpl>.success(
        new TableImpl(alignment, null, headers, cells), offset);
  }

  List<TableCellImpl> _parseRow(List<String> columns) {
    final List<TableCellImpl> result = <TableCellImpl>[];
    int start = 0;
    int end = columns.length;
    if (isOnlyWhitespace(columns.first)) {
      start = 1;
    }
    if (isOnlyWhitespace(columns.last)) {
      end = end - 1;
    }

    if (end - start < 1) {
      return null;
    }

    for (int i = start; i < end; i += 1) {
      final String columnString = columns[i];
      result.add(new TableCellImpl(<BlockNodeImpl>[
        new ParaImpl(new UnparsedInlinesImpl(columnString.trim()))
      ]));
    }

    return result;
  }

  List<String> _splitToColumns(String line) {
    final List<String> result = line.split('|');
    if (result[0].isNotEmpty) {
      final int indent = skipIndent(result[0], 0);
      if (indent > 0) {
        result[0] = result[0].substring(indent);
      }
    }
    return result;
  }

  List<Alignment> _getAlignment(List<String> columns) {
    if (columns.length < 2) {
      return null;
    }

    final List<Alignment> result = <Alignment>[];
    int start = 0;
    int end = columns.length;
    if (isOnlyWhitespace(columns.first)) {
      start = 1;
    }
    if (isOnlyWhitespace(columns.last)) {
      end = end - 1;
    }

    for (int i = start; i < end; i += 1) {
      final String columnString = columns[i];
      int columnStart = 0, columnEnd = columnString.length;
      Alignment align = Alignment.none;
      if (columnString.codeUnitAt(0) == colonCodeUnit) {
        columnStart = 1;
        if (columnString.codeUnitAt(columnEnd - 1) == colonCodeUnit) {
          align = Alignment.center;
          columnEnd -= 1;
        } else {
          align = Alignment.left;
        }
      } else if (columnString.codeUnitAt(columnEnd - 1) == colonCodeUnit) {
        align = Alignment.right;
        columnEnd -= 1;
      }

      if (columnEnd - columnStart < 1) {
        // There's no minuses. Columns like `|::|` are not allowed.
        return null;
      }

      for (int j = columnStart; j < columnEnd; j += 1) {
        if (columnString.codeUnitAt(j) != minusCodeUnit) {
          return null;
        }
      }

      result.add(align);
    }

    return result;
  }
}
