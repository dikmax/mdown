part of md_proc.src.parsers;

class _Delim {
  final int charCode;
  int count;
  final bool canOpen;
  final bool canClose;

  // Used for unmathed single quote
  bool matched = false;
  Inlines inlines = new Inlines();

  _Delim(this.charCode, this.count, this.canOpen, this.canClose);

  int countCloses(_Delim delim) {
    if (charCode != delim.charCode) {
      return 0;
    }
    if (charCode == _singleQuoteCodeUnit ||
        charCode == _doubleQuoteCodeUnit) {
      return 1; // Always closes.
    }
    if ((canClose || delim.canOpen) && (count + delim.count) % 3 == 0) {
      return 0;
    }

    return min(count, delim.count);
  }
}

/// Parsing emphasis, strongs, smartquotes, etc.
class InlineStructureParser extends AbstractParser<Inlines> {
  static final RegExp _spaceRegExp = new RegExp(r'\s');
  static final RegExp _punctuationRegExp = new RegExp(
      '[\u2000-\u206F\u2E00-\u2E7F\\\\\'!"#\$%&()*+,\\-./:;<=>?@\\[\\]^_`{|}~]');

  Set<int> _delimitersChars;

  Map<int, List<AbstractParser<Iterable<Inline>>>> _inlineParsers;

  /// Constructor.
  InlineStructureParser(ParsersContainer container) : super(container) {
    this._delimitersChars =
        new Set<int>.from(<int>[_starCodeUnit, _unredscoreCodeUnit]);

    if (container.options.smartPunctuation) {
      _delimitersChars.add(_singleQuoteCodeUnit);
      _delimitersChars.add(_doubleQuoteCodeUnit);
    }
  }

  @override
  void init() {
    _inlineParsers = new HashMap<int, List<AbstractParser<Iterable<Inline>>>>();

    _inlineParsers[_spaceCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[_tabCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.hardLineBreakParser
    ];

    _inlineParsers[_slashCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.escapesParser
    ];

    _inlineParsers[_ampersandCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.entityParser
    ];

    _inlineParsers[_backtickCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.inlineCodeParser
    ];

    _inlineParsers[_openBracketCodeUnit] =
        <AbstractParser<Iterable<Inline>>>[container.linkImageParser];

    _inlineParsers[_lessThanCodeUnit] = <AbstractParser<Iterable<Inline>>>[
      container.autolinkParser
    ];

    if (container.options.rawHtml) {
      _inlineParsers[_lessThanCodeUnit].add(container.inlineHtmlParser);
    }

    if (container.options.smartPunctuation) {
      _inlineParsers[_dotCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.ellipsisParser
      ];

      _inlineParsers[_minusCodeUnit] = <AbstractParser<Iterable<Inline>>>[
        container.mnDashParser
      ];
    }
  }

  _Delim _scanDelims(String text, int offset) {
    int charCode = text.codeUnitAt(offset);
    if (!_delimitersChars.contains(charCode)) {
      return null;
    }

    int endOffset = offset + 1;
    int length = text.length;
    while (endOffset < length && text.codeUnitAt(endOffset) == charCode) {
      endOffset++;
    }

    int count = endOffset - offset;
    String charBefore = offset == 0 ? '\n' : text[offset - 1];
    String charAfter = endOffset < length ? text[endOffset] : '\n';

    bool spaceAfter = _spaceRegExp.hasMatch(charAfter);
    bool spaceBefore = _spaceRegExp.hasMatch(charBefore);
    bool punctuationAfter = _punctuationRegExp.hasMatch(charAfter);
    bool punctuationBefore = _punctuationRegExp.hasMatch(charBefore);
    bool leftFlanking =
        !spaceAfter && (!punctuationAfter || spaceBefore || punctuationBefore);
    bool rightFlanking =
        !spaceBefore && (!punctuationBefore || spaceAfter || punctuationAfter);

    bool canOpen = leftFlanking;
    bool canClose = rightFlanking;
    if (charCode == _unredscoreCodeUnit) {
      canOpen = canOpen && (!rightFlanking || punctuationBefore);
      canClose = canClose && (!leftFlanking || punctuationAfter);
    } else if (charCode == _singleQuoteCodeUnit ||
        charCode == _doubleQuoteCodeUnit) {
      canOpen = canOpen && !rightFlanking;
    }

    return new _Delim(charCode, count, canOpen, canClose);
  }

  Inlines _buildStack(List<_Delim> stack, int skip) {
    Inlines result = new Inlines();
    Iterable<_Delim> list = skip > 0 ? stack.skip(skip) : stack;
    list.forEach((_Delim delim) {
      if (delim.count > 0) {
        int charCode = delim.charCode;
        if (charCode == _singleQuoteCodeUnit) {
          result.addAll(new List<Inline>.filled(delim.count,
              delim.matched ? new SingleOpenQuote() : new Apostrophe()));
        } else if (charCode == _doubleQuoteCodeUnit) {
          result.addAll(
              new List<Inline>.filled(delim.count, new DoubleOpenQuote()));
        } else {
          result.add(new Str(new String.fromCharCode(charCode) * delim.count));
        }
      }
      result.addAll(delim.inlines);
    });
    stack.length = skip;

    return result;
  }

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    _Delim delim = _scanDelims(text, offset);

    if (delim == null) {
      return new ParseResult<Inlines>.failure();
    }

    offset += delim.count;

    if (!delim.canOpen) {
      int charCode = delim.charCode;
      List<Inline> result;
      if (charCode == _singleQuoteCodeUnit) {
        result = new List<Inline>.filled(delim.count, new Apostrophe());
      } else if (charCode == _doubleQuoteCodeUnit) {
        result = new List<Inline>.filled(delim.count, new DoubleCloseQuote());
      } else {
        result = <Inline>[
          new Str(new String.fromCharCode(charCode) * delim.count)
        ];
      }

      return new ParseResult<Inlines>.success(new Inlines.from(result), offset);
    }

    List<_Delim> stack = <_Delim>[delim];

    Inlines result = new Inlines();

    int length = text.length;
    while (offset < length && stack.length > 0) {
      _Delim delim = _scanDelims(text, offset);
      if (delim != null) {
        if (delim.canClose) {
          if (delim.charCode == _singleQuoteCodeUnit ||
              delim.charCode == _doubleQuoteCodeUnit) {
            int openDelimIndex = stack.length - 1;
            while (openDelimIndex >= 0) {
              _Delim openDelim = stack[openDelimIndex];
              if (openDelim.charCode == delim.charCode) {
                openDelim.matched = true;
                break;
              }
              openDelimIndex--;
            }

            stack.last.inlines.addAll(new List<Inline>.filled(
                delim.count,
                delim.charCode == _singleQuoteCodeUnit
                    ? new SingleCloseQuote()
                    : new DoubleCloseQuote()));

            offset += delim.count;
            delim.count = 0;
          } else {
            // Going down through stack, and searching delimiter to close.
            int countCloses = 0;
            int openDelimIndex = stack.length - 1;
            while (openDelimIndex >= 0 && delim.count > 0) {
              _Delim openDelim = stack[openDelimIndex];
              countCloses = openDelim.countCloses(delim);
              if (countCloses > 0) {
                _Delim openDelim = stack[openDelimIndex];
                if (openDelimIndex < stack.length - 1) {
                  Inlines inner = _buildStack(stack, openDelimIndex + 1);
                  openDelim.inlines.addAll(inner);
                }

                Inlines itemRes = openDelim.inlines;

                if (delim.charCode == _unredscoreCodeUnit ||
                    delim.charCode == _starCodeUnit) {
                  int delimsLeft = countCloses;
                  if ((delimsLeft & 1) == 1) {
                    itemRes = new Inlines.single(new Emph(itemRes));
                    delimsLeft--;
                  }

                  while (delimsLeft > 0) {
                    itemRes = new Inlines.single(new Strong(itemRes));
                    delimsLeft -= 2;
                  }
                }
                openDelim.inlines = itemRes;

                openDelim.count -= countCloses;
                if (openDelim.count == 0) {
                  Inlines itemRes = _buildStack(stack, stack.length - 1);
                  if (stack.length == 0) {
                    result.addAll(itemRes);
                  } else {
                    stack.last.inlines.addAll(itemRes);
                  }
                }

                offset += countCloses;
                delim.count -= countCloses;
              }
              openDelimIndex--;
            }
          }
        }

        if (delim.count > 0) {
          if (delim.canOpen) {
            stack.add(delim);
          } else {
            Inlines inlines = stack.length == 0 ? result : stack.last.inlines;
            inlines.add(
                new Str(new String.fromCharCode(delim.charCode) * delim.count));
          }
        }

        offset += delim.count;
        continue;
      }

      int codeUnit = text.codeUnitAt(offset);
      if (codeUnit == _exclamationMarkCodeUnit &&
          offset + 1 < length &&
          text.codeUnitAt(offset + 1) == _openBracketCodeUnit) {
        // Exclamation mark without bracket means nothing.
        ParseResult<Inlines> res =
            container.linkImageParser.parse(text, offset);
        if (res.isSuccess) {
          if (res.value.length > 0) {
            stack.last.inlines.addAll(res.value);
          }
          offset = res.offset;
          continue;
        }
      } else if (_inlineParsers.containsKey(codeUnit)) {
        bool found = false;
        for (AbstractParser<Inlines> parser in _inlineParsers[codeUnit]) {
          ParseResult<Inlines> res = parser.parse(text, offset);
          if (res.isSuccess) {
            if (res.value.length > 0) {
              stack.last.inlines.addAll(res.value);
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

      ParseResult<Inlines> res = container.strParser.parse(text, offset);
      assert(res.isSuccess);

      if (res.value.length > 0) {
        stack.last.inlines.addAll(res.value);
      }
      offset = res.offset;
    }

    result.addAll(_buildStack(stack, 0));

    return new ParseResult<Inlines>.success(result, offset);
  }
}