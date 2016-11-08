part of md_proc.src.parsers;

class _LinkStackItem {
  int offset;
  int bracketLevel = 1;
  bool containsLink = false;

  _LinkStackItem(this.offset);
}

/// Parser for links and images.
class LinkImageParser extends AbstractParser<Inlines> {
  static final RegExp _hrefRegExp = new RegExp(
      // Link in <>
      r'<(?:[^\\> \t\r\n]|\\.|\\)*>|'
      // Link without
      r'(?:[^ \t\r\n\(\)\\]+|\((?:[^ \t\r\n\(\)\\]|\\.|\\)*\)|\\.|\\)*');

  static final RegExp _referenceRegExp = new RegExp(r'\[((?:[^\]]|\\\])+)\]');

  Map<int, List<AbstractParser<Iterable<Inline>>>> _higherPriorityInlineParsers;

  /// Constructor.
  LinkImageParser(ParsersContainer container) : super(container);

  @override
  void init() {
    _higherPriorityInlineParsers =
        new HashMap<int, List<AbstractParser<Iterable<Inline>>>>();

    _higherPriorityInlineParsers[_backtickCodeUnit] =
        <AbstractParser<Iterable<Inline>>>[container.inlineCodeParser];

    _higherPriorityInlineParsers[_lessThanCodeUnit] =
        <AbstractParser<Iterable<Inline>>>[
      container.inlineHtmlParser,
      container.autolinkParser
    ];

    if (container.options.texMathDollars) {
      _higherPriorityInlineParsers[_dollarCodeUnit] =
          <AbstractParser<Iterable<Inline>>>[container.texMathDollarsParser];
    }

    if (container.options.texMathSingleBackslash ||
        container.options.texMathDoubleBackslash) {
      _higherPriorityInlineParsers[_backslashCodeUnit] =
          <AbstractParser<Iterable<Inline>>>[];

      if (container.options.texMathSingleBackslash) {
        _higherPriorityInlineParsers[_backslashCodeUnit]
            .add(container.texMathSingleBackslashParser);
      }
      if (container.options.texMathDoubleBackslash) {
        _higherPriorityInlineParsers[_backslashCodeUnit]
            .add(container.texMathDoubleBackslashParser);
      }
    }
  }

  ParseResult<Target> _parseTarget(String text, int offset) {
    int length = text.length;

    // Skip whitespace.
    while (offset < length) {
      int codeUnit = text.codeUnitAt(offset);
      if (codeUnit != _spaceCodeUnit &&
          codeUnit != _tabCodeUnit &&
          codeUnit != _newLineCodeUnit &&
          codeUnit != _carriageReturnCodeUnit) {
        break;
      }
      offset++;
    }
    if (offset == length) {
      return new ParseResult<Target>.failure();
    }

    // Parsing href
    Match hrefMatch = _hrefRegExp.matchAsPrefix(text, offset);
    if (hrefMatch == null) {
      return new ParseResult<Target>.failure();
    }

    String href = hrefMatch[0];
    href = unescapeAndUnreference(href);
    if (href.startsWith('<') && href.endsWith('>')) {
      href = href.substring(1, href.length - 1);
    }

    offset = hrefMatch.end;

    // Skip whitespace.
    while (offset < length) {
      int codeUnit = text.codeUnitAt(offset);
      if (codeUnit != _spaceCodeUnit &&
          codeUnit != _tabCodeUnit &&
          codeUnit != _newLineCodeUnit &&
          codeUnit != _carriageReturnCodeUnit) {
        break;
      }
      offset++;
    }
    if (offset == length) {
      return new ParseResult<Target>.failure();
    }

    Target result = new Target(href, null);

    // Maybe parsing title.
    int codeUnit = text.codeUnitAt(offset);
    if (codeUnit == _singleQuoteCodeUnit ||
        codeUnit == _doubleQuoteCodeUnit ||
        codeUnit == _openParenCodeUnit) {
      int endCodeUnit =
          codeUnit == _openParenCodeUnit ? _closeParenCodeUnit : codeUnit;
      offset++;
      int startOffset = offset;
      while (offset < length) {
        int codeUnit = text.codeUnitAt(offset);
        offset++;
        if (codeUnit == _backslashCodeUnit) {
          offset++;
          continue;
        } else if (codeUnit == endCodeUnit) {
          break;
        } else if (codeUnit == _openParenCodeUnit && endCodeUnit == _closeParenCodeUnit) {
          return new ParseResult<Target>.failure();
        }
      }

      if (offset >= length) {
        return new ParseResult<Target>.failure();
      }

      String title = text.substring(startOffset, offset - 1);
      title = unescapeAndUnreference(title);
      result.title = title;

      // Skip whitespace.
      while (offset < length) {
        int codeUnit = text.codeUnitAt(offset);
        if (codeUnit != _spaceCodeUnit &&
            codeUnit != _tabCodeUnit &&
            codeUnit != _newLineCodeUnit &&
            codeUnit != _carriageReturnCodeUnit) {
          break;
        }
        offset++;
      }
      if (offset == length) {
        return new ParseResult<Target>.failure();
      }

      codeUnit = text.codeUnitAt(offset);
    }

    if (codeUnit != _closeParenCodeUnit) {
      return new ParseResult<Target>.failure();
    }

    offset++;

    return new ParseResult<Target>.success(result, offset);
  }

  // TODO reorder parse to put all fallbacks in the end.
  @override
  ParseResult<Inlines> parse(String text, int offset) {
    int length = text.length;
    bool isImage = false;
    if (text.codeUnitAt(offset) == _exclamationMarkCodeUnit) {
      offset++;
      if (offset == length) {
        return new ParseResult<Inlines>.failure();
      }
      isImage = true;
    }
    if (text.codeUnitAt(offset) != _openBracketCodeUnit) {
      return new ParseResult<Inlines>.failure();
    }
    offset++;
    if (offset == length) {
      return new ParseResult<Inlines>.failure();
    }

    int startOffset = offset;
    int endOffset = -1;
    bool containsLink = false;
    List<_LinkStackItem> stack = <_LinkStackItem>[new _LinkStackItem(offset)];
    while (offset < length && (isImage || !containsLink)) {
      int codeUnit = text.codeUnitAt(offset);
      if (codeUnit == _closeBracketCodeUnit) {
        _LinkStackItem last = stack.removeLast(); // TODO check link.
        if (!isImage) {
          containsLink = last.containsLink;
          if (!containsLink && last.bracketLevel == 2) {
            // There counld be link
            Inlines labelInlines = container.documentParser
                .parseInlines(text.substring(last.offset, offset));

            if (labelInlines._containsLink) {
              containsLink = true;
            }
          }
        }

        if (stack.length == 0) {
          endOffset = offset;
          offset++;
          break;
        }
        offset++;
        continue;
      }
      if (codeUnit == _backslashCodeUnit) {
        // Escaped char
        offset += 2;
        if (offset > length) {
          offset == length;
          break;
        }
        continue;
      }
      if (codeUnit == _openBracketCodeUnit) {
        for (int i = stack.length - 1, level = 2; i >= 0; i--, level++) {
          stack[i].bracketLevel = max(stack[i].bracketLevel, level);
        }
        offset++;
        stack.add(new _LinkStackItem(offset));
        continue;
      }

      if (_higherPriorityInlineParsers.containsKey(codeUnit)) {
        bool found = false;
        for (AbstractParser<Inlines> parser
            in _higherPriorityInlineParsers[codeUnit]) {
          // TODO optimize to only return offset.
          // TODO check autolink
          ParseResult<Inlines> res = parser.parse(text, offset);
          if (res.isSuccess) {
            offset = res.offset;
            if (!isImage && res.value._containsLink) {
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

      ParseResult<Inlines> res = container.strParser.parse(text, offset);
      assert(res.isSuccess);

      offset = res.offset;
    }

    if (endOffset == -1) {
      return new ParseResult<Inlines>.success(
          new Inlines.single(new Str(isImage ? '![' : '[')), startOffset);
    }

    if (isImage || !containsLink) {
      if (offset != length) {
        // Test link in parens.
        int codeUnit = text.codeUnitAt(offset);
        if (codeUnit == _openParenCodeUnit) {
          ParseResult<Target> targetResult = _parseTarget(text, offset + 1);
          if (targetResult.isSuccess) {
            // Normal link.
            Inlines labelInlines = container.documentParser
                .parseInlines(text.substring(startOffset, endOffset));

            Inline result = isImage
                ? new InlineImage(labelInlines, targetResult.value)
                : new InlineLink(labelInlines, targetResult.value);
            return new ParseResult<Inlines>.success(
                new Inlines.single(result), targetResult.offset);
          }
        }

        if (codeUnit == _openBracketCodeUnit) {
          if (offset + 1 < length &&
              text.codeUnitAt(offset + 1) == _closeBracketCodeUnit) {
            String reference = text.substring(startOffset, endOffset);
            String normalizedReference = _LinkReference.normalize(reference);
            Target target;
            if (container.references.containsKey(normalizedReference)) {
              target = container.references[normalizedReference];
            } else {
              target = container.options
                  .linkResolver(normalizedReference, reference);
            }
            if (target != null) {
              Inlines labelInlines = container.documentParser
                  .parseInlines(text.substring(startOffset, endOffset));

              Inline result = isImage
                  ? new ReferenceImage(reference, labelInlines, target)
                  : new ReferenceLink(reference, labelInlines, target);
              return new ParseResult<Inlines>.success(
                  new Inlines.single(result), offset + 2);
            } else {
              return new ParseResult<Inlines>.success(
                  new Inlines.single(new Str(isImage ? '![' : '[')),
                  startOffset);
            }
          }

          // Full reference parsing
          Match referenceMatch = _referenceRegExp.matchAsPrefix(text, offset);
          if (referenceMatch != null) {
            String reference = referenceMatch[1];
            String normalizedReference = _LinkReference.normalize(reference);
            Target target;

            if (container.references.containsKey(normalizedReference)) {
              target = container.references[normalizedReference];
            } else {
              target = container.options
                  .linkResolver(normalizedReference, reference);
            }
            if (target != null) {
              Inlines labelInlines = container.documentParser
                  .parseInlines(text.substring(startOffset, endOffset));

              Inline result = isImage
                  ? new ReferenceImage(reference, labelInlines, target)
                  : new ReferenceLink(reference, labelInlines, target);

              return new ParseResult<Inlines>.success(
                  new Inlines.single(result), referenceMatch.end);
            }
          }

          return new ParseResult<Inlines>.success(
              new Inlines.single(new Str(isImage ? '![' : '[')), startOffset);
        }
      }

      // Not followed by `(` or `[`
      // It's a shortcut reference link

      // Found variant

      String reference = text.substring(startOffset, endOffset);
      String normalizedReference = _LinkReference.normalize(reference);

      if (normalizedReference != '') {
        Target target;

        if (container.references.containsKey(normalizedReference)) {
          target = container.references[normalizedReference];
        } else {
          target =
              container.options.linkResolver(normalizedReference, reference);
        }
        if (target != null) {
          Inlines labelInlines = container.documentParser
              .parseInlines(text.substring(startOffset, endOffset));

          Inline result = isImage
              ? new ReferenceImage(reference, labelInlines, target)
              : new ReferenceLink(reference, labelInlines, target);
          return new ParseResult<Inlines>.success(
              new Inlines.single(result), offset);
        }
      }
    }

    return new ParseResult<Inlines>.success(
        new Inlines.single(new Str(isImage ? '![' : '[')), startOffset);
  }
}
