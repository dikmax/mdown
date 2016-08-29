part of md_proc.src.parsers;

/// Parser for links and images.
class LinkImageParser extends AbstractParser<Inlines> {
  static final RegExp _linkRegExp = new RegExp(
      // Space after opening paren (optional)
      r'(?:[ \t\r\n]*)'
      // Link in <>
      r'(<(?:[^\\> \t\r\n]|\\.|\\)*>|'
      // Link without
      r'(?:[^ \t\r\n\(\)\\]+|\((?:[^ \t\r\n\(\)\\]|\\.|\\)*\)|\\.|\\)*)'
      // Space after link and title (optional)
      r'(?:[ \t\r\n]+('
      r'"(?:[^"]|\\")*"|'
      r"'(?:[^']|\\')*'|"
      r'\((?:[^)]|\\\))*\)'
      r'))?'
      // Space before closing paren (optional)
      r'(?:[ \t\r\n]*)'
      // Closing paren
      r'\)');

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
    int brackets = 1;
    while (offset < length) {
      int codeUnit = text.codeUnitAt(offset);
      if (codeUnit == _closeBracketCodeUnit) {
        brackets--;
        if (brackets == 0) {
          endOffset = offset;
          offset++;
          break;
        }
        offset++;
        continue;
      }
      if (codeUnit == _slashCodeUnit) {
        // Escaped char
        offset += 2;
        if (offset > length) {
          offset == length;
          break;
        }
        continue;
      }
      if (codeUnit == _openBracketCodeUnit) {
        brackets++;
        offset++;
        continue;
      }

      if (_higherPriorityInlineParsers.containsKey(codeUnit)) {
        bool found = false;
        for (AbstractParser<Inlines> parser
            in _higherPriorityInlineParsers[codeUnit]) {
          // TODO optimize to only return offset.
          ParseResult<Inlines> res = parser.parse(text, offset);
          if (res.isSuccess) {
            offset = res.offset;
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

    Inlines labelInlines = container.documentParser
        .parseInlines(text.substring(startOffset, endOffset));

    if (isImage || !labelInlines._containsLink) {
      if (offset != length) {
        // Test link in parens.
        int codeUnit = text.codeUnitAt(offset);
        if (codeUnit == _openParenCodeUnit) {
          Match match = _linkRegExp.matchAsPrefix(text, offset + 1);
          if (match != null) {
            // Normal link. It also can be dropped,
            // if contains links inside label.
            String link = match[1];
            link = unescapeAndUnreference(link);
            if (link.startsWith('<') && link.endsWith('>')) {
              link = link.substring(1, link.length - 1);
            }

            String title = match[2];
            if (title != null) {
              title = title.substring(1, title.length - 1);
              title = unescapeAndUnreference(title);
            }

            Inline result = isImage
                ? new InlineImage(labelInlines, new Target(link, title))
                : new InlineLink(labelInlines, new Target(link, title));
            return new ParseResult<Inlines>.success(
                new Inlines.single(result), match.end);
          }
        }

        if (codeUnit == _openBracketCodeUnit) {
          if (offset + 1 < length &&
              text.codeUnitAt(offset + 1) == _closeBracketCodeUnit) {
            String reference = _LinkReference
                .normalize(text.substring(startOffset, endOffset));

            if (container.references.containsKey(reference)) {
              Inline result = isImage
                  ? new ReferenceImage(
                      reference, labelInlines, container.references[reference])
                  : new ReferenceLink(
                      reference, labelInlines, container.references[reference]);
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
            String reference = _LinkReference.normalize(referenceMatch[1]);
            if (container.references.containsKey(reference)) {
              Inline result = isImage
                  ? new ReferenceImage(
                      reference, labelInlines, container.references[reference])
                  : new ReferenceLink(
                      reference, labelInlines, container.references[reference]);

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
      if (normalizedReference != '' &&
          container.references.containsKey(normalizedReference)) {
        Inline result = isImage
            ? new ReferenceImage(reference, labelInlines,
                container.references[normalizedReference])
            : new ReferenceLink(reference, labelInlines,
                container.references[normalizedReference]);
        return new ParseResult<Inlines>.success(
            new Inlines.single(result), offset);
      }
    }

    return new ParseResult<Inlines>.success(
        new Inlines.single(new Str(isImage ? '![' : '[')), startOffset);
  }
}