library md_proc.src.parsers.attributes;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/container.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:quiver/collection.dart';

/// Parser for extended attiributes.
class AttributesParser extends AbstractParser<Attributes> {
  /// Constructor.
  AttributesParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Attributes> parse(String text, int offset) {
    if (text.codeUnitAt(offset) != openBraceCodeUnit) {
      return new ParseResult<Attributes>.failure();
    }

    offset++;

    String id;
    final List<String> classes = <String>[];
    final Multimap<String, String> attributes = new Multimap<String, String>();

    final int length = text.length;
    while (offset < length) {
      final int codeUnit = text.codeUnitAt(offset);

      if (codeUnit == closeBraceCodeUnit) {
        offset++;
        break;
      }

      switch (codeUnit) {
        case sharpCodeUnit:
          // Id
          final int endOffset = _parseIdentifier(text, offset);
          id = text.substring(offset + 1, endOffset);
          offset = endOffset;
          break;

        case dotCodeUnit:
          // Id
          final int endOffset = _parseIdentifier(text, offset);
          classes.add(text.substring(offset + 1, endOffset));
          offset = endOffset;
          break;

        case spaceCodeUnit:
        case tabCodeUnit:
        case newLineCodeUnit:
        case carriageReturnCodeUnit:
          offset++;
          break;

        default:
          final int endOffset = _parseAttribute(text, offset, attributes);
          if (endOffset == offset) {
            return new ParseResult<Attributes>.failure();
          }
          offset = endOffset;

          break;
      }
    }

    return new ParseResult<Attributes>.success(
        new Attributes(id, classes, attributes), offset);
  }

  int _parseIdentifier(String text, int offset) {
    int endOffset = offset + 1;
    final int length = text.length;

    while (endOffset < length) {
      final int codeUnit = text.codeUnitAt(endOffset);

      if (codeUnit == spaceCodeUnit ||
          codeUnit == tabCodeUnit ||
          codeUnit == newLineCodeUnit ||
          codeUnit == carriageReturnCodeUnit ||
          codeUnit == closeBraceCodeUnit ||
          codeUnit == equalCodeUnit ||
          codeUnit == sharpCodeUnit ||
          codeUnit == dotCodeUnit) {
        break;
      }

      endOffset++;
    }

    return endOffset;
  }

  static final RegExp _keyValueRegExp =
      new RegExp('([a-zA-Z0-9_\-]+)=([^ "\'\t}][^ \t}]*|"[^"]*"|\'[^\']*\')');

  int _parseAttribute(
      String text, int offset, Multimap<String, String> attributes) {
    final Match match = _keyValueRegExp.matchAsPrefix(text, offset);
    if (match == null) {
      return offset;
    }

    final String key = match[1];
    String value = match[2];
    final int startCodeUnit = value.codeUnitAt(0);
    if (startCodeUnit == singleQuoteCodeUnit ||
        startCodeUnit == doubleQuoteCodeUnit) {
      value = value.substring(1, value.length - 1);
    }

    attributes.add(key, value);

    return match.end;
  }
}
