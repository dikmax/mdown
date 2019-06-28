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

  ParseResult<String> _parseDestination(String text, int offset) {
    int off = offset;
    final int length = text.length;

    if (off == length) {
      return const ParseResult<String>.failure();
    }

    if (text.codeUnitAt(offset) == lessThanCodeUnit) {
      // Parsing link in brackets.
      off++;
      while (off < length) {
        final int codeUnit = text.codeUnitAt(off);
        if (codeUnit == greaterThanCodeUnit) {
          off++;
          return new ParseResult<String>.success(
              text.substring(offset + 1, off - 1), off);
        }
        if (codeUnit == backslashCodeUnit) {
          // Escaped char
          off++;
          if (off == length) {
            break;
          }

          final int nextCodeUnit = text.codeUnitAt(off);
          if (nextCodeUnit == spaceCodeUnit ||
              nextCodeUnit == tabCodeUnit ||
              nextCodeUnit == newLineCodeUnit ||
              nextCodeUnit == carriageReturnCodeUnit) {
            break;
          }
        } else if (codeUnit == spaceCodeUnit ||
            codeUnit == tabCodeUnit ||
            codeUnit == newLineCodeUnit ||
            codeUnit == carriageReturnCodeUnit ||
            codeUnit == lessThanCodeUnit) {
          break;
        }
        off++;
      }
    }

    // Destination without < >.

    // Start from scratch
    off = offset;
    int parensDepth = 0;
    while (off < length) {
      final int codeUnit = text.codeUnitAt(off);
      if (codeUnit <= spaceCodeUnit) {
        // Space or control. Stop here.
        break;
      }
      if (codeUnit == backslashCodeUnit) {
        // Escaped char
        off++;
        if (off == length) {
          break;
        }

        final int nextCodeUnit = text.codeUnitAt(off);
        if (nextCodeUnit <= spaceCodeUnit) {
          break;
        }
      }
      if (codeUnit == openParenCodeUnit) {
        parensDepth++;
      } else if (codeUnit == closeParenCodeUnit) {
        if (parensDepth == 0) {
          break;
        }
        parensDepth--;
      }
      off++;
    }

    return new ParseResult<String>.success(text.substring(offset, off), off);
  }

  ParseResult<Target> _parseTarget(String text, int offset) {
    int off = offset;
    final int length = text.length;

    // Skip whitespace.
    while (off < length) {
      final int codeUnit = text.codeUnitAt(off);
      if (codeUnit != spaceCodeUnit &&
          codeUnit != tabCodeUnit &&
          codeUnit != newLineCodeUnit &&
          codeUnit != carriageReturnCodeUnit) {
        break;
      }
      off++;
    }
    if (off == length) {
      return const ParseResult<Target>.failure();
    }

    // Parsing href
    final ParseResult<String> destinationRes = _parseDestination(text, off);
    if (!destinationRes.isSuccess) {
      return const ParseResult<Target>.failure();
    }

    String href = destinationRes.value;
    /*
    final int hrefLength = href.length;
    if (hrefLength > 0 &&
        href.codeUnitAt(0) == lessThanCodeUnit &&
        href.codeUnitAt(hrefLength - 1) == greaterThanCodeUnit) {
      href = href.substring(1, hrefLength - 1);
    }
    */
    href = unescapeAndUnreference(href);

    off = destinationRes.offset;

    // Skip whitespace.
    while (off < length) {
      final int codeUnit = text.codeUnitAt(off);
      if (codeUnit != spaceCodeUnit &&
          codeUnit != tabCodeUnit &&
          codeUnit != newLineCodeUnit &&
          codeUnit != carriageReturnCodeUnit) {
        break;
      }
      off++;
    }
    if (off == length) {
      return const ParseResult<Target>.failure();
    }

    final TargetImpl result = astFactory.target(href, null);

    // Maybe parsing title.
    int codeUnit = text.codeUnitAt(off);
    if (codeUnit == singleQuoteCodeUnit ||
        codeUnit == doubleQuoteCodeUnit ||
        codeUnit == openParenCodeUnit) {
      final int endCodeUnit =
          codeUnit == openParenCodeUnit ? closeParenCodeUnit : codeUnit;
      off++;
      final int startOffset = off;
      while (off < length) {
        final int codeUnit = text.codeUnitAt(off);
        off++;
        if (codeUnit == backslashCodeUnit) {
          off++;
          continue;
        } else if (codeUnit == endCodeUnit) {
          break;
        } else if (codeUnit == openParenCodeUnit &&
            endCodeUnit == closeParenCodeUnit) {
          return const ParseResult<Target>.failure();
        }
      }

      if (off >= length) {
        return const ParseResult<Target>.failure();
      }

      String title = text.substring(startOffset, off - 1);
      title = unescapeAndUnreference(title);
      result.title = title;

      // Skip whitespace.
      // ignore: invariant_booleans
      while (off < length) {
        final int codeUnit = text.codeUnitAt(off);
        if (codeUnit != spaceCodeUnit &&
            codeUnit != tabCodeUnit &&
            codeUnit != newLineCodeUnit &&
            codeUnit != carriageReturnCodeUnit) {
          break;
        }
        off++;
      }
      if (off == length) {
        return const ParseResult<Target>.failure();
      }

      codeUnit = text.codeUnitAt(off);
    }

    if (codeUnit != closeParenCodeUnit) {
      return const ParseResult<Target>.failure();
    }

    off++;

    return new ParseResult<Target>.success(result, off);
  }

  // TODO reorder parse to put all fallbacks in the end.
  @override
  ParseResult<InlineNodeImpl> parse(String text, int offset) {
    int off = offset;
    final int length = text.length;
    bool isImage = false;
    if (text.codeUnitAt(off) == exclamationMarkCodeUnit) {
      off++;
      if (off == length) {
        return const ParseResult<InlineNodeImpl>.failure();
      }
      isImage = true;
    }
    if (text.codeUnitAt(off) != openBracketCodeUnit) {
      return const ParseResult<InlineNodeImpl>.failure();
    }
    off++;
    if (off == length) {
      return const ParseResult<InlineNodeImpl>.failure();
    }

    final int startOffset = off;
    int endOffset = -1;
    bool containsLink = false;
    final List<_LinkStackItem> stack = <_LinkStackItem>[
      new _LinkStackItem(off)
    ];
    while (off < length && (isImage || !containsLink)) {
      final int codeUnit = text.codeUnitAt(off);
      if (codeUnit == closeBracketCodeUnit) {
        final _LinkStackItem last = stack.removeLast(); // TODO check link.
        if (!isImage) {
          containsLink = last.containsLink;
          if (!containsLink && last.bracketLevel == 2) {
            // There could be link
            final List<InlineNodeImpl> labelInlines = container.documentParser
                .parseInlines(text.substring(last.offset, off));

            if (labelInlines.any((InlineNodeImpl node) => node.containsLink)) {
              containsLink = true;
            }
          }
        }

        if (stack.isEmpty) {
          endOffset = off;
          off++;
          break;
        }
        off++;
        continue;
      }
      if (codeUnit == backslashCodeUnit) {
        // Escaped char
        off += 2;
        if (off > length) {
          off = length;
          break;
        }
        continue;
      }
      if (codeUnit == openBracketCodeUnit) {
        for (int i = stack.length - 1, level = 2; i >= 0; i--, level++) {
          stack[i].bracketLevel = max(stack[i].bracketLevel, level);
        }
        off++;
        stack.add(new _LinkStackItem(off));
        continue;
      }

      if (_higherPriorityInlineParsers.containsKey(codeUnit)) {
        bool found = false;
        for (AbstractParser<InlineNodeImpl> parser
            in _higherPriorityInlineParsers[codeUnit]) {
          // TODO optimize to only return offset.
          // TODO check autolink
          final ParseResult<InlineNodeImpl> res = parser.parse(text, off);
          if (res.isSuccess) {
            off = res.offset;
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
          container.strParser.parse(text, off);
      assert(res.isSuccess);

      off = res.offset;
    }

    if (endOffset == -1) {
      return new ParseResult<InlineNodeImpl>.success(
          new StrImpl(isImage ? '![' : '['), startOffset);
    }

    if (isImage || !containsLink) {
      if (off != length) {
        // Test link in parens.
        final int codeUnit = text.codeUnitAt(off);
        if (codeUnit == openParenCodeUnit) {
          final ParseResult<Target> targetResult = _parseTarget(text, off + 1);
          if (targetResult.isSuccess) {
            final Target target = targetResult.value;

            // Normal link.
            final List<InlineNodeImpl> labelInlines = container.documentParser
                .parseInlines(text.substring(startOffset, endOffset));

            // Attributes (linkAttributes extensions).
            off = targetResult.offset;
            ExtendedAttributes attributes;
            if (container.options.linkAttributes) {
              if (off < length && text.codeUnitAt(off) == openBraceCodeUnit) {
                final ParseResult<Attributes> attributesResult =
                    container.attributesParser.parse(text, off);
                if (attributesResult.isSuccess) {
                  attributes = attributesResult.value;
                  off = attributesResult.offset;
                }
              }
            }

            final InlineNodeImpl result = isImage
                ? astFactory.inlineImage(labelInlines, target, attributes)
                : astFactory.inlineLink(labelInlines, target, attributes);
            return new ParseResult<InlineNodeImpl>.success(result, off);
          }
        }

        if (codeUnit == openBracketCodeUnit) {
          if (off + 1 < length &&
              text.codeUnitAt(off + 1) == closeBracketCodeUnit) {
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
              return new ParseResult<InlineNodeImpl>.success(result, off + 2);
            }
            return new ParseResult<InlineNodeImpl>.success(
                new StrImpl(isImage ? '![' : '['), startOffset);
          }

          // Full reference parsing
          final Match referenceMatch =
              _referenceRegExp.matchAsPrefix(text, off);
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
          return new ParseResult<InlineNodeImpl>.success(result, off);
        }
      }
    }

    return new ParseResult<InlineNodeImpl>.success(
        new StrImpl(isImage ? '![' : '['), startOffset);
  }
}
