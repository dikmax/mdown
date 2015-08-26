library md_proc.markdown_parser;

import 'package:parsers/parsers.dart';
import 'package:persistent/persistent.dart';

import 'definitions.dart';
import 'entities.dart';
import 'options.dart';


class _UnparsedInlines extends Inlines {
  String raw;

  _UnparsedInlines(this.raw);

  String toString() => raw;

  bool operator==(obj) => obj is _UnparsedInlines &&
    raw == obj.raw;

  int get hashCode => raw.hashCode;
}


String _normalizeReference(String s) {
  return s.trim()
    .replaceAll(new RegExp(r'\s+'),' ')
    .toUpperCase();
}


class _LinkReference extends Block {
  String reference;
  String normalizedReference;
  Target target;

  _LinkReference(this.reference, this.target) {
    normalizedReference = _normalizeReference(reference);
  }
}


class _EscapedSpace extends Inline {
  static final _EscapedSpace _instance = new _EscapedSpace._internal();

  factory _EscapedSpace() {
    return _instance;
  }

  _EscapedSpace._internal();

  String toString() => "_EscapedSpace";

  bool operator== (obj) => obj is _EscapedSpace;

  int get hashCode => 0;
}


// TODO make aux parsers private

// TODO extract constant parsers from parsers methods

class _ListStackItem {
  int indent;
  int subIndent;
  ListBlock block;

  _ListStackItem(this.indent, this.subIndent, this.block);
}


class _EmphasisStackItem {
  String char;
  int numDelims;
  Inlines inlines;
  bool cantCloseAnyway;

  _EmphasisStackItem(this.char, this.numDelims, this.inlines, {this.cantCloseAnyway: false});
}

// TODO make const parsers 'final'

// CommonMark parser
class CommonMarkParser {
  static const int tabStop = 4;

  Options _options;

  Map<String, Target> _references;

  String _inlineDelimiters;
  String _strSpecialChars;
  String _intrawordDelimiters;

  CommonMarkParser(this._options, [this._references]) {
    _inlineDelimiters = "_*";
    _strSpecialChars = " *_`![]&<\\";
    _intrawordDelimiters = "*";
    if (_options.smartPunctuation) {
      _inlineDelimiters += "'\"";
      _strSpecialChars += "'\".-";
    }
    if (_options.strikeout || _options.subscript) {
      _inlineDelimiters += "~";
      _strSpecialChars += "~";
      _intrawordDelimiters += "~";
    }
    if (_options.superscript) {
      _inlineDelimiters += '^';
      _strSpecialChars += '^';
      _intrawordDelimiters += '^';
    }
  }

  Document parse(String s) {
    // TODO separate preprocess option

    _references = {};

    s = preprocess(s);
    if (!s.endsWith("\n")) {
      s += "\n";
    }
    var doc = document.parse(s, tabStop: tabStop);

    _inlinesInDocument(doc);
    return doc;
  }


  //
  // Preprocess
  //

  String preprocess(String s) {
    StringBuffer sb = new StringBuffer();

    int i = 0, len = s.length;
    while (i < len) {
      if (s[i] == "\r") {
        if (i + 1 < len && s[i + 1] == "\n") {
          ++i;
        }

        sb.write("\n");
      } else if (s[i] == "\n") {
        if (i + 1 < len && s[i + 1] == "\r") {
          ++i;
        }

        sb.write("\n");
      } else {
        sb.write(s[i]);
      }

      ++i;
    }

    return sb.toString();
  }


  //
  // Inlines search
  //

  void _inlinesInDocument(Document doc) {
    doc.contents.forEach(_inlinesInBlock);
  }


  Block _inlinesInBlock(Block block) {
    if (block is Header) {
      var contents = block.contents;
      if (contents is _UnparsedInlines) {
        block.contents = _parseInlines(contents.raw);
      }
    } else if (block is Para) {
      var contents = block.contents;
      if (contents is _UnparsedInlines) {
        block.contents = _parseInlines(contents.raw);
      }
    } else if (block is Blockquote) {
      block.contents = block.contents.map(_inlinesInBlock);
    } else if (block is ListBlock) {
      block.items = block.items.map((ListItem item) {
        item.contents = item.contents.map(_inlinesInBlock);
        return item;
      });
    }
    return block;
  }


  Inlines _parseInlines(String raw) {
    return inlines.parse(raw, tabStop: tabStop);
  }


  //
  // Aux methods
  //

  List<Block> processParsedBlocks(Iterable blocks) {
    List list = flatten(blocks);
    List result = [];
    list.forEach((Block block) {
      if (block is _LinkReference) {
        String nr = block.normalizedReference;
        if (!_references.containsKey(nr)) {
          _references[nr] = block.target;
        }
      } else {
        result.add(block);
      }
    });
    return result;
  }


  Inlines processParsedInlines(Iterable inlines) {
    Inlines result = new Inlines();
    result.addAll(flatten(inlines));
    return result;
  }


  static List flatten(Iterable list) {
    List result = [];

    for (var item in list) {
      if (item is Iterable) {
        result.addAll(flatten(item));
      } else {
        result.add(item);
      }
    }

    return result;
  }


  String stripTrailingNewlines(String str) {
    var l = str.length;
    while (l > 0 && str[l - 1] == '\n') {
      --l;
    }
    return str.substring(0, l);
  }


  //
  // Aux parsers
  //

  static Parser get anyLine => new Parser((String s, Position pos) {
    String result = '';
    int offset = pos.offset, len = s.length;
    if (offset >= len) {
      return new ParseResult(s, new Expectations.empty(pos), pos, false, false, null);
    }
    while (offset < len && s[offset] != '\n') {
      result += s[offset];
      ++offset;
    }
    var newPos;
    if (offset < len && s[offset] == '\n') {
      newPos = new Position(offset + 1, pos.line + 1, 1, tabStop: tabStop);
    } else {
      newPos = new Position(offset, pos.line, pos.character + result.length, tabStop: tabStop);
    }
    return new ParseResult(s, new Expectations.empty(newPos), newPos, true, false, result);
  });


  static final Parser whitespaceChar = oneOf(" \t") % 'space';
  static final Parser nonSpaceChar = noneOf("\t\n \r");
  static Parser skipSpaces = whitespaceChar.skipMany;
  static Parser blankline = skipSpaces > newline % 'blankline';
  static Parser blanklines = blankline.many1 % 'blanklines';

  // All indent and spaces parsers accepts spaces to skip, and returns spaces
  // that were actually skipped.
  // TODO test all parsers that use skipNonindentSpaces, skipListNonindentSpaces, indentSpaces, atMostSpaces
  // TODO rename indentSpaces => indent, atMostSpaces => atMostIndent
  static final Parser skipNonindentChars = atMostIndent(tabStop - 1).notFollowedBy(whitespaceChar);
  static final Parser skipNonindentCharsFromAnyPosition =
    atMostIndent(tabStop - 1, fromLineStart: false).notFollowedBy(whitespaceChar);
  static Parser skipListIndentChars(int max) => (atMostIndent(max - 1) | atMostIndent(tabStop - 1, fromLineStart: false)).notFollowedBy(whitespaceChar);
  static Parser spnl = (skipSpaces > newline);
  static Parser get indent => waitForIndent(tabStop) % "indentation";

  static Parser atMostIndent(int indent, {bool fromLineStart: true}) => new Parser((String s, Position pos) {
    if (fromLineStart && pos.character != 1) {
      return fail.run(s, pos);
    }
    var startCharacter = pos.character;
    var maxEndCharacter = indent + startCharacter;
    Position position = pos;
    while (position.character <= maxEndCharacter) {
      var res = whitespaceChar.run(s, position);
      if (!res.isSuccess || res.position.character > maxEndCharacter) {
        return success(position.character - startCharacter).run(s, position);
      }
      position = res.position;
    }
    return success(position.character - startCharacter).run(s, position);
  });

  static Parser waitForIndent(int length) => new Parser((String s, Position pos) {
    if (pos.character != 1) {
      return fail.run(s, pos);
    }
    var startCharacter = pos.character;
    Position position = pos;
    while (position.character <= length) {
      var res = whitespaceChar.run(s, position);
      if (!res.isSuccess) {
        return res;
      }
      position = res.position;
    }
    return success(position.character - startCharacter).run(s, position);
  }) % "indentation";


  static Parser count(int l, Parser p) => countBetween(l, l, p);

  static Parser countBetween(int min, int max, Parser p) => new Parser((String s, Position pos) {
    var position = pos;
    var value = [];
    ParseResult res;
    for (int i = 0; i < max; ++i) {
      res = p.run(s, position);
      if (res.isSuccess) {
        value.add(res.value);
        position = res.position;
      } else if (i < min) {
        return fail.run(s, pos);
      } else {
        return success(value).run(s, position);
      }
    }

    return res.copy(value: value);
  });


  //
  // HTML
  //

  static final String _lower = "abcdefghijklmnopqrstuvwxyz";
  static final String _upper = _lower.toUpperCase();
  static final String _alpha = "$_lower$_upper";
  static final String _digit = "1234567890";
  static final String _alphanum = "$_alpha$_digit";
  static final Set<String> _allowedTags = new Set.from(
      ["address", "article", "aside", "base", "basefont", "blockquote", "body",
      "caption", "center", "col", "colgroup", "dd", "details", "dialog", "dir",
      "div", "dl", "dt", "fieldset", "figcaption", "figure", "footer", "form",
      "frame", "frameset", "h1", "head", "header", "hr", "html", "iframe", "legend",
      "li", "link", "main", "menu", "menuitem", "meta", "nav", "noframes", "ol",
      "optgroup", "option", "p", "param", "section", "source", "summary", "table",
      "tbody", "td", "tfoot", "th", "thead", "title", "tr", "track", "ul"]
  );

  static Parser spaceOrNL = oneOf(" \t\n");

  static Parser htmlTagName = (letter > oneOf(_alphanum + "-").many).record;
  static Parser htmlAttributeName = (oneOf(_alpha + "_:") > oneOf(_alphanum + "_.:-").many).record;
  static Parser htmlAttributeValue = (spaceOrNL.many + char('=') + spaceOrNL.many +
      (htmlUnquotedAttributeValue | htmlSingleQuotedAttributeValue | htmlDoubleQuotedAttributeValue)).list.record;
  static Parser htmlUnquotedAttributeValue = noneOf(" \t\n\"'=<>`").many1;
  static Parser htmlSingleQuotedAttributeValue = (char("'") > noneOf("'").many) < char("'");
  static Parser htmlDoubleQuotedAttributeValue = (char('"') > noneOf('"').many) < char('"');
  static Parser get htmlAttribute => (spaceOrNL.many1 + htmlAttributeName + htmlAttributeValue.maybe).list.record;
  Parser get htmlOpenTag => (((((char("<") > htmlTagName) < htmlAttribute.many) <
      spaceOrNL.many) < char('/').maybe) < char('>')).record;
  Parser get htmlCloseTag => (((string("</") > htmlTagName) < spaceOrNL.many) < char('>')).record;
  Parser _htmlCompleteComment = (string('<!--').notFollowedBy(char('>') | string('->')) > anyChar.manyUntil(string('--'))).record;
  Parser get htmlCompleteComment => new Parser((String s, Position pos) {
    ParseResult res = _htmlCompleteComment.run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    ParseResult res2 = char('>').run(s, res.position);
    if (res2.isSuccess) {
      return res2.copy(value: res.value + '>');
    }
    return res2;
  });
  Parser get htmlCompletePI => (string('<?') > anyChar.manyUntil(string('?>'))).record;
  Parser get htmlDeclaration => (string('<!') + upper.many1 + spaceOrNL.many1 + anyChar.manyUntil(char('>'))).list.record;
  Parser get htmlCompleteCDATA => (string('<![CDATA[') > anyChar.manyUntil(string(']]>'))).record;

  //
  // Links aux parsers
  //

  Parser get _linkTextChoice =>
    choice([whitespace, htmlEntity, inlineCode, autolink, rawInlineHtml, escapedChar, rec(() => linkText), str]);
  Parser get linkText => (char('[') > (_linkTextChoice + _linkTextChoice.manyUntil(char(']'))).list.record) ^
      (String label) => label.substring(0, label.length - 1);
  Parser get imageText => (char('[') > _linkTextChoice.manyUntil(char(']')).record) ^
      (String label) => label.substring(0, label.length - 1);

  static final String _linkLabelStrSpecialChars = " *_`!<\\";
  static final Parser _linkLabelStr = (noneOf(_linkLabelStrSpecialChars + "[]\n").many1 ^ (chars) => _transformString(chars.join())) |
    (oneOf(_linkLabelStrSpecialChars) ^ (chars) => _transformString(chars)) |
    (char("\n").notFollowedBy(spnl) ^ (_) => [new Str("\n")]);


  Parser get linkLabel => (char('[') >
      choice([whitespace, htmlEntity, inlineCode, autolink, rawInlineHtml, escapedChar, _linkLabelStr]).manyUntil(char(']')).record) ^
      (String label) => label.substring(0, label.length - 1);


  Parser get linkBalancedParenthesis => ((char("(") > (noneOf('&\\\n ()') | escapedChar1 | htmlEntity1 | oneOf('&\\')).many1) <
    char(')')) ^ (i) => "(${i.join()})";


  Parser get linkInlineDestination => (
      ((char("<") > noneOf("<>\n").many) < char(">")) |
      (noneOf("&\\\n ()") | escapedChar1 | htmlEntity1 | linkBalancedParenthesis | oneOf('&\\')).many
  ) ^ (i) => i.join();


  Parser get linkBlockDestination => (
      ((char("<") > noneOf("<>\n").many1) < char(">")) |
      (noneOf("&\\\n ()") | escapedChar1 | htmlEntity1 | linkBalancedParenthesis | oneOf('&\\')).many1
  ) ^ (i) => i.join();


  Parser get oneNewLine => newline.notFollowedBy(blankline);
  Parser get linkTitle => (
      ((char("'") > (noneOf("'&\\\n") | oneNewLine | escapedChar1 | htmlEntity1 | oneOf('&\\')).many) < char("'")) |
      ((char('"') > (noneOf('"&\\\n') | oneNewLine | escapedChar1 | htmlEntity1 | oneOf('&\\')).many) < char('"')) |
      ((char('(') > (noneOf(')&\\\n') | oneNewLine | escapedChar1 | htmlEntity1 | oneOf('&\\')).many) < char(')'))
  ) ^ (i) => i.join();


  //
  // Inlines
  //

  //
  // whitespace
  //

  static final Parser whitespace =
      (char(' ') ^ (_) => [new Space()]) |
      (char('\t') ^ (_) => [new Tab()]);


  // TODO better escaped chars support
  Parser escapedChar1 = (char('\\') > oneOf("!\"#\$%&'()*+,-./:;<=>?@[\\]^_`{|}~")) % "escaped char";
  Parser get escapedChar => escapedChar1 ^ (char) => [new Str(char)];


  //
  // html entities
  //

  static RegExp decimalEntity = new RegExp(r'^#(\d{1,8})$');
  static RegExp hexadecimalEntity = new RegExp(r'^#[xX]([0-9a-fA-F]{1,8})$');
  Parser<String> get htmlEntity1 => (((char('&') >
      ((char('#').maybe + alphanum.many1) ^ (Option a, b) => (a.isDefined ? '#' : '') + b.join()) ) <
      char(';')) ^ (entity) {
    if (htmlEntities.containsKey(entity)) {
      return htmlEntities[entity];
    }

    int code;
    Match m = decimalEntity.firstMatch(entity);
    if (m != null) {
      code = int.parse(m.group(1));
    }

    m = hexadecimalEntity.firstMatch(entity);

    if (m != null) {
      code = int.parse(m.group(1), radix: 16);
    }

    if (code != null) {
      if (code > 1114111 || code == 0) {
        code = 0xFFFD;
      }
      return new String.fromCharCode(code);
    }

    return '&$entity;';
  }) % "html entity";
  Parser get htmlEntity => htmlEntity1 ^ (str) => str == "\u{a0}" ? [new NonBreakableSpace()] : [new Str(str)];


  //
  // inline code
  //

  String _processInlineCode(String code) {
    return code.trim().replaceAll(new RegExp(r'\s+'), ' ');
  }

  static Parser _inlineCode1 = char('`').many1;
  static Parser _inlineCode2 = noneOf('\n`').many;

  Parser<List<Inline>> get inlineCode => new Parser<List<Inline>>((String s, Position pos) {
    ParseResult openRes = _inlineCode1.run(s, pos);
    if (!openRes.isSuccess) {
      return openRes;
    }
    if (pos.offset > 0 && s[pos.offset - 1] == '`') {
      return fail.run(s,pos);
    }

    int fenceSize = openRes.value.length;

    StringBuffer str = new StringBuffer();
    Position position = openRes.position;
    while(true) {
      ParseResult res = _inlineCode2.run(s, position);
      if (!res.isSuccess) {
        return res;
      }
      str.write(res.value.join());
      position = res.position;

      // Checking for paragraph end
      ParseResult blankRes = char('\n').run(s, position);
      if (blankRes.isSuccess) {
        str.write('\n');
        position = blankRes.position;
        ParseResult blankRes2 = blankline.run(s, position);
        if (blankRes2.isSuccess) { // second \n - closing block
          return fail.run(s, pos);
        }
        position = blankRes.position;
        continue;
      }

      res = _inlineCode1.run(s, position);
      if (!res.isSuccess) {
        return res;
      }
      if (res.value.length == fenceSize) {
        return res.copy(value: [new Code(_processInlineCode(str.toString()), fenceSize: fenceSize)]);
      }
      str.write(res.value.join());
      position = res.position;
    }
  });

  //
  // emphasis and strong
  //

  static RegExp _isSpace = new RegExp(r'^\s');

  static RegExp _isPunctuation = new RegExp("^[\u{2000}-\u{206F}\u{2E00}-\u{2E7F}\\\\'!\"#\\\$%&\\(\\)\\*\\+,\\-\\.\\/:;<=>\\?@\\[\\]\\^_`\\{\\|\\}~]");

  Parser get scanDelims => new Parser((String s, Position pos) {
    ParseResult testRes = oneOf(_inlineDelimiters).lookAhead.run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }
    String c = testRes.value;

    ParseResult res = char(c).many1.run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    int numDelims = res.value.length;

    var i = 1;
    while (pos.offset - i >= 0 && _intrawordDelimiters.contains(s[pos.offset - i])) {
      ++i;
    }
    String charBefore = pos.offset - i < 0 ? '\n' : s[pos.offset - i];

    i = 0;
    while (res.position.offset + i < s.length && _intrawordDelimiters.contains(s[res.position.offset + i])) {
      ++i;
    }
    String charAfter = res.position.offset + i < s.length ? s[res.position.offset + i] : '\n';
    bool leftFlanking = !_isSpace.hasMatch(charAfter) &&
        (!_isPunctuation.hasMatch(charAfter) || _isSpace.hasMatch(charBefore) || _isPunctuation.hasMatch(charBefore));
    bool rightFlanking = !_isSpace.hasMatch(charBefore) &&
        (!_isPunctuation.hasMatch(charBefore) || _isSpace.hasMatch(charAfter) || _isPunctuation.hasMatch(charAfter));
    bool canOpen = numDelims > 0 && leftFlanking;
    bool canClose = numDelims > 0 && rightFlanking;
    if (c == '_') {
      canOpen = canOpen && (!rightFlanking || _isPunctuation.hasMatch(charBefore));
      canClose = canClose && (!leftFlanking || _isPunctuation.hasMatch(charAfter));
    }
    if (c == '~' && !_options.subscript && numDelims < 2) {
      canOpen = false;
      canClose = false;
    }
    return res.copy(value: [numDelims, canOpen, canClose, c]);
  });


  Parser get emphasis => new Parser((String s, Position pos) {
    ParseResult res = scanDelims.run(s, pos);
    if (!res.isSuccess) {
      return res;
    }
    int numDelims = res.value[0];
    bool canOpen = res.value[1];
    bool canClose = res.value[2];
    String char = res.value[3];

    if (!canOpen) {
      return res.copy(value: [new Str(char * numDelims)]);
    }

    List<_EmphasisStackItem> stack = <_EmphasisStackItem>[];
    Inlines result = new Inlines();
    Position position = res.position;

    void mergeWithPrevious() {
      Inlines inlines = new Inlines();
      if (stack.last.char == "'" || stack.last.char == '"') {
        for (var i = 0; i < stack.last.numDelims; ++i) {
          inlines.add(new SmartQuote(new Inlines(), single: stack.last.char == "'", close: false));
        }
      } else {
        inlines.add(new Str(stack.last.char * stack.last.numDelims));
      }
      inlines.addAll(stack.last.inlines);
      stack.removeLast();
      if (stack.length > 0) {
        stack.last.inlines.addAll(inlines);
      } else {
        result.addAll(inlines);
      }
    }
    void addToStack(Inline inline) {
      if (stack.length > 0) {
        stack.last.inlines.add(inline);
      } else {
        result.add(inline);
      }
    }
    void addAllToStack(List<Inline> inlines) {
      stack.last.inlines.addAll(inlines);
    }

    Inlines transformEscapedSpace(Inlines inlines, Inline replacement) {
      return new Inlines.from(inlines.map((Inline el) {
        if (el is _EscapedSpace) {
          return replacement;
        }
        if (el is Subscript) {
          el.contents = transformEscapedSpace(el.contents, replacement);
        } else if (el is Superscript) {
          el.contents = transformEscapedSpace(el.contents, replacement);
        } else if (el is Strikeout) {
          el.contents = transformEscapedSpace(el.contents, replacement);
        } else if (el is Emph) {
          el.contents = transformEscapedSpace(el.contents, replacement);
        } else if (el is Strong) {
          el.contents = transformEscapedSpace(el.contents, replacement);
        }
        return el;
      }));
    }

    /// Add all inlines to stack. If there's Space marks all subscript and superscript delimiters as invalid
    /// and return false, otherwise return true;
    bool processSpacesAndAddAllToStack(List<Inline> inlines) {
      bool res = true;
      inlines.forEach((Inline el) {
        if (el is Space) {
          stack.forEach((_EmphasisStackItem item) {
            bool convert = false;
            if (_options.subscript && item.char == '~' || _options.superscript && item.char == '^') {
              item.cantCloseAnyway = true;
              convert = true;
            }
            if (convert) {
              item.inlines = transformEscapedSpace(item.inlines, new NonBreakableSpace());
            }
          });
          res = false;
        }
        stack.last.inlines.add(el);
      });

      return res;
    }

    void wrapStackInlines(String str) {
      stack.last.inlines
        ..insert(0, new Str(str))
        ..add(new Str(str));
    }

    mainloop: while (true) {
      // Trying to close
      if (canOpen && canClose && char == "'" && numDelims == 1) {
        // Special case for smart quote, apostrophe
        addToStack(new SmartQuote(new Inlines(), single: true, open: false));
      } else {
        if (canClose) {
          bool openFound = stack.any((item) => item.char == char);
          while (openFound && numDelims > 0 && stack.length > 0) {
            while (stack.length > 0 && stack.last.char != char) {
              mergeWithPrevious();
            }
            Inlines inlines = stack.last.inlines;
            Inline inline;
            var count = numDelims < stack.last.numDelims  ? numDelims : stack.last.numDelims;
            numDelims -= count;
            stack.last.numDelims -= count;
            if (char == "'" || char == '"') {
              // Smart quotes

              while (count > 0) {
                inline = new SmartQuote(inlines, single: char == "'");
                inlines = new Inlines();
                inlines.add(inline);
                count--;
              }
            } else if (char == "~") {
              if (_options.strikeout && _options.subscript) {
                // Strikeouts and subscripts

                if (count & 1 == 1) {
                  if (stack.last.cantCloseAnyway) {
                    wrapStackInlines("~");
                  } else {
                    inline = new Subscript(transformEscapedSpace(inlines, new Space()));
                    inlines = new Inlines();
                    inlines.add(inline);
                  }
                  count--;
                }
                while (count > 0) {
                  inline = new Strikeout(transformEscapedSpace(inlines, new NonBreakableSpace()));
                  inlines = new Inlines();
                  inlines.add(inline);
                  count -= 2;
                }
              } else if (_options.subscript) {
                // Subscript only

                if (stack.last.cantCloseAnyway) {
                  wrapStackInlines("~" * count);
                } else {
                  while (count > 0) {
                    inline = new Subscript(transformEscapedSpace(inlines, new Space()));
                    inlines = new Inlines();
                    inlines.add(inline);
                    count--;
                  }
                }
              } else {
                // Strikeout only

                if (count & 1 == 1) {
                  inlines.add(new Str("~"));
                  count--;
                }
                while (count > 0) {
                  inline = new Strikeout(inlines);
                  inlines = new Inlines();
                  inlines.add(inline);
                  count -= 2;
                }
              }
            } else if (char == "^") {
              // Superscript

              if (stack.last.cantCloseAnyway) {
                wrapStackInlines("^" * count);
              } else {
                while (count > 0) {
                  inline = new Superscript(transformEscapedSpace(inlines, new Space()));
                  inlines = new Inlines();
                  inlines.add(inline);
                  count--;
                }
              }
            } else {
              // Strongs and emphasises

              if (count & 1 == 1) {
                inline = new Emph(inlines);
                inlines = new Inlines();
                inlines.add(inline);
                count--;
              }
              while (count > 0) {
                inline = new Strong(inlines);
                inlines = new Inlines();
                inlines.add(inline);
                count -= 2;
              }
            }

            if (inline != null) {
              if (stack.last.numDelims == 0) {
                stack.removeLast();
              } else {
                stack.last.inlines = new Inlines();
              }
              addToStack(inline);
            } else {
              mergeWithPrevious();
            }
            if (numDelims > 0) {
              openFound = stack.any((item) => item.char == char);
            }
          }
        }
        // Trying to open
        if (canOpen && numDelims > 0) {
          stack.add(new _EmphasisStackItem(char, numDelims, new Inlines()));
          numDelims = 0;
        }

        if (numDelims > 0 ) {
          // ending delimiters without open ones
          if (char == "'" || char == '"') {
            for (var i = 0; i < stack.last.numDelims; ++i) {
              addToStack(new SmartQuote(new Inlines(), single: stack.last.char == "'", open: false));
            }
          } else {
            addToStack(new Str(char * numDelims));
          }
        }
      }

      if (stack.length == 0) {
        break;
      }

      bool excludeSpaces = (_options.subscript || _options.superscript) &&
        stack.firstWhere((_EmphasisStackItem el) {
          return _options.subscript && el.char == '~' || _options.superscript && el.char == '^';
        }, orElse: () => null) != null;
      while (true) {
        ParseResult res = scanDelims.run(s, position);
        if (res.isSuccess) {
          numDelims = res.value[0];
          canOpen = res.value[1];
          canClose = res.value[2];
          char = res.value[3];
          position = res.position;
          break;
        }

        if (excludeSpaces) {
          res = spaceEscapedInline.run(s, position);
          if (!res.isSuccess) {
            break mainloop;
          }

          excludeSpaces = processSpacesAndAddAllToStack(res.value);
        } else {
          res = inline.run(s, position);
          if (!res.isSuccess) {
            break mainloop;
          }

          addAllToStack(res.value);
        }

        position = res.position;
      }
    }

    while (stack.length > 0) {
      mergeWithPrevious();
    }

    return success(result).run(s, position);
  });


  //
  // link and image
  //

  Parser linkWhitespace = (blankline > (whitespaceChar < skipSpaces)) | (whitespaceChar < skipSpaces);
  Parser get linkInline => (char('(') > (
      (
          (linkWhitespace.maybe > linkInlineDestination) + ((linkWhitespace > linkTitle).maybe < linkWhitespace.maybe)
      ) ^ (a, Option b) => new Target(a, b.asNullable))
  ) < char(')');

  bool _isContainsLink(Inlines inlines) => inlines.any((Inline inline) {
    if (inline is Link) {
      return true;
    }
    if (inline is Emph) {
      return _isContainsLink(inline.contents);
    }
    if (inline is Strong) {
      return _isContainsLink(inline.contents);
    }
    if (inline is Image) {
      return _isContainsLink(inline.label);
    }
    return false;
  });

  Parser<List<Inline>> _linkOrImage(bool isLink) => new Parser<List<Inline>>((String s, Position pos) {
    ParseResult testRes = char('[').run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }

    // Try inline
    ParseResult labelRes = (isLink ? linkText : imageText).run(s, pos);
    if (!labelRes.isSuccess) {
      return labelRes;
    }
    if (isLink && labelRes.value.contains(new RegExp(r"^\s*$"))) {
      return fail.run(s, pos);
    }
    Inlines linkInlines = inlines.parse(labelRes.value, tabStop: tabStop);
    if (isLink && _isContainsLink(linkInlines)) {
      List<Inline> resValue = [new Str('[')];
      resValue.addAll(linkInlines);
      resValue.add(new Str(']'));
      return labelRes.copy(value: resValue);
    }
    ParseResult destRes = linkInline.run(s, labelRes.position);
    if (destRes.isSuccess) {
      // Links inside link content are not allowed
      if (isLink) {
        return destRes.copy(value: [new InlineLink(linkInlines, destRes.value)]);
      } else {
        return destRes.copy(value: [new InlineImage(linkInlines, destRes.value)]);
      }
    }

    // Try reference link
    ParseResult refRes = ((blankline | whitespaceChar).maybe > linkLabel).run(s, labelRes.position);
    if (refRes.isSuccess) {
      String reference = refRes.value == "" ? labelRes.value : refRes.value;
      String normalizedReference = _normalizeReference(reference);
      Target target = _references[normalizedReference];
      if (target == null) {
        target = _options.linkResolver(normalizedReference, reference);
      }
      if (target != null) {
        if (isLink) {
          return refRes.copy(value: [new ReferenceLink(reference, linkInlines, target)]);
        } else {
          return refRes.copy(value: [new ReferenceImage(reference, linkInlines, target)]);
        }
      }
    } else {
      // Try again from beginning because reference couldn't contain brackets
      labelRes = linkLabel.run(s, pos);
      if (!labelRes.isSuccess) {
        return labelRes;
      }
      String normalizedReference = _normalizeReference(labelRes.value);
      Target target = _references[normalizedReference];
      if (target == null) {
        target = _options.linkResolver(normalizedReference, labelRes.value);
      }
      if (target != null) {
        if (isLink) {
          return labelRes.copy(value: [new ReferenceLink(labelRes.value, linkInlines, target)]);
        } else {
          return labelRes.copy(value: [new ReferenceImage(labelRes.value, linkInlines, target)]);
        }
      }
    }

    return fail.run(s, pos);
  });


  Parser<List<Inline>> get image => char('!') > _linkOrImage(false);
  Parser<List<Inline>> get link => _linkOrImage(true);


  List<String> allowedSchemes = <String>[
    "coap", "doi", "javascript", "aaa", "aaas", "about", "acap", "cap",
    "cid", "crid", "data", "dav", "dict", "dns", "file", "ftp", "geo", "go",
    "gopher", "h323", "http", "https", "iax", "icap", "im", "imap", "info",
    "ipp", "iris", "iris.beep", "iris.xpc", "iris.xpcs", "iris.lwz", "ldap",
    "mailto", "mid", "msrp", "msrps", "mtqp", "mupdate", "news", "nfs",
    "ni", "nih", "nntp", "opaquelocktoken", "pop", "pres", "rtsp",
    "service", "session", "shttp", "sieve", "sip", "sips", "sms", "snmp",
    "soap.beep", "soap.beeps", "tag", "tel", "telnet", "tftp", "thismessage",
    "tn3270", "tip", "tv", "urn", "vemmi", "ws", "wss", "xcon",
    "xcon-userid", "xmlrpc.beep", "xmlrpc.beeps", "xmpp", "z39.50r",
    "z39.50s", "adiumxtra", "afp", "afs", "aim", "apt", "attachment", "aw",
    "beshare", "bitcoin", "bolo", "callto", "chrome", "chrome-extension",
    "com-eventbrite-attendee", "content", "cvs", "dlna-playsingle",
    "dlna-playcontainer", "dtn", "dvb", "ed2k", "facetime", "feed",
    "finger", "fish", "gg", "git", "gizmoproject", "gtalk", "hcp", "icon",
    "ipn", "irc", "irc6", "ircs", "itms", "jar", "jms", "keyparc", "lastfm",
    "ldaps", "magnet", "maps", "market", "message", "mms", "ms-help",
    "msnim", "mumble", "mvn", "notes", "oid", "palm", "paparazzi",
    "platform", "proxy", "psyc", "query", "res", "resource", "rmi", "rsync",
    "rtmp", "secondlife", "sftp", "sgn", "skype", "smb", "soldat",
    "spotify", "ssh", "steam", "svn", "teamspeak", "things", "udp",
    "unreal", "ut2004", "ventrilo", "view-source", "webcal", "wtai",
    "wyciwyg", "xfire", "xri", "ymsgr"
  ];


  RegExp autolinkEmailRegExp = new RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
    r"[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");


  Parser<List<Inline>> get autolink => new Parser<List<Inline>>((String s, Position pos) {
    ParseResult res = (char('<') >
      pred((String char) => char.codeUnitAt(0) > 0x20 && char != "<" && char != ">").manyUntil(char('>'))).run(s, pos);
    if (!res.isSuccess) {
      return res;
    }
    String contents = res.value.join();
    int colon = contents.indexOf(":");
    if (colon >= 1) {
      String schema = contents.substring(0, colon).toLowerCase();
      if (allowedSchemes.contains(schema)) {
        return res.copy(value: [new Autolink(contents)]);
      }
    }

    if (contents.contains(autolinkEmailRegExp)) {
      return res.copy(value: [new Autolink.email(contents)]);
    }

    return fail.run(s, pos);
  });


  //
  // raw html
  //

  Parser get rawInlineHtml => choice([
      htmlOpenTag,
      htmlCloseTag,
      htmlCompleteComment,
      htmlCompletePI,
      htmlDeclaration,
      htmlCompleteCDATA
  ]) ^ (result) => [new HtmlRawInline(result)];


  //
  // Line break
  //

  Parser lineBreak = (((string('  ') < whitespaceChar.many) < newline) | string("\\\n")) ^ (_) => [new LineBreak()];


  //
  // str
  //

  static final RegExp _nbspRegExp = new RegExp("\u{a0}");
  static List<Inline> _transformString(String str) {
    Match m = _nbspRegExp.firstMatch(str);
    List<Inline> result = [];
    while (m != null) {
      if (m.start > 0) {
        result.add(new Str(str.substring(0, m.start)));
      }
      result.add(new NonBreakableSpace());
      str = str.substring(m.end);
      m = _nbspRegExp.firstMatch(str);
    }
    if (str.length > 0) {
      result.add(new Str(str));
    }
    return result;
  }


  static final Parser smartPunctuation = (string("...") ^ (_) => [new Ellipsis()]) |
    (char("-") > char("-").many1) ^ (res) {
      /*
        From spec.

        A sequence of more than three hyphens is
        parsed as a sequence of em and/or en dashes,
        with no hyphens. If possible, a homogeneous
        sequence of dashes is used (so, 10 hyphens
        = 5 en dashes, and 9 hyphens = 3 em dashes).
        When a heterogeneous sequence must be used,
        the em dashes come first, followed by the en
        dashes, and as few en dashes as possible are
        used (so, 7 hyphens = 2 em dashes an 1 en
        dash).
       */
      int len = res.length + 1;
      if (len % 3 == 0) {
        return new List.filled(len ~/ 3, new MDash());
      }
      if (len % 2 == 0) {
        return new List.filled(len ~/ 2, new NDash());
      }
      List result = [];
      if (len % 3 == 2) {
        result.addAll(new List.filled(len ~/ 3, new MDash()));
        result.add(new NDash());
      } else {
        result.addAll(new List.filled(len ~/ 3 - 1, new MDash()));
        result.addAll([new NDash(), new NDash()]);
      }

      return result;
    };


  Parser get str => (noneOf(_strSpecialChars + "\n").many1 ^ (chars) => _transformString(chars.join())) |
    (oneOf(_strSpecialChars) ^ (chars) => _transformString(chars)) |
    (char("\n").notFollowedBy(spnl) ^ (_) => [new Str("\n")]);


  Parser<List<Inline>> get inline => choice([
      lineBreak,
      whitespace,
      escapedChar,
      htmlEntity,
      inlineCode,
      emphasis,
      link,
      image,
      autolink,
      rawInlineHtml,
      _options.smartPunctuation ? smartPunctuation : fail,
      str
  ]);

  Parser<List<Inline>> get spaceEscapedInline =>
    (string(r'\ ') ^ (_) => [new _EscapedSpace()]) |
    inline;


  Parser<Inlines> get inlines => inline.manyUntil(eof) ^ (res) => processParsedInlines(res);


  //
  // Blocks
  //

  Parser<List<Block>> get block => choice([
      blanklines ^ (_) => [],
      hrule,
      list,
      codeBlockIndented,
      codeBlockFenced,
      atxHeader,
      setextHeader,
      rawHtml,
      linkReference,
      blockquote,
      para
  ]);

  Parser<List<Block>> get lazyLineBlock => choice([
      blanklines ^ (_) => [],
      hrule,
      list,
      codeBlockFenced,
      atxHeader,
      setextHeader,
      rawHtml,
      linkReference,
      blockquote,
      para
  ]);


  Parser<List<Block>> get listTightBlock => choice([
      hrule,
      codeBlockIndented,
      codeBlockFenced,
      atxHeader,
      setextHeader,
      rawHtml,
      linkReference,
      blockquote,
      para
  ]);


  //
  // Horizontal rule
  //

  static const String hruleChars = '*-_';

  static Parser get hrule => new Parser((String s, Position pos) {
    ParseResult startRes = (skipNonindentCharsFromAnyPosition > oneOf(hruleChars)).run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    var start = startRes.value;

    return ((((count(2, skipSpaces > char(start)) > (whitespaceChar | char(start)).skipMany) > newline) > blanklines.maybe) >
      success([new HorizontalRule()])).run(s, startRes.position);
  });


  //
  // ATX Header
  //

  Parser get atxHeader => new Parser((String s, Position pos) {
    Parser startParser = skipNonindentChars > char('#').many1;
    ParseResult startRes = startParser.run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    int level = startRes.value.length;
    if (level > 6) {
      return fail.run(s, pos);
    }

    // Try empty
    ParseResult textRes = (((whitespaceChar > skipSpaces) > (char('#').many > blankline)) |
      (newline ^ (_) => [])).run(s, startRes.position);
    if (textRes.isSuccess) {
      return textRes.copy(value: [new AtxHeader(level, new _UnparsedInlines(''))]);
    }
    textRes = (((whitespaceChar > skipSpaces) > (escapedChar.record | anyChar).manyUntil((string(' #') > char('#').many).maybe > blankline)) |
      (newline ^ (_) => [])).run(s, startRes.position);
    if (!textRes.isSuccess) {
      return textRes;
    }
    String raw = textRes.value.join();
    _UnparsedInlines inlines = new _UnparsedInlines(raw.trim());
    return textRes.copy(value: [new AtxHeader(level, inlines)]);
  });


  //
  // Setext Header
  //

  static const String setextHChars = "=-";

  Parser get setextHeader => new Parser((String s, Position pos) {
    ParseResult res = (((skipNonindentChars.notFollowedBy(char('>')) > anyLine) +
      (skipNonindentChars > oneOf(setextHChars).many1)).list < blankline).run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    String raw = res.value[0];
    int level = res.value[1][0] == '=' ? 1 : 2;
    _UnparsedInlines inlines = new _UnparsedInlines(raw.trim());
    return res.copy(value: [new SetextHeader(level, inlines)]);
  });


  //
  // Indented code
  //

  Parser get indentedLine => (indent > anyLine) ^ (line) => line + "\n";

  Parser get codeBlockIndented => (indentedLine +
    ((indentedLine | (blanklines + indentedLine) ^ (b, l) => b.join('') + l).many)) ^
      (f, c) => [new IndentedCodeBlock(stripTrailingNewlines(f + c.join('')) + '\n')];


  //
  // Fenced code
  //

  // TODO static ?
  Parser get openFence => new Parser((String s, Position pos) {
    Parser fenceStartParser = (skipNonindentCharsFromAnyPosition + (string('~~~') | string('```'))).list;
    ParseResult fenceStartRes = fenceStartParser.run(s, pos);
    if (!fenceStartRes.isSuccess) {
      return fenceStartRes;
    }
    int indent = fenceStartRes.value[0];
    String fenceChar = fenceStartRes.value[1][0];

    Parser infoStringParser = ((skipSpaces > (noneOf("&\n\\ " + fenceChar) | escapedChar1 | htmlEntity1 | oneOf('&\\')).many) <
      noneOf("\n" + fenceChar).many) < newline;
    Parser topFenceParser = (char(fenceChar).many + infoStringParser).list;
    ParseResult topFenceRes = topFenceParser.run(s, fenceStartRes.position);
    if (!topFenceRes.isSuccess) {
      return topFenceRes;
    }

    int fenceSize = topFenceRes.value[0].length + 3;
    String infoString = topFenceRes.value[1].join();
    return topFenceRes.copy(value: [indent, fenceChar, fenceSize, infoString]);
  });


  Parser get codeBlockFenced => new Parser((String s, Position pos) {
    ParseResult openFenceRes = openFence.run(s, pos);
    if (!openFenceRes.isSuccess) {
      return openFenceRes;
    }
    int indent = openFenceRes.value[0] + pos.character - 1;
    String fenceChar = openFenceRes.value[1];
    int fenceSize = openFenceRes.value[2];
    String infoString = openFenceRes.value[3];

    FenceType fenceType = FenceType.backtick;
    if (fenceChar == '~') {
      fenceType = FenceType.tilde;
    }

    Parser lineParser = anyLine;
    if (indent > 0) {
      lineParser = atMostIndent(indent) > lineParser;
    }
    Parser endFenceParser = (((skipNonindentChars > string(fenceChar * fenceSize)) > char(fenceChar).many) > skipSpaces) > newline;
    Parser restParser = (lineParser.manyUntil(endFenceParser) ^
        (lines) => [new FencedCodeBlock(lines.map((i) => i + '\n').join(),
            fenceType: fenceType, fenceSize: fenceSize, attributes: new InfoString(infoString))])
      | (lineParser.manyUntil(eof) ^ (List lines) {
        return [new FencedCodeBlock(lines.map((l) => l + '\n').join(),
            fenceType: fenceType, fenceSize: fenceSize, attributes: new InfoString(infoString))];
      });

    return restParser.run(s, openFenceRes.position);
  });


  //
  // Raw html block
  //

  static final List<Map<String, Pattern>> rawHtmlTests = [
    { // <script>, <pre> or <style>
      "start": new RegExp(r'^(script|pre|style)( |>|$)', caseSensitive: false), // TODO \t
      "end": new RegExp(r'</(script|pre|style)>', caseSensitive: false)
    },
    { // <!-- ... -->
      "start": new RegExp(r'^!--'),
      "end": "-->"
    },
    { // <? ... ?>
      "start": new RegExp(r'^\?'),
      "end": "?>"
    },
    { // <!... >
      "start": new RegExp(r'^![A-Z]'),
      "end": ">"
    },
    { // <![CDATA[
      "start": new RegExp(r'^!\[CDATA\['),
      "end": "]]>"
    }
  ];
  static final Pattern rawHtmlTest6 = new RegExp(r'^/?([a-zA-Z]+)( |>|$)');  // TODO \t
  Parser get rawHtmlParagraphStopTest => new Parser((String s, Position pos) {
    // Simple test
    ParseResult testRes = (skipNonindentChars < char('<')).record.run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }

    ParseResult lineRes = anyLine.run(s, testRes.position);
    assert(lineRes.isSuccess);
    Map<String, Pattern> passedTest = rawHtmlTests.firstWhere((element) {
      return lineRes.value.contains(element['start']);
    }, orElse: () => null);
    if (passedTest != null) {
      return success(true).run(s, pos);
    }

    Match match = rawHtmlTest6.matchAsPrefix(lineRes.value);
    if (match != null && _allowedTags.contains(match.group(1).toLowerCase())) {
      return success(true).run(s, pos);
    }

    return fail.run(s, pos);
  });

  Parser get rawHtml => new Parser((String s, Position pos) {
    // Simple test
    ParseResult testRes = (skipNonindentChars < char('<')).record.run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }

    var content = testRes.value;

    ParseResult lineRes = anyLine.run(s, testRes.position);
    assert(lineRes.isSuccess);
    Map<String, Pattern> passedTest = rawHtmlTests.firstWhere((element) {
      return lineRes.value.contains(element['start']);
    }, orElse: () => null);
    if (passedTest != null) {
      // Got it
      content += lineRes.value + '\n';
      var position = lineRes.position;
      while(!lineRes.value.contains(passedTest['end'])) {
        lineRes = anyLine.run(s, position);
        if (!lineRes.isSuccess) {
          // eof
          return success(new HtmlRawBlock(content)).run(s, position);
        }
        content += lineRes.value + '\n';
        position = lineRes.position;
      }
      return lineRes.copy(value: new HtmlRawBlock(content));
    }

    Match match = rawHtmlTest6.matchAsPrefix(lineRes.value);
    var position;
    if (match == null || !_allowedTags.contains(match.group(1).toLowerCase())) {
      // Trying rule 7

      var rule7Res = ((skipNonindentChars < (htmlOpenTag | htmlCloseTag)) < blankline).record.run(s, pos);
      if (!rule7Res.isSuccess || rule7Res.value.indexOf('\n') != rule7Res.value.length - 1) {
        // There could be only one \n, and it's in the end.
        return fail.run(s, pos);
      }


      content = rule7Res.value;
      position = rule7Res.position;
    } else {
      content += lineRes.value + '\n';
      position = lineRes.position;
    }

    do {
      var blanklineRes = blankline.run(s, position);
      if (blanklineRes.isSuccess) {
        return success(new HtmlRawBlock(content)).run(s, blanklineRes.position);
      }
      lineRes = anyLine.run(s, position);
      if (!lineRes.isSuccess) {
        // eof
        return success(new HtmlRawBlock(content)).run(s, position);
      }
      content += lineRes.value + '\n';
      position = lineRes.position;
    } while(true);
  });


  //
  // Link reference
  //

  Parser get linkReference => new Parser((String s, Position pos) {
    var labelRes = ((skipNonindentChars > linkLabel) < char(':')).run(s, pos);
    if (!labelRes.isSuccess) {
      return labelRes;
    }
    var destinationRes = ((blankline.maybe > skipSpaces) >
        linkBlockDestination).run(s, labelRes.position);
    if (!destinationRes.isSuccess) {
      return destinationRes;
    }
    ParseResult<Option> blanklineRes = blankline.maybe.run(s, destinationRes.position);
    assert(blanklineRes.isSuccess);
    var titleRes = ((skipSpaces > linkTitle) < blankline).run(s, blanklineRes.position);

    var value;
    ParseResult res;
    if (!titleRes.isSuccess) {
      if (blanklineRes.value.isDefined) {
        value = new _LinkReference(labelRes.value, new Target(destinationRes.value, null));
        res = blanklineRes;
      } else {
        return fail.run(s, pos);
      }
    } else {
      value = new _LinkReference(labelRes.value, new Target(destinationRes.value, titleRes.value));
      res = titleRes;
    }

    // Reference couldn't be empty
    if (value.reference.contains(new RegExp(r"^\s*$"))) {
      return fail.run(s, pos);
    }
    return res.copy(value: value);
  });

  //
  // Paragraph
  //

  Parser get para => new Parser((String s, Position pos) {
    Parser end = blankline
      | hrule
      | listMarkerTest(4)
      | atxHeader
      | openFence
      | rawHtmlParagraphStopTest
      | (skipNonindentChars > (
        char('>')
        | (oneOf('+-*') > whitespaceChar)
        | ((countBetween(1, 9, digit) > oneOf('.)')) > whitespaceChar)));
    ParseResult res = (end.notAhead > anyLine).many1.run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    _UnparsedInlines inlines = new _UnparsedInlines(res.value.join("\n").trim());
    return res.copy(value: [new Para(inlines)]);
  });


  //
  // Lazy line aux function
  //

  /// Trying to add current line as lazy to nested list blocks.
  ///
  /// Returns `true` when line was accepted.
  bool _acceptLazy(Iterable<Block> blocks, String s) {
    if (blocks.length > 0) {
      if (blocks.last is Para) {
        Para last = blocks.last;
        (last.contents as _UnparsedInlines).raw += "\n" + s;
        return true;
      } else if (blocks.last is Blockquote) {
        Blockquote last = blocks.last;
        return _acceptLazy(last.contents, s);
      } else if (blocks.last is ListBlock) {
        ListBlock last = blocks.last;
        return _acceptLazy(last.items.last.contents, s);
      }
    }

    return false;
  }


  //
  // Blockquote
  //

  static Parser blockquoteStrictLine = ((skipNonindentChars > char('>')) > whitespaceChar.maybe) > anyLine; // TODO check tab
  static Parser blockquoteLine = (blockquoteStrictLine ^ (l) => [true, l])
    | (anyLine ^ (l) => [false, l]);


  Parser get blockquote => new Parser((String s, Position pos) {
    ParseResult firstLineRes = blockquoteStrictLine.run(s, pos);
    if (!firstLineRes.isSuccess) {
      return firstLineRes;
    }
    List<String> buffer = [firstLineRes.value];
    List<Block> blocks = [];

    bool closeParagraph = false;

    void buildBuffer() {
      String s = buffer.map((l) => l + "\n").join();
      List<Block> innerRes = (block.manyUntil(eof) ^ (res) => processParsedBlocks(res)).parse(s, tabStop: tabStop);
      if (!closeParagraph && innerRes.length > 0 && innerRes.first is Para) {
        Para first = innerRes.first;
        if (_acceptLazy(blocks, (first.contents as _UnparsedInlines).raw)) {
          innerRes.removeAt(0);
        }
      }
      if (innerRes.length > 0) {
        blocks.addAll(innerRes);
      }
      buffer = [];
    }

    Position position = firstLineRes.position;
    while(true) {
      ParseResult res = blockquoteLine.run(s, position);
      if (!res.isSuccess) {
        break;
      }
      bool isStrict = res.value[0];
      String line = res.value[1];
      if (isStrict) {
        closeParagraph = line.trim() == "";
        buffer.add(line);
      } else {
        if (buffer.length > 0) {
          buildBuffer();
          List<Block> lineBlock = lazyLineBlock.parse(line + "\n", tabStop: tabStop);
          // TODO fix condition
          if (!closeParagraph && lineBlock.length == 1 && lineBlock[0] is Para) {
            Para block = lineBlock[0];
            if (!_acceptLazy(blocks, (block.contents as _UnparsedInlines).raw)) {
              break;
            }
          } else {
            break;
          }
        }
      }
      position = res.position;
    }

    if (buffer.length > 0) {
      buildBuffer();
    }

    return firstLineRes.copy(position: position, value: [new Blockquote(blocks)]);
  });


  //
  // Lists
  //

  static const _listTypeOrdered = 0;
  static const _listTypeUnordered = 1;
  static ParserAccumulator3 orderedListMarkerTest(int indent) =>
      skipListIndentChars(indent) +
          countBetween(1, 9, digit) + // 1-9 digits
          oneOf('.)');
  static ParserAccumulator2 unorderedListMarkerTest(int indent) =>
      skipListIndentChars(indent).notFollowedBy(hrule) +
          oneOf('-+*');
  static Parser listMarkerTest(int indent) => (
      (
          (orderedListMarkerTest(indent) ^ (sp, d, c) => [_listTypeOrdered, sp, d, c]) |
          (unorderedListMarkerTest(indent) ^ (sp, c) => [_listTypeUnordered, sp, c])
      ) +
      (
          char("\n") |
          countBetween(1, 4, char(' ')).notFollowedBy(char(' ')) |
          oneOf(' \t')
      )
  ).list;

  Parser get list => new Parser((String s, Position pos) {
    // TODO quick test
    List<_ListStackItem> stack = [];

    int getSubIndent() => stack.length > 0 ? stack.last.subIndent : 0;
    int getIndent() => stack.length > 0 ? stack.last.indent : 0;
    bool getTight() => stack.length > 0 ? stack.last.block.tight : true;
    void setTight(bool tight) {
      if (stack.length > 0) {
        stack.last.block.tight = tight;
      }
    }

    /// Is previous parsed line was empty?
    bool afterEmptyLine = false;
    bool markerOnSaparateLine = false;
    List<Block> blocks = [];
    List<String> buffer = [];
    void buildBuffer() {
      String s = buffer.map((l) => l + "\n").join();
      List<Block> innerBlocks;
      if (s == "\n" && blocks.length == 0) {
        // Test for empty items
        blocks = [];
        buffer = [];
        return;
      }
      if (getTight()) {
        ParseResult innerRes = (listTightBlock.manyUntil(eof) ^ (res) => processParsedBlocks(res)).run(s);
        if (innerRes.isSuccess) {
          innerBlocks = innerRes.value;
        } else {
          setTight(false);
        }
      }

      if (!getTight()) {
        innerBlocks = (block.manyUntil(eof) ^ (res) => processParsedBlocks(res)).parse(s, tabStop: tabStop);
      }
      if (!afterEmptyLine && innerBlocks.length > 0 && innerBlocks.first is Para &&
          _acceptLazy(blocks, ((innerBlocks.first as Para).contents as _UnparsedInlines).raw)) {
        innerBlocks.removeAt(0);
      }
      if (innerBlocks.length > 0) {
        blocks.addAll(innerBlocks);
      }
      buffer = [];
    }

    void addToListItem(ListItem item, Iterable<Block> c) {
      if (item.contents is List) {
        (item.contents as List).addAll(c);
        return;
      }
      List<Block> contents = new List.from(item.contents);
      contents.addAll(c);
      item.contents = contents;
    }

    bool addListItem(int type, {IndexSeparator indexSeparator, BulletType bulletType}) {
      bool success = false;
      if (stack.length == 0) {
        return false;
      }
      ListBlock block = stack.last.block;
      if (type == _listTypeOrdered && block is OrderedList && block.indexSeparator == indexSeparator) {
        success = true;
      }
      if (type == _listTypeUnordered && block is UnorderedList && block.bulletType == bulletType) {
        success = true;
      }
      if (success) {
        if (afterEmptyLine) {
          setTight(false);
          afterEmptyLine = false;
        }
        buildBuffer();
        addToListItem(block.items.last, blocks);
        blocks = [];
        if (block.items is List) {
          (block.items as List).add(new ListItem([]));
        } else {
          List<ListItem> list = new List.from(block.items);
          list.add(new ListItem([]));
          block.items = list;
        }
      }
      return success;
    }

    Position getNewPositionAfterListMarker(ParseResult res) {
      if (res.value[1] == "\n" || res.value[1].length <= 4) {
        return res.position;
      } else {
        int diff = res.value[1].length - 1;
        return new Position(res.position.offset - diff, res.position.line, res.position.character - diff,
            tabStop: tabStop);
      }
    }

    /// Current parsing position
    Position position = pos; // Current parsing position

    /// Will list item nested inside current?
    bool nextLevel = true;

    // TODO Split loop to smaller parts
    while (true) {
      bool closeListItem = false;
      ParseResult eofRes = eof.run(s, position);
      if (eofRes.isSuccess) {
        // End of input reached
        break;
      }

      // If we at the line start and there's only spaces left then applying new line rules
      if (position.character == 1) {
        ParseResult blanklineRes = blankline.run(s, position);
        if (blanklineRes.isSuccess) {
          if (afterEmptyLine) {
            // It's second new line. Closing all lists.
            break;
          }
          afterEmptyLine = true;
          position = blanklineRes.position;
          continue;
        }
      }

      // Parsing from line start
      if (position.character == 1 && getSubIndent() > 0) {
        // Waiting for indent
        ParseResult indentRes = waitForIndent(getSubIndent()).run(s, position);
        if (indentRes.isSuccess) {
          position = indentRes.position;
          nextLevel = true;
        } else {
          // Trying lazy line
          if (!afterEmptyLine) { // Lazy line couldn't appear after empty line
            if (buffer.length > 0) {
              buildBuffer();
            }

            // TODO Speedup by checking impossible starts
            ParseResult lineRes = anyLine.run(s, position);
            assert(lineRes.isSuccess);
            List<Block> lineBlock = block.parse(lineRes.value.trimLeft() + "\n", tabStop: tabStop);
            if (
              lineBlock.length == 1 &&
              lineBlock[0] is Para &&
              _acceptLazy(blocks, ((lineBlock[0] as Para).contents as _UnparsedInlines).raw)
            ) {
              position = lineRes.position;
              continue;
            }
          }

          if (buffer.length > 0 || blocks.length > 0) {
            buildBuffer();
            addToListItem(stack.last.block.items.last, blocks);
            blocks = [];
          }

          // Closing all nested lists until we found one with enough indent to accept current line
          nextLevel = false;
          while (stack.length > 1) {
            ParseResult indentRes = waitForIndent(getIndent()).run(s, position);
            if (indentRes.isSuccess) {
              position = indentRes.position;
              closeListItem = true;
              break;
            }
            stack.last.block.tight = getTight();
            stack.removeLast();
          }
        }
      }

      // Trying to find new list item

      ParseResult markerRes = listMarkerTest(getIndent() + tabStop).run(s, position);
      if (markerRes.isSuccess) {
        markerOnSaparateLine = false;
        int type = markerRes.value[0][0];
        IndexSeparator indexSeparator = (type == _listTypeOrdered ? IndexSeparator.fromChar(markerRes.value[0][3]) : null);
        int startIndex = type == _listTypeOrdered ? int.parse(markerRes.value[0][2].join(), onError: (_) => 1) : 1;
        BulletType bulletType = (type == _listTypeUnordered ? BulletType.fromChar(markerRes.value[0][2]) : null);

        // It's a new list item on same level
        if (!nextLevel) {
          bool addSuccess = addListItem(type, indexSeparator: indexSeparator, bulletType: bulletType);
          if (!addSuccess) {
            if (stack.length == 1) {
              // It's a new list on top level. Stopping here
              break;
            }
            // New list on same level, so we a closing previous one.
            stack.removeLast();
          } else {
            int subIndent = markerRes.position.character - 1;
            if (markerRes.value[1] == "\n") {
              markerOnSaparateLine = true;
              subIndent = position.character + markerRes.value[0][1] + 1; // marker + space after marker - char
              if (type == _listTypeOrdered) {
                subIndent += markerRes.value[0][2].length;
              }
            }
            stack.last.indent = position.character + markerRes.value[0][1] - 1;
            stack.last.subIndent = getIndent() + subIndent;

            position = getNewPositionAfterListMarker(markerRes);
            continue;
          }
        }

        // Flush buffer
        if (stack.length > 0 && (buffer.length > 0 || blocks.length > 0)) {
          if (afterEmptyLine) {
            setTight(false);
            afterEmptyLine = false;
          }
          buildBuffer();
          addToListItem(stack.last.block.items.last, blocks);
          blocks = [];
        }

        // Ok, it's a new list on new level.
        ListBlock newListBlock;
        int subIndent = markerRes.position.character - 1;
        if (markerRes.value[1] == "\n") {
          markerOnSaparateLine = true;
          subIndent = position.character + markerRes.value[0][1] + 1; // marker + space after marker - char
          if (type == _listTypeOrdered) {
            subIndent += markerRes.value[0][2].length;
          }
        }
        if (type == _listTypeOrdered) {
          newListBlock = new OrderedList([new ListItem([])],
              tight: true, indexSeparator: indexSeparator, startIndex: startIndex);
          //subIndent += markerRes.value[0][2].length;
        } else {
          newListBlock = new UnorderedList([new ListItem([])], tight: true, bulletType: bulletType);
        }

        if (stack.length > 0) {
          addToListItem(stack.last.block.items.last, [newListBlock]);
        }

        int indent = getSubIndent();
        stack.add(new _ListStackItem(indent, subIndent, newListBlock));
        position = getNewPositionAfterListMarker(markerRes);
        nextLevel = true;
        continue;
      } else if (stack.length == 0) {
        // That was first marker test and it's failed. Return with fail.
        return markerRes;
      }

      if (closeListItem) {
        stack.last.block.tight = getTight();
        if (stack.length > 1) {
          stack.removeLast();
        } else {
          break;
        }
      }

      if (position.character > 1) {
        // Fenced code block requires special treatment.
        ParseResult openFenceRes = openFence.run(s, position);
        if (openFenceRes.isSuccess) {
          if (buffer.length > 0) {
            buildBuffer();
          }

          int indent = openFenceRes.value[0] + position.character - 1;
          String fenceChar = openFenceRes.value[1];
          int fenceSize = openFenceRes.value[2];
          String infoString = openFenceRes.value[3];

          FenceType fenceType = FenceType.backtick;
          if (fenceChar == '~') {
            fenceType = FenceType.tilde;
          }

          position = openFenceRes.position;

          Parser indentParser = waitForIndent(indent);
          Parser endFenceParser = (((skipSpaces > string(fenceChar * fenceSize)) > char(fenceChar).many) > skipSpaces) > newline;
          Parser lineParser = anyLine;

          List<String> code = [];
          while (true) {
            ParseResult eofRes = eof.run(s, position);
            if (eofRes.isSuccess) {
              break;
            }

            ParseResult blanklineRes = blankline.run(s, position);
            if (blanklineRes.isSuccess) {
              position = blanklineRes.position;
              code.add("");
              continue;
            }

            ParseResult indentRes = indentParser.run(s, position);
            if (!indentRes.isSuccess) {
              break;
            }
            position = indentRes.position;

            ParseResult endFenceRes = endFenceParser.run(s, position);
            if (endFenceRes.isSuccess) {
              position = endFenceRes.position;
              break;
            }

            ParseResult lineRes = lineParser.run(s, position);
            if (!lineRes.isSuccess) {
              break;
            }
            code.add(lineRes.value);
            position = lineRes.position;
          }

          blocks.add(new FencedCodeBlock(code.map((i) => i + '\n').join(),
              fenceType: fenceType, fenceSize: fenceSize, attributes: new InfoString(infoString)));
          afterEmptyLine = false;
          continue;
        }

        if (markerOnSaparateLine && afterEmptyLine) {
          // A list item can begin with at most one blank line.
          break;
        }

        // Strict line
        ParseResult lineRes = anyLine.run(s, position);
        assert(lineRes.isSuccess);
        if (afterEmptyLine) {
          buffer.add("");
          afterEmptyLine = false;
        }
        buffer.add(lineRes.value);
        position = lineRes.position;
      } else {
        break;
      }
    }

    // End
    if (stack.length > 0) {
      if (buffer.length > 0 || blocks.length > 0) {
        buildBuffer();
        addToListItem(stack.last.block.items.last, blocks);
      }

      return success([stack.first.block]).run(s, position);
    } else {
      return fail.run(s, pos);
    }
  });


  //
  // Document
  //

  Parser get document => (block.manyUntil(eof) ^ (res) => new Document(processParsedBlocks(res))) % "document";


  static CommonMarkParser commonmark = new CommonMarkParser(Options.commonmark);
  static CommonMarkParser defaults = new CommonMarkParser(Options.defaults);
  static CommonMarkParser strict = new CommonMarkParser(Options.strict);
}
