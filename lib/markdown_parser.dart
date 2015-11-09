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

  bool operator ==(dynamic obj) => obj is _UnparsedInlines && raw == obj.raw;

  int get hashCode => raw.hashCode;
}

RegExp _trimAndReplaceSpacesRegExp = new RegExp(r'\s+');
String _trimAndReplaceSpaces(String s) {
  return s.trim().replaceAll(_trimAndReplaceSpacesRegExp, ' ');
}

String _normalizeReference(String s) => _trimAndReplaceSpaces(s).toUpperCase();

// TODO make constructors in ParseResult (new ParseResult.success)

ParseResult /*<E>*/ _success(
    dynamic /*E*/ value, String text, Position position,
    [Expectations expectations, bool committed = false]) {
  final Expectations exps =
      (expectations != null) ? expectations : new Expectations.empty(position);
  return new ParseResult(text, exps, position, true, committed, value);
}

ParseResult _failure(String text, Position position,
    [Expectations expectations, bool committed = false]) {
  final Expectations exps =
      (expectations != null) ? expectations : new Expectations.empty(position);
  return new ParseResult(text, exps, position, false, committed, null);
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

  bool operator ==(dynamic obj) => obj is _EscapedSpace;

  int get hashCode => 0;
}

// TODO make aux parsers private

// TODO provide generic types to Parser where possible
// TODO provide generic types to ParseResult where possible

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

  _EmphasisStackItem(this.char, this.numDelims, this.inlines,
      {this.cantCloseAnyway: false});
}

// TODO make const parsers 'final'

// CommonMark parser
class CommonMarkParser {
  static const int tabStop = 4;

  Options _options;

  Map<String, Target> _references;

  Set<String> _inlineDelimiters;
  Set<String> _strSpecialChars;
  Set<String> _intrawordDelimiters;

  CommonMarkParser(this._options, [this._references]) {
    _inlineDelimiters = new Set<String>.from(["_", "*"]);
    _strSpecialChars = new Set<String>.from(
        [" ", "*", "_", "`", "!", "[", "]", "&", "<", "\\"]);
    _intrawordDelimiters = new Set<String>.from(["*"]);
    if (_options.smartPunctuation) {
      _inlineDelimiters.addAll(["'", "\""]);
      _strSpecialChars.addAll(["'", "\"", ".", "-"]);
    }
    if (_options.strikeout || _options.subscript) {
      _inlineDelimiters.add("~");
      _strSpecialChars.add("~");
      _intrawordDelimiters.add("~");
    }
    if (_options.superscript) {
      _inlineDelimiters.add('^');
      _strSpecialChars.add('^');
      _intrawordDelimiters.add('^');
    }
  }

  Document parse(String s) {
    // TODO separate preprocess option

    _references = {};

    s = preprocess(s);
    if (!s.endsWith("\n")) {
      s += "\n";
    }
    Document doc = document.parse(s, tabStop: tabStop);

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
      Inlines contents = block.contents;
      if (contents is _UnparsedInlines) {
        block.contents = _parseInlines(contents.raw);
      }
    } else if (block is Para) {
      Inlines contents = block.contents;
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

    for (dynamic item in list) {
      if (item is Iterable) {
        result.addAll(flatten(item));
      } else {
        result.add(item);
      }
    }

    return result;
  }

  static String stripTrailingNewlines(String str) {
    int l = str.length;
    while (l > 0 && str[l - 1] == '\n') {
      --l;
    }
    return str.substring(0, l);
  }

  //
  // Aux parsers
  //

  static final Parser<String> anyLine = new Parser((String s, Position pos) {
    String result = '';
    int offset = pos.offset, len = s.length;
    if (offset >= len) {
      return new ParseResult(
          s, new Expectations.empty(pos), pos, false, false, null);
    }
    while (offset < len && s[offset] != '\n') {
      result += s[offset];
      ++offset;
    }
    Position newPos;
    if (offset < len && s[offset] == '\n') {
      newPos = new Position(offset + 1, pos.line + 1, 1, tabStop: tabStop);
    } else {
      newPos = new Position(offset, pos.line, pos.character + result.length,
          tabStop: tabStop);
    }
    return _success(result, s, newPos);
  });

  static final Parser<String> whitespaceChar = oneOf(" \t");
  static final Parser<String> nonSpaceChar = noneOf("\t\n \r");
  static final Parser skipSpaces = whitespaceChar.skipMany;
  static final Parser<String> blankline = skipSpaces > newline;
  static final Parser<List<String>> blanklines = blankline.many1;

  // All indent and spaces parsers accepts spaces to skip, and returns spaces
  // that were actually skipped.
  // TODO test all parsers that use skipNonindentSpaces, skipListNonindentSpaces, indentSpaces, atMostSpaces
  // TODO rename indentSpaces => indent, atMostSpaces => atMostIndent
  static final Parser<int> skipNonindentChars =
      atMostIndent(tabStop - 1).notFollowedBy(whitespaceChar);
  static final Parser<int> skipNonindentCharsFromAnyPosition =
      atMostIndent(tabStop - 1, fromLineStart: false)
          .notFollowedBy(whitespaceChar);
  static Parser<int> skipListIndentChars(int max) =>
      (atMostIndent(max - 1) | atMostIndent(tabStop - 1, fromLineStart: false))
          .notFollowedBy(whitespaceChar);
  static final Parser<String> spnl = (skipSpaces > newline);
  static final Parser<int> indent = waitForIndent(tabStop);

  static Map<int, Parser<int>> _atMostIndentCache = {};
  static Map<int, Parser<int>> _atMostIndentStartCache = {};
  static Parser<int> atMostIndent(int indent, {bool fromLineStart: true}) {
    if (fromLineStart && _atMostIndentStartCache[indent] != null) {
      return _atMostIndentStartCache[indent];
    }
    if (!fromLineStart && _atMostIndentCache[indent] != null) {
      return _atMostIndentCache[indent];
    }

    Parser<int> p = new Parser((String s, Position pos) {
      if (fromLineStart && pos.character != 1) {
        return _failure(s, pos);
      }
      int startCharacter = pos.character;
      int maxEndCharacter = indent + startCharacter;
      Position position = pos;
      while (position.character <= maxEndCharacter) {
        ParseResult<String> res = whitespaceChar.run(s, position);
        if (!res.isSuccess || res.position.character > maxEndCharacter) {
          return _success(position.character - startCharacter, s, position);
        }
        position = res.position;
      }
      return _success(position.character - startCharacter, s, position);
    });
    if (fromLineStart) {
      _atMostIndentStartCache[indent] = p;
    } else {
      _atMostIndentCache[indent] = p;
    }
    return p;
  }

  static Map<int, Parser<int>> _waitForIndentCache = {};
  static Parser<int> waitForIndent(int length) {
    if (_waitForIndentCache[length] == null) {
      _waitForIndentCache[length] = new Parser((String s, Position pos) {
        if (pos.character != 1) {
          return _failure(s, pos);
        }
        int startCharacter = pos.character;
        Position position = pos;
        while (position.character <= length) {
          ParseResult<String> res = whitespaceChar.run(s, position);
          if (!res.isSuccess) {
            return res;
          }
          position = res.position;
        }
        return _success(position.character - startCharacter, s, position);
      });
    }

    return _waitForIndentCache[length];
  }

  static Parser<List /*<A>*/ > count(int l, Parser /*<A>*/ p) =>
      countBetween(l, l, p);

  static Parser<List /*<A>*/ > countBetween(
          int min, int max, Parser /*<A>*/ p) =>
      new Parser((String s, Position pos) {
        Position position = pos;
        List /*<A>*/ value = [];
        ParseResult res;
        for (int i = 0; i < max; ++i) {
          res = p.run(s, position);
          if (res.isSuccess) {
            value.add(res.value);
            position = res.position;
          } else if (i < min) {
            return _failure(s, pos);
          } else {
            return _success(value, s, position);
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
  static final Set<String> _allowedTags = new Set.from([
    "address",
    "article",
    "aside",
    "base",
    "basefont",
    "blockquote",
    "body",
    "caption",
    "center",
    "col",
    "colgroup",
    "dd",
    "details",
    "dialog",
    "dir",
    "div",
    "dl",
    "dt",
    "fieldset",
    "figcaption",
    "figure",
    "footer",
    "form",
    "frame",
    "frameset",
    "h1",
    "head",
    "header",
    "hr",
    "html",
    "iframe",
    "legend",
    "li",
    "link",
    "main",
    "menu",
    "menuitem",
    "meta",
    "nav",
    "noframes",
    "ol",
    "optgroup",
    "option",
    "p",
    "param",
    "section",
    "source",
    "summary",
    "table",
    "tbody",
    "td",
    "tfoot",
    "th",
    "thead",
    "title",
    "tr",
    "track",
    "ul"
  ]);

  static final Parser<String> spaceOrNL = oneOf(" \t\n");

  static final Parser<String> htmlTagName =
      (letter > oneOf(_alphanum + "-").many).record;
  static final Parser<String> htmlAttributeName =
      (oneOf(_alpha + "_:") > oneOf(_alphanum + "_.:-").many).record;
  static final Parser<String> htmlAttributeValue = (spaceOrNL.many +
      char('=') +
      spaceOrNL.many +
      (htmlUnquotedAttributeValue |
          htmlSingleQuotedAttributeValue |
          htmlDoubleQuotedAttributeValue)).list.record;
  static final Parser<List<String>> htmlUnquotedAttributeValue =
      noneOf(" \t\n\"'=<>`").many1;
  static final Parser<List<String>> htmlSingleQuotedAttributeValue =
      (char("'") > noneOf("'").many) < char("'");
  static final Parser<List<String>> htmlDoubleQuotedAttributeValue =
      (char('"') > noneOf('"').many) < char('"');
  static final Parser<String> htmlAttribute = (spaceOrNL.many1 +
      htmlAttributeName +
      htmlAttributeValue.maybe).list.record;
  static final Parser<String> htmlOpenTag =
      (((((char("<") > htmlTagName) < htmlAttribute.many) < spaceOrNL.many) <
              char('/').maybe) <
          char('>')).record;
  static final Parser<String> htmlCloseTag =
      (((string("</") > htmlTagName) < spaceOrNL.many) < char('>')).record;
  static final Parser<String> _htmlCompleteComment = (string('<!--')
          .notFollowedBy(char('>') | string('->')) >
      anyChar.manyUntil(string('--'))).record;
  static final Parser<String> htmlCompleteComment =
      new Parser<String>((String s, Position pos) {
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
  static final Parser<String> htmlCompletePI =
      (string('<?') > anyChar.manyUntil(string('?>'))).record;
  static final Parser<String> htmlDeclaration = (string('<!') +
      upper.many1 +
      spaceOrNL.many1 +
      anyChar.manyUntil(char('>'))).list.record;
  static final Parser<String> htmlCompleteCDATA =
      (string('<![CDATA[') > anyChar.manyUntil(string(']]>'))).record;

  //
  // Links aux parsers
  //

  // Can't be static because of str
  Parser _linkTextChoiceCache;
  Parser get _linkTextChoice {
    if (_linkTextChoiceCache == null) {
      _linkTextChoiceCache = choice([
        whitespace,
        htmlEntity,
        inlineCode,
        autolink,
        rawInlineHtml,
        escapedChar,
        rec(() => linkText),
        str
      ]);
    }
    return _linkTextChoiceCache;
  }

  Parser _linkTextCache;
  Parser get linkText {
    if (_linkTextCache == null) {
      _linkTextCache = (char('[') >
              (_linkTextChoice + _linkTextChoice.manyUntil(char(']')))
                  .list
                  .record) ^
          (String label) => label.substring(0, label.length - 1);
    }
    return _linkTextCache;
  }

  Parser _imageTextCache;
  Parser get imageText {
    if (_imageTextCache == null) {
      _imageTextCache = (char('[') >
              _linkTextChoice.manyUntil(char(']')).record) ^
          (String label) => label.substring(0, label.length - 1);
    }
    return _imageTextCache;
  }

  static final String _linkLabelStrSpecialChars = " *_`!<\\";
  static final Parser<List<Inline>> _linkLabelStr =
      (noneOf(_linkLabelStrSpecialChars + "[]\n").many1 ^
              (List<String> chars) => _transformString(chars.join())) |
          (oneOf(_linkLabelStrSpecialChars) ^
              (String chars) => _transformString(chars)) |
          (char("\n").notFollowedBy(spnl) ^ (String _) => [new Str("\n")]);

  static final Parser<String> linkLabel = (char('[') >
          choice([
            whitespace,
            htmlEntity,
            inlineCode,
            autolink,
            rawInlineHtml,
            escapedChar,
            _linkLabelStr
          ]).manyUntil(char(']')).record) ^
      (String label) => label.substring(0, label.length - 1);

  static final Parser<String> linkBalancedParenthesis = ((char("(") >
              (noneOf('&\\\n ()') | escapedChar1 | htmlEntity1 | oneOf('&\\'))
                  .many1) <
          char(')')) ^
      (List<String> i) => "(${i.join()})";

  static final Parser<String> linkInlineDestination =
      (((char("<") > noneOf("<>\n").many) < char(">")) |
              (noneOf("&\\\n ()") |
                  escapedChar1 |
                  htmlEntity1 |
                  linkBalancedParenthesis |
                  oneOf('&\\')).many) ^
          (List<String> i) => i.join();

  static final Parser<String> linkBlockDestination =
      (((char("<") > noneOf("<>\n").many1) < char(">")) |
              (noneOf("&\\\n ()") |
                  escapedChar1 |
                  htmlEntity1 |
                  linkBalancedParenthesis |
                  oneOf('&\\')).many1) ^
          (List<String> i) => i.join();

  static final Parser<String> oneNewLine = newline.notFollowedBy(blankline);
  static final Parser<String> linkTitle = (((char("'") >
                  (noneOf("'&\\\n") |
                      oneNewLine |
                      escapedChar1 |
                      htmlEntity1 |
                      oneOf('&\\')).many) <
              char("'")) |
          ((char('"') >
                  (noneOf('"&\\\n') |
                      oneNewLine |
                      escapedChar1 |
                      htmlEntity1 |
                      oneOf('&\\')).many) <
              char('"')) |
          ((char('(') >
                  (noneOf(')&\\\n') |
                      oneNewLine |
                      escapedChar1 |
                      htmlEntity1 |
                      oneOf('&\\')).many) <
              char(')'))) ^
      (List<String> i) => i.join();

  //
  // Inlines
  //

  //
  // whitespace
  //

  static final Parser<List<Inline>> whitespace = (char(' ') ^
          (String _) => [new Space()]) |
      (char('\t') ^ (String _) => [new Tab()]);

  // TODO better escaped chars support
  static final Parser<String> escapedChar1 =
      (char('\\') > oneOf("!\"#\$%&'()*+,-./:;<=>?@[\\]^_`{|}~"));
  static final Parser<List<Inline>> escapedChar =
      escapedChar1 ^ (String char) => [new Str(char)];

  //
  // html entities
  //

  static final RegExp decimalEntity = new RegExp(r'^#(\d{1,8})$');
  static final RegExp hexadecimalEntity =
      new RegExp(r'^#[xX]([0-9a-fA-F]{1,8})$');
  static final Parser<String> htmlEntity1 = (((char('&') >
              ((char('#').maybe + alphanum.many1) ^
                  (Option a, List<String> b) =>
                      (a.isDefined ? '#' : '') + b.join())) <
          char(';')) ^
      (String entity) {
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
      });
  static final Parser<List<Inline>> htmlEntity = htmlEntity1 ^
      (String str) =>
          str == "\u{a0}" ? [new NonBreakableSpace()] : [new Str(str)];

  //
  // inline code
  //

  static final Parser _inlineCode1 = char('`').many1;
  static final Parser _inlineCode2 = noneOf('\n`').many;

  static final Parser<List<Inline>> inlineCode =
      new Parser<List<Inline>>((String s, Position pos) {
    ParseResult openRes = _inlineCode1.run(s, pos);
    if (!openRes.isSuccess) {
      return openRes;
    }
    if (pos.offset > 0 && s[pos.offset - 1] == '`') {
      return _failure(s, pos);
    }

    int fenceSize = openRes.value.length;

    StringBuffer str = new StringBuffer();
    Position position = openRes.position;
    while (true) {
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
        if (blankRes2.isSuccess) {
          // second \n - closing block
          return _failure(s, pos);
        }
        position = blankRes.position;
        continue;
      }

      res = _inlineCode1.run(s, position);
      if (!res.isSuccess) {
        return res;
      }
      if (res.value.length == fenceSize) {
        return res.copy(value: [
          new Code(_trimAndReplaceSpaces(str.toString()), fenceSize: fenceSize)
        ]);
      }
      str.write(res.value.join());
      position = res.position;
    }
  });

  //
  // emphasis and strong
  //

  static final RegExp _isSpace = new RegExp(r'^\s');

  static final RegExp _isPunctuation = new RegExp(
      "^[\u{2000}-\u{206F}\u{2E00}-\u{2E7F}\\\\'!\"#\\\$%&\\(\\)\\*\\+,\\-\\.\\/:;<=>\\?@\\[\\]\\^_`\\{\\|\\}~]");

  // Can't be static
  Parser _scanDelimsCache;
  Map<String, Parser> _scanDelimsParserCache = {};
  Parser get scanDelims {
    if (_scanDelimsCache == null) {
      Parser testParser = oneOf(_inlineDelimiters.join()).lookAhead;
      _scanDelimsCache = new Parser((String s, Position pos) {
        ParseResult testRes = testParser.run(s, pos);
        if (!testRes.isSuccess) {
          return testRes;
        }
        String c = testRes.value;

        Parser p = _scanDelimsParserCache[c];
        if (p == null) {
          p = char(c).many1;
          _scanDelimsParserCache[c] = p;
        }
        ParseResult res = p.run(s, pos);
        if (!res.isSuccess) {
          return res;
        }

        int numDelims = res.value.length;

        int i = 1;
        while (pos.offset - i >= 0 &&
            _intrawordDelimiters.contains(s[pos.offset - i])) {
          ++i;
        }
        String charBefore = pos.offset - i < 0 ? '\n' : s[pos.offset - i];

        i = 0;
        while (res.position.offset + i < s.length &&
            _intrawordDelimiters.contains(s[res.position.offset + i])) {
          ++i;
        }
        String charAfter = res.position.offset + i < s.length
            ? s[res.position.offset + i]
            : '\n';
        bool leftFlanking = !_isSpace.hasMatch(charAfter) &&
            (!_isPunctuation.hasMatch(charAfter) ||
                _isSpace.hasMatch(charBefore) ||
                _isPunctuation.hasMatch(charBefore));
        bool rightFlanking = !_isSpace.hasMatch(charBefore) &&
            (!_isPunctuation.hasMatch(charBefore) ||
                _isSpace.hasMatch(charAfter) ||
                _isPunctuation.hasMatch(charAfter));
        bool canOpen = numDelims > 0 && leftFlanking;
        bool canClose = numDelims > 0 && rightFlanking;
        if (c == '_') {
          canOpen = canOpen &&
              (!rightFlanking || _isPunctuation.hasMatch(charBefore));
          canClose =
              canClose && (!leftFlanking || _isPunctuation.hasMatch(charAfter));
        }
        if (c == '~' && !_options.subscript && numDelims < 2) {
          canOpen = false;
          canClose = false;
        }
        return res.copy(value: [numDelims, canOpen, canClose, c]);
      });
    }
    return _scanDelimsCache;
  }

  Parser _emphasisCache;
  Parser get emphasis {
    if (_emphasisCache == null) {
      _emphasisCache = new Parser((String s, Position pos) {
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
            for (int i = 0; i < stack.last.numDelims; ++i) {
              inlines.add(new SmartQuote(new Inlines(),
                  single: stack.last.char == "'", close: false));
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
                if (_options.subscript && item.char == '~' ||
                    _options.superscript && item.char == '^') {
                  item.cantCloseAnyway = true;
                  convert = true;
                }
                if (convert) {
                  item.inlines = transformEscapedSpace(
                      item.inlines, new NonBreakableSpace());
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
            addToStack(
                new SmartQuote(new Inlines(), single: true, open: false));
          } else {
            if (canClose) {
              bool openFound =
                  stack.any((_EmphasisStackItem item) => item.char == char);
              while (openFound && numDelims > 0 && stack.length > 0) {
                while (stack.length > 0 && stack.last.char != char) {
                  mergeWithPrevious();
                }
                Inlines inlines = stack.last.inlines;
                Inline inline;
                int count = numDelims < stack.last.numDelims
                    ? numDelims
                    : stack.last.numDelims;
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
                        inline = new Subscript(
                            transformEscapedSpace(inlines, new Space()));
                        inlines = new Inlines();
                        inlines.add(inline);
                      }
                      count--;
                    }
                    while (count > 0) {
                      inline = new Strikeout(transformEscapedSpace(
                          inlines, new NonBreakableSpace()));
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
                        inline = new Subscript(
                            transformEscapedSpace(inlines, new Space()));
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
                      inline = new Superscript(
                          transformEscapedSpace(inlines, new Space()));
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
                  openFound =
                      stack.any((_EmphasisStackItem item) => item.char == char);
                }
              }
            }
            // Trying to open
            if (canOpen && numDelims > 0) {
              stack.add(new _EmphasisStackItem(char, numDelims, new Inlines()));
              numDelims = 0;
            }

            if (numDelims > 0) {
              // ending delimiters without open ones
              if (char == "'" || char == '"') {
                for (int i = 0; i < stack.last.numDelims; ++i) {
                  addToStack(new SmartQuote(new Inlines(),
                      single: stack.last.char == "'", open: false));
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
                    return _options.subscript && el.char == '~' ||
                        _options.superscript && el.char == '^';
                  }, orElse: () => null) !=
                  null;
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

        return _success(result, s, position);
      });
    }

    return _emphasisCache;
  }

  //
  // link and image
  //

  static final Parser<String> linkWhitespace = (blankline >
          (whitespaceChar < skipSpaces)) |
      (whitespaceChar < skipSpaces);
  static final Parser<Target> linkInline = (char('(') >
          (((linkWhitespace.maybe > linkInlineDestination) +
                  ((linkWhitespace > linkTitle).maybe < linkWhitespace.maybe)) ^
              (String a, Option b) => new Target(a, b.asNullable))) <
      char(')');

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

  static final Parser _linkOrImageTestParser = char('[');
  static final Parser _linkOrImageRefParser =
      (blankline | whitespaceChar).maybe > linkLabel;
  Parser<List<Inline>> _linkOrImage(bool isLink) {
    Parser labelParser = isLink ? linkText : imageText;
    return new Parser<List<Inline>>((String s, Position pos) {
      ParseResult testRes = _linkOrImageTestParser.run(s, pos);
      if (!testRes.isSuccess) {
        return testRes;
      }

      // Try inline
      ParseResult labelRes = labelParser.run(s, pos);
      if (!labelRes.isSuccess) {
        return labelRes;
      }
      if (isLink && labelRes.value.contains(new RegExp(r"^\s*$"))) {
        return _failure(s, pos);
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
          return destRes.copy(
              value: [new InlineLink(linkInlines, destRes.value)]);
        } else {
          return destRes.copy(
              value: [new InlineImage(linkInlines, destRes.value)]);
        }
      }

      // Try reference link
      ParseResult refRes = _linkOrImageRefParser.run(s, labelRes.position);
      if (refRes.isSuccess) {
        String reference = refRes.value == "" ? labelRes.value : refRes.value;
        String normalizedReference = _normalizeReference(reference);
        Target target = _references[normalizedReference];
        if (target == null) {
          target = _options.linkResolver(normalizedReference, reference);
        }
        if (target != null) {
          if (isLink) {
            return refRes.copy(
                value: [new ReferenceLink(reference, linkInlines, target)]);
          } else {
            return refRes.copy(
                value: [new ReferenceImage(reference, linkInlines, target)]);
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
            return labelRes.copy(value:
                [new ReferenceLink(labelRes.value, linkInlines, target)]);
          } else {
            return labelRes.copy(value:
                [new ReferenceImage(labelRes.value, linkInlines, target)]);
          }
        }
      }

      return _failure(s, pos);
    });
  }

  Parser<List<Inline>> get image => char('!') > _linkOrImage(false);
  Parser<List<Inline>> get link => _linkOrImage(true);

  // TODO test benchmark
  static final Set<String> allowedSchemes = new Set<String>.from(<String>[
    "coap",
    "doi",
    "javascript",
    "aaa",
    "aaas",
    "about",
    "acap",
    "cap",
    "cid",
    "crid",
    "data",
    "dav",
    "dict",
    "dns",
    "file",
    "ftp",
    "geo",
    "go",
    "gopher",
    "h323",
    "http",
    "https",
    "iax",
    "icap",
    "im",
    "imap",
    "info",
    "ipp",
    "iris",
    "iris.beep",
    "iris.xpc",
    "iris.xpcs",
    "iris.lwz",
    "ldap",
    "mailto",
    "mid",
    "msrp",
    "msrps",
    "mtqp",
    "mupdate",
    "news",
    "nfs",
    "ni",
    "nih",
    "nntp",
    "opaquelocktoken",
    "pop",
    "pres",
    "rtsp",
    "service",
    "session",
    "shttp",
    "sieve",
    "sip",
    "sips",
    "sms",
    "snmp",
    "soap.beep",
    "soap.beeps",
    "tag",
    "tel",
    "telnet",
    "tftp",
    "thismessage",
    "tn3270",
    "tip",
    "tv",
    "urn",
    "vemmi",
    "ws",
    "wss",
    "xcon",
    "xcon-userid",
    "xmlrpc.beep",
    "xmlrpc.beeps",
    "xmpp",
    "z39.50r",
    "z39.50s",
    "adiumxtra",
    "afp",
    "afs",
    "aim",
    "apt",
    "attachment",
    "aw",
    "beshare",
    "bitcoin",
    "bolo",
    "callto",
    "chrome",
    "chrome-extension",
    "com-eventbrite-attendee",
    "content",
    "cvs",
    "dlna-playsingle",
    "dlna-playcontainer",
    "dtn",
    "dvb",
    "ed2k",
    "facetime",
    "feed",
    "finger",
    "fish",
    "gg",
    "git",
    "gizmoproject",
    "gtalk",
    "hcp",
    "icon",
    "ipn",
    "irc",
    "irc6",
    "ircs",
    "itms",
    "jar",
    "jms",
    "keyparc",
    "lastfm",
    "ldaps",
    "magnet",
    "maps",
    "market",
    "message",
    "mms",
    "ms-help",
    "msnim",
    "mumble",
    "mvn",
    "notes",
    "oid",
    "palm",
    "paparazzi",
    "platform",
    "proxy",
    "psyc",
    "query",
    "res",
    "resource",
    "rmi",
    "rsync",
    "rtmp",
    "secondlife",
    "sftp",
    "sgn",
    "skype",
    "smb",
    "soldat",
    "spotify",
    "ssh",
    "steam",
    "svn",
    "teamspeak",
    "things",
    "udp",
    "unreal",
    "ut2004",
    "ventrilo",
    "view-source",
    "webcal",
    "wtai",
    "wyciwyg",
    "xfire",
    "xri",
    "ymsgr"
  ]);

  static final RegExp autolinkEmailRegExp = new RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
      r"[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");

  static final Parser _autolinkParser = char('<') >
      pred((String char) =>
              char.codeUnitAt(0) > 0x20 && char != "<" && char != ">")
          .manyUntil(char('>'));
  static final Parser<List<Inline>> autolink =
      new Parser<List<Inline>>((String s, Position pos) {
    ParseResult res = _autolinkParser.run(s, pos);
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

    return _failure(s, pos);
  });

  //
  // raw html
  //

  static final Parser<List<Inline>> rawInlineHtml = choice([
        htmlOpenTag,
        htmlCloseTag,
        htmlCompleteComment,
        htmlCompletePI,
        htmlDeclaration,
        htmlCompleteCDATA
      ]) ^
      (String result) => [new HtmlRawInline(result)];

  //
  // Line break
  //

  static final Parser<List<Inline>> lineBreak =
      (((string('  ') < whitespaceChar.many) < newline) | string("\\\n")) ^
          (String _) => [new LineBreak()];

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

  static final Parser<List<Inline>> smartPunctuation =
      (string("...") ^ (String _) => [new Ellipsis()]) |
          (char("-") > char("-").many1) ^
              (List<String> res) {
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

  Parser<List<Inline>> _strCache;
  Parser<List<Inline>> get str {
    if (_strCache == null) {
      _strCache = (noneOf(_strSpecialChars.join() + "\n").many1 ^
              (List<String> chars) => _transformString(chars.join())) |
          (oneOf(_strSpecialChars.join()) ^
              (String chars) => _transformString(chars)) |
          (char("\n").notFollowedBy(spnl) ^ (String _) => [new Str("\n")]);
    }
    return _strCache;
  }

  Parser<List<Inline>> _inlineCache;
  Parser<List<Inline>> get inline {
    if (_inlineCache == null) {
      _inlineCache = choice([
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
    }
    return _inlineCache;
  }

  Parser<List<Inline>> _spaceEscapedInlineCache;
  Parser<List<Inline>> get spaceEscapedInline {
    if (_spaceEscapedInlineCache == null) {
      _spaceEscapedInlineCache =
          (string(r'\ ') ^ (String _) => [new _EscapedSpace()]) | inline;
    }
    return _spaceEscapedInlineCache;
  }

  Parser<Inlines> _inlinesCache;
  Parser<Inlines> get inlines {
    if (_inlinesCache == null) {
      _inlinesCache = inline.manyUntil(eof) ^
          (List<List<Inline>> res) => processParsedInlines(res);
    }
    return _inlinesCache;
  }

  //
  // Blocks
  //

  Parser<List<Block>> _blockCached;
  Parser<List<Block>> get block {
    if (_blockCached == null) {
      _blockCached = choice([
        blanklines ^ (List<String> _) => [],
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
    }
    return _blockCached;
  }

  Parser<List<Block>> _lazyLineBlockCache;
  Parser<List<Block>> get lazyLineBlock {
    if (_lazyLineBlockCache == null) {
      _lazyLineBlockCache = choice([
        blanklines ^ (List<String> _) => [],
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
    }
    return _lazyLineBlockCache;
  }

  Parser<List<Block>> _listTightBlockCache;
  Parser<List<Block>> get listTightBlock {
    if (_listTightBlockCache == null) {
      _listTightBlockCache = choice([
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
    }
    return _listTightBlockCache;
  }

  //
  // Horizontal rule
  //

  static const String hruleChars = '*-_';

  static Map<String, Parser> _hruleParserCache = {};
  static Parser _hruleParser(String start) {
    if (_hruleParserCache[start] == null) {
      _hruleParserCache[start] = ((((count(2, skipSpaces > char(start)) >
                      (whitespaceChar | char(start)).skipMany) >
                  newline) >
              blanklines.maybe) >
          success([new HorizontalRule()]));
    }
    return _hruleParserCache[start];
  }

  static final Parser<String> _hruleStartParser =
      (skipNonindentCharsFromAnyPosition > oneOf(hruleChars));
  static final Parser hrule = new Parser((String s, Position pos) {
    ParseResult<String> startRes = _hruleStartParser.run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }

    return _hruleParser(startRes.value).run(s, startRes.position);
  });

  //
  // ATX Header
  //

  static final Parser<List<String>> _atxHeaderStartParser =
      skipNonindentChars > char('#').many1;
  static final Parser<String> _atxHeaderEmptyParser =
      (((whitespaceChar > skipSpaces) > (char('#').many > blankline)) |
          (newline ^ (String _) => null));
  static final Parser<List<String>> _atxHeaderRegularParser =
      (((whitespaceChar > skipSpaces) >
              (escapedChar.record | anyChar).manyUntil(
                  (string(' #') > char('#').many).maybe > blankline)) |
          (newline ^ (String _) => []));
  static final Parser atxHeader = new Parser((String s, Position pos) {
    ParseResult startRes = _atxHeaderStartParser.run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    int level = startRes.value.length;
    if (level > 6) {
      return _failure(s, pos);
    }

    // Try empty
    ParseResult textRes = _atxHeaderEmptyParser.run(s, startRes.position);
    if (textRes.isSuccess) {
      return textRes.copy(
          value: [new AtxHeader(level, new _UnparsedInlines(''))]);
    }
    textRes = _atxHeaderRegularParser.run(s, startRes.position);
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
  static final Parser _setextHeaderParser =
      (((skipNonindentChars.notFollowedBy(char('>')) > anyLine) +
              (skipNonindentChars > oneOf(setextHChars).many1)).list <
          blankline);
  static final Parser<List<SetextHeader>> setextHeader =
      new Parser((String s, Position pos) {
    ParseResult res = _setextHeaderParser.run(s, pos);
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

  static final Parser<String> indentedLine =
      (indent > anyLine) ^ (String line) => line + "\n";

  static final Parser<
      List<IndentedCodeBlock>> codeBlockIndented = (indentedLine +
          ((indentedLine |
              (blanklines + indentedLine) ^
                  (List<String> b, String l) => b.join('') + l).many)) ^
      (String f, List<String> c) =>
          [new IndentedCodeBlock(stripTrailingNewlines(f + c.join('')) + '\n')];

  //
  // Fenced code
  //

  static final Parser _openFenceStartParser =
      (skipNonindentCharsFromAnyPosition + (string('~~~') | string('```')))
          .list;
  static Parser _openFenceInfoStringParser(String fenceChar) => ((skipSpaces >
              (noneOf("&\n\\ " + fenceChar) |
                  escapedChar1 |
                  htmlEntity1 |
                  oneOf('&\\')).many) <
          noneOf("\n" + fenceChar).many) <
      newline;
  static Parser _openFenceTopFenceParser(String fenceChar) =>
      (char(fenceChar).many + _openFenceInfoStringParser(fenceChar)).list;
  static final Parser _openFenceTildeTopFenceParser =
      _openFenceTopFenceParser('~');
  static final Parser _openFenceBacktickTopFenceParser =
      _openFenceTopFenceParser('`');
  static final Parser openFence = new Parser((String s, Position pos) {
    ParseResult fenceStartRes = _openFenceStartParser.run(s, pos);
    if (!fenceStartRes.isSuccess) {
      return fenceStartRes;
    }
    int indent = fenceStartRes.value[0];
    String fenceChar = fenceStartRes.value[1][0];
    Parser topFenceParser = fenceChar == '~'
        ? _openFenceTildeTopFenceParser
        : _openFenceBacktickTopFenceParser;
    ParseResult topFenceRes = topFenceParser.run(s, fenceStartRes.position);
    if (!topFenceRes.isSuccess) {
      return topFenceRes;
    }

    int fenceSize = topFenceRes.value[0].length + 3;
    String infoString = topFenceRes.value[1].join();
    return topFenceRes.copy(value: [indent, fenceChar, fenceSize, infoString]);
  });

  static final Parser codeBlockFenced = new Parser((String s, Position pos) {
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

    Parser<String> lineParser = anyLine;
    if (indent > 0) {
      lineParser = atMostIndent(indent) > lineParser;
    }
    // TODO extract creation
    Parser endFenceParser = (((skipNonindentChars >
                    string(fenceChar * fenceSize)) >
                char(fenceChar).many) >
            skipSpaces) >
        newline;
    Parser<List<FencedCodeBlock>> restParser =
        (lineParser.manyUntil(endFenceParser) ^
                (List<String> lines) => [
                      new FencedCodeBlock(
                          lines.map((String i) => i + '\n').join(),
                          fenceType: fenceType,
                          fenceSize: fenceSize,
                          attributes: new InfoString(infoString))
                    ]) |
            (lineParser.manyUntil(eof) ^
                (List<String> lines) {
                  return [
                    new FencedCodeBlock(
                        lines.map((String l) => l + '\n').join(),
                        fenceType: fenceType,
                        fenceSize: fenceSize,
                        attributes: new InfoString(infoString))
                  ];
                });

    return restParser.run(s, openFenceRes.position);
  });

  //
  // Raw html block
  //

  static final List<Map<String, Pattern>> rawHtmlTests = [
    {
      // <script>, <pre> or <style>
      "start": new RegExp(r'^(script|pre|style)( |>|$)',
          caseSensitive: false), // TODO \t
      "end": new RegExp(r'</(script|pre|style)>', caseSensitive: false)
    },
    {
      // <!-- ... -->
      "start": new RegExp(r'^!--'),
      "end": "-->"
    },
    {
      // <? ... ?>
      "start": new RegExp(r'^\?'),
      "end": "?>"
    },
    {
      // <!... >
      "start": new RegExp(r'^![A-Z]'),
      "end": ">"
    },
    {
      // <![CDATA[
      "start": new RegExp(r'^!\[CDATA\['),
      "end": "]]>"
    }
  ];
  static final Pattern rawHtmlTest6 =
      new RegExp(r'^/?([a-zA-Z]+)( |>|$)'); // TODO \t

  static final Parser<int> _rawHtmlParagraphStopTestSimple =
      skipNonindentChars < char('<');
  static final Parser<bool> rawHtmlParagraphStopTest =
      new Parser((String s, Position pos) {
    // Simple test
    ParseResult testRes = _rawHtmlParagraphStopTestSimple.run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }

    ParseResult<String> lineRes = anyLine.run(s, testRes.position);
    assert(lineRes.isSuccess);
    Map<String, Pattern> passedTest = rawHtmlTests.firstWhere(
        (Map<String, Pattern> element) {
      return lineRes.value.contains(element['start']);
    }, orElse: () => null);
    if (passedTest != null) {
      return _success(true, s, pos);
    }

    Match match = rawHtmlTest6.matchAsPrefix(lineRes.value);
    if (match != null && _allowedTags.contains(match.group(1).toLowerCase())) {
      return _success(true, s, pos);
    }

    return _failure(s, pos);
  });

  static final Parser<String> _rawHtmlTest =
      (skipNonindentChars < char('<')).record;
  static final Parser<String> _rawHtmlRule7Parser =
      ((skipNonindentChars < (htmlOpenTag | htmlCloseTag)) < blankline).record;
  static final Parser<HtmlRawBlock> rawHtml =
      new Parser((String s, Position pos) {
    // Simple test
    ParseResult<String> testRes = _rawHtmlTest.run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }

    String content = testRes.value;

    ParseResult lineRes = anyLine.run(s, testRes.position);
    assert(lineRes.isSuccess);
    Map<String, Pattern> passedTest = rawHtmlTests.firstWhere(
        (Map<String, Pattern> element) {
      return lineRes.value.contains(element['start']);
    }, orElse: () => null);
    if (passedTest != null) {
      // Got it
      content += lineRes.value + '\n';
      Position position = lineRes.position;
      while (!lineRes.value.contains(passedTest['end'])) {
        lineRes = anyLine.run(s, position);
        if (!lineRes.isSuccess) {
          // eof
          return _success(new HtmlRawBlock(content), s, position);
        }
        content += lineRes.value + '\n';
        position = lineRes.position;
      }
      return lineRes.copy(value: new HtmlRawBlock(content));
    }

    Match match = rawHtmlTest6.matchAsPrefix(lineRes.value);
    Position position;
    if (match == null || !_allowedTags.contains(match.group(1).toLowerCase())) {
      // Trying rule 7

      ParseResult<String> rule7Res = _rawHtmlRule7Parser.run(s, pos);
      if (!rule7Res.isSuccess ||
          rule7Res.value.indexOf('\n') != rule7Res.value.length - 1) {
        // There could be only one \n, and it's in the end.
        return _failure(s, pos);
      }

      content = rule7Res.value;
      position = rule7Res.position;
    } else {
      content += lineRes.value + '\n';
      position = lineRes.position;
    }

    do {
      ParseResult<String> blanklineRes = blankline.run(s, position);
      if (blanklineRes.isSuccess) {
        return _success(new HtmlRawBlock(content), s, blanklineRes.position);
      }
      lineRes = anyLine.run(s, position);
      if (!lineRes.isSuccess) {
        // eof
        return _success(new HtmlRawBlock(content), s, position);
      }
      content += lineRes.value + '\n';
      position = lineRes.position;
    } while (true);
  });

  //
  // Link reference
  //

  static final Parser<String> _linkReferenceLabelParser =
      (skipNonindentChars > linkLabel) < char(':');
  static final Parser<String> _linkReferenceDestinationParser =
      (blankline.maybe > skipSpaces) > linkBlockDestination;
  static final Parser<String> _linkReferenceTitleParser =
      (skipSpaces > linkTitle) < blankline;
  static final Parser linkReference = new Parser((String s, Position pos) {
    ParseResult<String> labelRes = _linkReferenceLabelParser.run(s, pos);
    if (!labelRes.isSuccess) {
      return labelRes;
    }
    ParseResult<String> destinationRes =
        _linkReferenceDestinationParser.run(s, labelRes.position);
    if (!destinationRes.isSuccess) {
      return destinationRes;
    }
    ParseResult<Option<String>> blanklineRes =
        blankline.maybe.run(s, destinationRes.position);
    assert(blanklineRes.isSuccess);
    ParseResult<String> titleRes =
        _linkReferenceTitleParser.run(s, blanklineRes.position);

    _LinkReference value;
    ParseResult res;
    if (!titleRes.isSuccess) {
      if (blanklineRes.value.isDefined) {
        value = new _LinkReference(
            labelRes.value, new Target(destinationRes.value, null));
        res = blanklineRes;
      } else {
        return _failure(s, pos);
      }
    } else {
      value = new _LinkReference(
          labelRes.value, new Target(destinationRes.value, titleRes.value));
      res = titleRes;
    }

    // Reference couldn't be empty
    if (value.reference.contains(new RegExp(r"^\s*$"))) {
      return _failure(s, pos);
    }
    return res.copy(value: value);
  });

  //
  // Paragraph
  //

  static final Parser _paraEndParser = blankline |
      hrule |
      listMarkerTest(4) |
      atxHeader |
      openFence |
      rawHtmlParagraphStopTest |
      (skipNonindentChars >
          (char('>') |
              (oneOf('+-*') > whitespaceChar) |
              ((countBetween(1, 9, digit) > oneOf('.)')) > whitespaceChar)));
  static final Parser _paraParser = (_paraEndParser.notAhead > anyLine).many1;
  static final Parser para = new Parser((String s, Position pos) {
    ParseResult res = _paraParser.run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    _UnparsedInlines inlines =
        new _UnparsedInlines(res.value.join("\n").trim());
    return res.copy(value: [new Para(inlines)]);
  });

  //
  // Lazy line aux function
  //

  /// Trying to add current line as lazy to nested list blocks.
  ///
  /// Returns `true` when line was accepted.
  static bool _acceptLazy(Iterable<Block> blocks, String s) {
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

  static final Parser<String> blockquoteStrictLine =
      ((skipNonindentChars > char('>')) > whitespaceChar.maybe) >
          anyLine; // TODO check tab
  static final Parser<List> blockquoteLine = (blockquoteStrictLine ^
          (String l) => [true, l]) |
      (anyLine ^ (String l) => [false, l]);

  Parser _blockquoteCache;
  Parser get blockquote {
    if (_blockquoteCache == null) {
      _blockquoteCache = new Parser((String s, Position pos) {
        ParseResult firstLineRes = blockquoteStrictLine.run(s, pos);
        if (!firstLineRes.isSuccess) {
          return firstLineRes;
        }
        List<String> buffer = [firstLineRes.value];
        List<Block> blocks = [];

        bool closeParagraph = false;

        void buildBuffer() {
          String s = buffer.map((String l) => l + "\n").join();
          List<Block> innerRes = (block.manyUntil(eof) ^
                  (List<List<Block>> res) => processParsedBlocks(res))
              .parse(s, tabStop: tabStop);
          if (!closeParagraph &&
              innerRes.length > 0 &&
              innerRes.first is Para) {
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
        while (true) {
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
              List<Block> lineBlock =
                  lazyLineBlock.parse(line + "\n", tabStop: tabStop);
              // TODO fix condition
              if (!closeParagraph &&
                  lineBlock.length == 1 &&
                  lineBlock[0] is Para) {
                Para block = lineBlock[0];
                if (!_acceptLazy(
                    blocks, (block.contents as _UnparsedInlines).raw)) {
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

        return firstLineRes.copy(
            position: position, value: [new Blockquote(blocks)]);
      });
    }

    return _blockquoteCache;
  }

  //
  // Lists
  //

  static const int _listTypeOrdered = 0;
  static const int _listTypeUnordered = 1;
  static ParserAccumulator3 orderedListMarkerTest(int indent) =>
      skipListIndentChars(indent) +
          countBetween(1, 9, digit) + // 1-9 digits
          oneOf('.)');
  static ParserAccumulator2 unorderedListMarkerTest(int indent) =>
      skipListIndentChars(indent).notFollowedBy(hrule) + oneOf('-+*');
  static Parser<List> listMarkerTest(int indent) =>
      (((orderedListMarkerTest(indent) ^
                  (int sp, List d, String c) => [_listTypeOrdered, sp, d, c]) |
              (unorderedListMarkerTest(indent) ^
                  (int sp, String c) => [_listTypeUnordered, sp, c])) +
          (char("\n") |
              countBetween(1, 4, char(' ')).notFollowedBy(char(' ')) |
              oneOf(' \t'))).list;

  Parser _listCache;
  Parser get list {
    if (_listCache == null) {
      _listCache = new Parser((String s, Position pos) {
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
          String s = buffer.map((String l) => l + "\n").join();
          List<Block> innerBlocks;
          if (s == "\n" && blocks.length == 0) {
            // Test for empty items
            blocks = [];
            buffer = [];
            return;
          }
          if (getTight()) {
            ParseResult innerRes = (listTightBlock.manyUntil(eof) ^
                (Iterable res) => processParsedBlocks(res)).run(s);
            if (innerRes.isSuccess) {
              innerBlocks = innerRes.value;
            } else {
              setTight(false);
            }
          }

          if (!getTight()) {
            innerBlocks = (block.manyUntil(eof) ^
                    (Iterable res) => processParsedBlocks(res))
                .parse(s, tabStop: tabStop);
          }
          if (!afterEmptyLine &&
              innerBlocks.length > 0 &&
              innerBlocks.first is Para &&
              _acceptLazy(
                  blocks,
                  ((innerBlocks.first as Para).contents as _UnparsedInlines)
                      .raw)) {
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

        bool addListItem(int type,
            {IndexSeparator indexSeparator, BulletType bulletType}) {
          bool success = false;
          if (stack.length == 0) {
            return false;
          }
          ListBlock block = stack.last.block;
          if (type == _listTypeOrdered &&
              block is OrderedList &&
              block.indexSeparator == indexSeparator) {
            success = true;
          }
          if (type == _listTypeUnordered &&
              block is UnorderedList &&
              block.bulletType == bulletType) {
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
            return new Position(res.position.offset - diff, res.position.line,
                res.position.character - diff,
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
            ParseResult indentRes =
                waitForIndent(getSubIndent()).run(s, position);
            if (indentRes.isSuccess) {
              position = indentRes.position;
              nextLevel = true;
            } else {
              // Trying lazy line
              if (!afterEmptyLine) {
                // Lazy line couldn't appear after empty line
                if (buffer.length > 0) {
                  buildBuffer();
                }

                // TODO Speedup by checking impossible starts
                ParseResult lineRes = anyLine.run(s, position);
                assert(lineRes.isSuccess);
                List<Block> lineBlock = block
                    .parse(lineRes.value.trimLeft() + "\n", tabStop: tabStop);
                if (lineBlock.length == 1 &&
                    lineBlock[0] is Para &&
                    _acceptLazy(
                        blocks,
                        ((lineBlock[0] as Para).contents as _UnparsedInlines)
                            .raw)) {
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
                ParseResult indentRes =
                    waitForIndent(getIndent()).run(s, position);
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

          ParseResult markerRes =
              listMarkerTest(getIndent() + tabStop).run(s, position);
          if (markerRes.isSuccess) {
            markerOnSaparateLine = false;
            int type = markerRes.value[0][0];
            IndexSeparator indexSeparator = (type == _listTypeOrdered
                ? IndexSeparator.fromChar(markerRes.value[0][3])
                : null);
            int startIndex = type == _listTypeOrdered
                ? int.parse(markerRes.value[0][2].join(),
                    onError: (String any) => 1)
                : 1;
            BulletType bulletType = (type == _listTypeUnordered
                ? BulletType.fromChar(markerRes.value[0][2])
                : null);

            // It's a new list item on same level
            if (!nextLevel) {
              bool addSuccess = addListItem(type,
                  indexSeparator: indexSeparator, bulletType: bulletType);
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
                  subIndent = position.character +
                      markerRes.value[0][1] +
                      1; // marker + space after marker - char
                  if (type == _listTypeOrdered) {
                    subIndent += markerRes.value[0][2].length;
                  }
                }
                stack.last.indent =
                    position.character + markerRes.value[0][1] - 1;
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
              subIndent = position.character +
                  markerRes.value[0][1] +
                  1; // marker + space after marker - char
              if (type == _listTypeOrdered) {
                subIndent += markerRes.value[0][2].length;
              }
            }
            if (type == _listTypeOrdered) {
              newListBlock = new OrderedList([new ListItem([])],
                  tight: true,
                  indexSeparator: indexSeparator,
                  startIndex: startIndex);
              //subIndent += markerRes.value[0][2].length;
            } else {
              newListBlock = new UnorderedList([new ListItem([])],
                  tight: true, bulletType: bulletType);
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
              Parser endFenceParser = (((skipSpaces >
                              string(fenceChar * fenceSize)) >
                          char(fenceChar).many) >
                      skipSpaces) >
                  newline;
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

              blocks.add(new FencedCodeBlock(
                  code.map((String i) => i + '\n').join(),
                  fenceType: fenceType,
                  fenceSize: fenceSize,
                  attributes: new InfoString(infoString)));
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

          return _success([stack.first.block], s, position);
        } else {
          return _failure(s, pos);
        }
      });
    }

    return _listCache;
  }

  //
  // Document
  //

  Parser<Document> get document => (block.manyUntil(eof) ^
      (Iterable res) => new Document(processParsedBlocks(res)));

  static final CommonMarkParser commonmark =
      new CommonMarkParser(Options.commonmark);
  static final CommonMarkParser defaults =
      new CommonMarkParser(Options.defaults);
  static final CommonMarkParser strict = new CommonMarkParser(Options.strict);
}
