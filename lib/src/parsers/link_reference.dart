library md_proc.src.parsers.link_reference;

import 'package:md_proc/definitions.dart';
import 'package:md_proc/src/code_units.dart';
import 'package:md_proc/src/parse_result.dart';
import 'package:md_proc/src/parsers/abstract.dart';
import 'package:md_proc/src/parsers/common.dart';
import 'package:md_proc/src/parsers/container.dart';

class LinkReference extends Block {
  String reference;
  String normalizedReference;
  Target target;

  LinkReference(this.reference, this.target) {
    normalizedReference = normalize(reference);
  }

  static String normalize(String s) => trimAndReplaceSpaces(s).toUpperCase();
}

/// Parser for link reference blocks.
class LinkReferenceParser extends AbstractParser<LinkReference> {
  /// Constructor.
  LinkReferenceParser(ParsersContainer container) : super(container);

  /// Regexp to check that we don't have empty line.
  static const String _notEmptyLineRegExp =
      r'(?:\r\n|\n|\r)(?![ \t]*(?:\r\n|\n|\r))';

  static final RegExp _labelAndLinkRegExp =
      new RegExp(r' {0,3}\[((?:[^\[\]\r\n]|\\\]|\\\[|' +
          _notEmptyLineRegExp +
          r')+)\]:' +
          // Space after label
          r'(?:[ \t]|' +
          _notEmptyLineRegExp +
          r')*' +
          // Link
          r'([^ \t\r\n]*)');

  static final RegExp _titleRegExp = new RegExp(r'(?:[ \t]|' +
      _notEmptyLineRegExp +
      r')+(' +
      r'"(?:[^"\\\r\n]|\\"|\\|' +
      _notEmptyLineRegExp +
      r')*"|' +
      r"'(?:[^'\\\r\n]|\\'|\\|" +
      _notEmptyLineRegExp +
      r")*'|" +
      r'\((?:[^)\\\r\n]|\\\)|\\|' +
      _notEmptyLineRegExp +
      r')*\)' +
      r')');

  static final RegExp _lineEndRegExp = new RegExp(r'[ \t]*(\r\n|\n|\r|$)');
  @override
  ParseResult<LinkReference> parse(String text, int offset) {
    final Match labelAndLinkMatch =
        _labelAndLinkRegExp.matchAsPrefix(text, offset);
    if (labelAndLinkMatch == null) {
      return new ParseResult<LinkReference>.failure();
    }

    final String label = LinkReference.normalize(labelAndLinkMatch[1]);
    if (label.length == 0) {
      // Label cannot be empty
      return new ParseResult<LinkReference>.failure();
    }

    String link = labelAndLinkMatch[2];
    if (link == '') {
      // Target cannot be empty
      return new ParseResult<LinkReference>.failure();
    }
    if (link.codeUnitAt(0) == lessThanCodeUnit) {
      final int linkLength = link.length;
      final int lastCodeUnit = link.codeUnitAt(linkLength - 1);
      final int beforeLastCodeUnit = linkLength >= 2 ?
        link.codeUnitAt(linkLength - 2) : 0;
      if (lastCodeUnit == greaterThanCodeUnit &&
          beforeLastCodeUnit != backslashCodeUnit) {
        link = link.substring(1, link.length - 1);
      }
    }
    link = unescapeAndUnreference(link);

    offset = labelAndLinkMatch.end;

    Match lineEndMatch = _lineEndRegExp.matchAsPrefix(text, offset);

    final int offsetAfterLink = lineEndMatch?.end ?? -1;

    // Trying title

    final Match titleMatch = _titleRegExp.matchAsPrefix(text, offset);

    String title;

    int offsetAfterTitle = -1;
    if (titleMatch != null) {
      title = titleMatch[1];
      if (title != null) {
        title = title.substring(1, title.length - 1);
        title = unescapeAndUnreference(title);
      }

      offset = titleMatch.end;

      lineEndMatch = _lineEndRegExp.matchAsPrefix(text, offset);

      offsetAfterTitle = lineEndMatch?.end ?? -1;
    }

    // Trying attributes

    Attr attributes = new EmptyAttr();
    int offsetAfterAttributes = -1;

    if (container.options.linkAttributes) {
      while (offset < text.length) {
        final int codeUnit = text.codeUnitAt(offset);
        if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
          break;
        }
        offset++;
      }
      if (offset < text.length &&
          text.codeUnitAt(offset) == openBraceCodeUnit) {
        final ParseResult<Attributes> attributesResult =
            container.attributesParser.parse(text, offset);
        if (attributesResult.isSuccess) {
          offset = attributesResult.offset;

          lineEndMatch = _lineEndRegExp.matchAsPrefix(text, offset);

          offsetAfterAttributes = lineEndMatch?.end ?? -1;
          if (lineEndMatch != null) {
            attributes = attributesResult.value;
          }
        }
      }
    }

    if (offsetAfterAttributes != -1) {
      return new ParseResult<LinkReference>.success(
          new LinkReference(label, new Target(link, title, attributes)),
          offsetAfterAttributes);
    }
    if (offsetAfterTitle != -1) {
      return new ParseResult<LinkReference>.success(
          new LinkReference(label, new Target(link, title, attributes)),
          offsetAfterTitle);
    }
    if (offsetAfterLink != -1) {
      return new ParseResult<LinkReference>.success(
          new LinkReference(label, new Target(link, null, new EmptyAttr())),
          offsetAfterLink);
    }

    return new ParseResult<LinkReference>.failure();
  }
}
