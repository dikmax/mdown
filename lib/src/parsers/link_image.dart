library mdown.src.parsers.link_image;

import 'dart:collection';
import 'dart:math';

import 'package:mdown/ast/ast.dart';
import 'package:mdown/ast/standard_ast_factory.dart';
import 'package:mdown/src/ast/ast.dart';
import 'package:mdown/src/code_units.dart';
import 'package:mdown/src/parse_result.dart';
import 'package:mdown/src/parsers/abstract.dart';
import 'package:mdown/src/parsers/common.dart';
import 'package:mdown/src/parsers/container.dart';

class _LinkStackItem {
  int offset;
  int bracketLevel = 1;
  bool containsLink = false;

  _LinkStackItem(this.offset);
}

/// Parser for links and images.
class LinkImageParser extends AbstractParser<InlineNodeImpl> {
  static final RegExp _hrefRegExp = new RegExp(
      // Link in <>
      r'<(?:[^\\> \t\r\n]|\\.|\\)*>|'
      // Link without
      r'(?:[^ \t\r\n\(\)\\]+|\((?:[^ \t\r\n\(\)\\]|\\.|\\)*\)|\\.|\\)*');

  static final RegExp _referenceRegExp = new RegExp(r'\[((?:[^\]]|\\\])+)\]');

  Map<int, List<AbstractParser<InlineNodeImpl>>> _higherPriorityInlineParsers;

  /// Constructor.
  LinkImageParser(ParsersContainer container) : super(container);

  @override
  void init() {
    _higherPriorityInlineParsers =
        new HashMap<int, List<AbstractParser<InlineNodeImpl>>>();

    _higherPriorityInlineParsers[backtickCodeUnit] =
        <AbstractParser<InlineNodeImpl>>[container.inlineCodeParser];

    _higherPriorityInlineParsers[lessThanCodeUnit] =
        <AbstractParser<InlineNodeImpl>>[
      container.inlineHtmlParser,
      container.autolinkParser
    ];

    if (container.options.texMathDollars) {
      _higherPriorityInlineParsers[dollarCodeUnit] =
          <AbstractParser<InlineNodeImpl>>[container.texMathDollarsParser];
    }

    if (container.options.texMathSingleBackslash ||
        container.options.texMathDoubleBackslash) {
      _higherPriorityInlineParsers[backslashCodeUnit] =
          <AbstractParser<InlineNodeImpl>>[];

      if (container.options.texMathSingleBackslash) {
        _higherPriorityInlineParsers[backslashCodeUnit]
            .add(container.texMathSingleBackslashParser);
      }
      if (container.options.texMathDoubleBackslash) {
        _higherPriorityInlineParsers[backslashCodeUnit]
            .add(container.texMathDoubleBackslashParser);
      }
    }
  }

  ParseResult<Target> _parseTarget(String text, int offset) {
    final int length = text.length;

    // Skip whitespace.
    while (offset < length) {
      final int codeUnit = text.codeUnitAt(offset);
      if (codeUnit != spaceCodeUnit &&
          codeUnit != tabCodeUnit &&
          codeUnit != newLineCodeUnit &&
          codeUnit != carriageReturnCodeUnit) {
        break;
      }
      offset++;
    }
    if (offset == length) {
      return new ParseResult<Target>.failure();
    }

    // Parsing href
    final Match hrefMatch = _hrefRegExp.matchAsPrefix(text, offset);
    if (hrefMatch == null) {
      return new ParseResult<Target>.failure();
    }

    String href = hrefMatch[0];
    final int hrefLength = href.length;
    if (hrefLength > 0 &&
        href.codeUnitAt(0) == lessThanCodeUnit &&
        href.codeUnitAt(hrefLength - 1) == greaterThanCodeUnit) {
      href = href.substring(1, href.length - 1);
    }
    href = unescapeAndUnreference(href);

    offset = hrefMatch.end;

    // Skip whitespace.
    while (offset < length) {
      final int codeUnit = text.codeUnitAt(offset);
      if (codeUnit != spaceCodeUnit &&
          codeUnit != tabCodeUnit &&
          codeUnit != newLineCodeUnit &&
          codeUnit != carriageReturnCodeUnit) {
        break;
      }
      offset++;
    }
    if (offset == length) {
      return new ParseResult<Target>.failure();
    }

    final TargetImpl result =
        astFactory.target(astFactory.targetLink(href), null);

    // Maybe parsing title.
    int codeUnit = text.codeUnitAt(offset);
    if (codeUnit == singleQuoteCodeUnit ||
        codeUnit == doubleQuoteCodeUnit ||
        codeUnit == openParenCodeUnit) {
      final int endCodeUnit =
          codeUnit == openParenCodeUnit ? closeParenCodeUnit : codeUnit;
      offset++;
      final int startOffset = offset;
      while (offset < length) {
        final int codeUnit = text.codeUnitAt(offset);
        offset++;
        if (codeUnit == backslashCodeUnit) {
          offset++;
          continue;
        } else if (codeUnit == endCodeUnit) {
          break;
        } else if (codeUnit == openParenCodeUnit &&
            endCodeUnit == closeParenCodeUnit) {
          return new ParseResult<Target>.failure();
        }
      }

      if (offset >= length) {
        return new ParseResult<Target>.failure();
      }

      String title = text.substring(startOffset, offset - 1);
      title = unescapeAndUnreference(title);
      result.title = astFactory.targetTitle(title);

      // Skip whitespace.
      while (offset < length) {
        final int codeUnit = text.codeUnitAt(offset);
        if (codeUnit != spaceCodeUnit &&
            codeUnit != tabCodeUnit &&
            codeUnit != newLineCodeUnit &&
            codeUnit != carriageReturnCodeUnit) {
          break;
        }
        offset++;
      }
      if (offset == length) {
        return new ParseResult<Target>.failure();
      }

      codeUnit = text.codeUnitAt(offset);
    }

    if (codeUnit != closeParenCodeUnit) {
      return new ParseResult<Target>.failure();
    }

    offset++;

    return new ParseResult<Target>.success(result, offset);
  }

  // TODO reorder parse to put all fallbacks in the end.
  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    final int length = text.length;
    bool isImage = false;
    if (text.codeUnitAt(offset) == exclamationMarkCodeUnit) {
      offset++;
      if (offset == length) {
        return new ParseResult<InlineNodeImpl>.failure();
      }
      isImage = true;
    }
    if (text.codeUnitAt(offset) != openBracketCodeUnit) {
      return new ParseResult<InlineNodeImpl>.failure();
    }
    offset++;
    if (offset == length) {
      return new ParseResult<InlineNodeImpl>.failure();
    }

    final int startOffset = offset;
    int endOffset = -1;
    bool containsLink = false;
    final List<_LinkStackItem> stack = <_LinkStackItem>[
      new _LinkStackItem(offset)
    ];
    while (offset < length && (isImage || !containsLink)) {
      final int codeUnit = text.codeUnitAt(offset);
      if (codeUnit == closeBracketCodeUnit) {
        final _LinkStackItem last = stack.removeLast(); // TODO check link.
        if (!isImage) {
          containsLink = last.containsLink;
          if (!containsLink && last.bracketLevel == 2) {
            // There could be link
            final List<InlineNodeImpl> labelInlines = container.documentParser
                .parseInlines(text.substring(last.offset, offset));

            if (labelInlines.any((InlineNodeImpl node) => node.containsLink)) {
              containsLink = true;
            }
          }
        }

        if (stack.isEmpty) {
          endOffset = offset;
          offset++;
          break;
        }
        offset++;
        continue;
      }
      if (codeUnit == backslashCodeUnit) {
        // Escaped char
        offset += 2;
        if (offset > length) {
          offset == length;
          break;
        }
        continue;
      }
      if (codeUnit == openBracketCodeUnit) {
        for (int i = stack.length - 1, level = 2; i >= 0; i--, level++) {
          stack[i].bracketLevel = max(stack[i].bracketLevel, level);
        }
        offset++;
        stack.add(new _LinkStackItem(offset));
        continue;
      }

      if (_higherPriorityInlineParsers.containsKey(codeUnit)) {
        bool found = false;
        for (AbstractParser<InlineNodeImpl> parser
            in _higherPriorityInlineParsers[codeUnit]) {
          // TODO optimize to only return offset.
          // TODO check autolink
          final ParseResult<InlineNodeImpl> res = parser.parse(text, offset);
          if (res.isSuccess) {
            offset = res.offset;
            if (!isImage && res.value.containsLink) {
              containsLink = true;
            }
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

      offset = res.offset;
    }

    if (endOffset == -1) {
      return new ParseResult<InlineNodeImpl>.success(
          new StrImpl(isImage ? '![' : '['), startOffset);
    }

    if (isImage || !containsLink) {
      if (offset != length) {
        // Test link in parens.
        final int codeUnit = text.codeUnitAt(offset);
        if (codeUnit == openParenCodeUnit) {
          final ParseResult<Target> targetResult =
              _parseTarget(text, offset + 1);
          if (targetResult.isSuccess) {
            final Target target = targetResult.value;

            // Normal link.
            final List<InlineNodeImpl> labelInlines = container.documentParser
                .parseInlines(text.substring(startOffset, endOffset));

            // Attributes (linkAttributes extensions).
            offset = targetResult.offset;
            ExtendedAttributes attributes;
            if (container.options.linkAttributes) {
              if (offset < length &&
                  text.codeUnitAt(offset) == openBraceCodeUnit) {
                final ParseResult<Attributes> attributesResult =
                    container.attributesParser.parse(text, offset);
                if (attributesResult.isSuccess) {
                  attributes = attributesResult.value;
                  offset = attributesResult.offset;
                }
              }
            }

            final InlineNodeImpl result = isImage
                ? astFactory.inlineImage(labelInlines, target, attributes)
                : astFactory.inlineLink(labelInlines, target, attributes);
            return new ParseResult<InlineNodeImpl>.success(result, offset);
          }
        }

        if (codeUnit == openBracketCodeUnit) {
          if (offset + 1 < length &&
              text.codeUnitAt(offset + 1) == closeBracketCodeUnit) {
            // Collapsed reference.
            final String referenceString =
                text.substring(startOffset, endOffset);
            final String normalizedReference =
                normalizeReference(referenceString);
            Target target;
            ExtendedAttributes attributes;
            if (container.references.containsKey(normalizedReference)) {
              final LinkReference linkReference =
                  container.references[normalizedReference];
              target = linkReference.target;
              attributes = linkReference.attributes;
            } else {
              target = container.options
                  .linkResolver(normalizedReference, referenceString);
            }

            if (target != null) {
              final List<InlineNodeImpl> labelInlines = container.documentParser
                  .parseInlines(text.substring(startOffset, endOffset));
              final Reference reference =
                  astFactory.reference(referenceString, target);

              final InlineNode result = isImage
                  ? astFactory.referenceImage(
                      labelInlines, reference, attributes)
                  : astFactory.referenceLink(
                      labelInlines, reference, attributes);
              return new ParseResult<InlineNodeImpl>.success(
                  result, offset + 2);
            }
            return new ParseResult<InlineNodeImpl>.success(
                new StrImpl(isImage ? '![' : '['), startOffset);
          }

          // Full reference parsing
          final Match referenceMatch =
              _referenceRegExp.matchAsPrefix(text, offset);
          if (referenceMatch != null) {
            final String referenceString = referenceMatch[1];
            final String normalizedReference =
                normalizeReference(referenceString);

            Target target;
            ExtendedAttributes attributes;

            if (container.references.containsKey(normalizedReference)) {
              final LinkReference linkReference =
                  container.references[normalizedReference];
              target = linkReference.target;
              attributes = linkReference.attributes;
            } else {
              target = container.options
                  .linkResolver(normalizedReference, referenceString);
            }
            if (target != null) {
              final List<InlineNodeImpl> labelInlines = container.documentParser
                  .parseInlines(text.substring(startOffset, endOffset));

              final Reference reference =
                  astFactory.reference(referenceString, target);
              final InlineNode result = isImage
                  ? astFactory.referenceImage(
                      labelInlines, reference, attributes)
                  : astFactory.referenceLink(
                      labelInlines, reference, attributes);

              return new ParseResult<InlineNodeImpl>.success(
                  result, referenceMatch.end);
            }
          }

          return new ParseResult<InlineNodeImpl>.success(
              new StrImpl(isImage ? '![' : '['), startOffset);
        }
      }

      // Not followed by `(` or `[`
      // It's a shortcut reference link

      // Found variant

      final String referenceString = text.substring(startOffset, endOffset);
      final String normalizedReference = normalizeReference(referenceString);

      // Shortcut reference.
      if (normalizedReference != '') {
        Target target;
        ExtendedAttributes attributes;

        if (container.references.containsKey(normalizedReference)) {
          final LinkReference linkReference =
              container.references[normalizedReference];
          target = linkReference.target;
          attributes = linkReference.attributes;
        } else {
          target = container.options
              .linkResolver(normalizedReference, referenceString);
        }
        if (target != null) {
          final List<InlineNodeImpl> labelInlines = container.documentParser
              .parseInlines(text.substring(startOffset, endOffset));
          final Reference reference =
              astFactory.reference(referenceString, target);

          final InlineNode result = isImage
              ? astFactory.referenceImage(labelInlines, reference, attributes)
              : astFactory.referenceLink(labelInlines, reference, attributes);
          return new ParseResult<InlineNodeImpl>.success(result, offset);
        }
      }
    }

    return new ParseResult<InlineNodeImpl>.success(
        new StrImpl(isImage ? '![' : '['), startOffset);
  }
}
