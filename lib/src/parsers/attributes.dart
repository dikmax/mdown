library mdown.src.parsers.attributes;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/standard_ast_factory.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/container.dart';

/// Parser for extended attiributes.
class ExtendedAttributesParser extends AbstractStringParser<Attributes> {
  /// Constructor.
  ExtendedAttributesParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Attributes> parse(String text, int offset) {
    if (text.codeUnitAt(offset) != openBraceCodeUnit) {
      return new ParseResult<Attributes>.failure();
    }

    offset++;

    final List<Attribute> attributes = <Attribute>[];

    /*
    String id;
    final List<String> classes = <String>[];
    final Multimap<String, String> attributes = new Multimap<String, String>();
    */

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
          attributes.add(astFactory
              .identifierAttribute(text.substring(offset + 1, endOffset)));
          offset = endOffset;
          break;

        case dotCodeUnit:
          // Id
          final int endOffset = _parseIdentifier(text, offset);
          attributes.add(
              astFactory.classAttribute(text.substring(offset + 1, endOffset)));
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
        astFactory.extendedAttributes(attributes), offset);
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

  int _parseAttribute(String text, int offset, List<Attribute> attributes) {
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

    attributes.add(astFactory.keyValueAttribute(key, value));

    return match.end;
  }
}
