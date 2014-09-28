part of markdown;

class _UnparsedInlines extends Inlines {
  String raw;

  _UnparsedInlines(this.raw);

  String toString() => raw;

  bool operator==(obj) => obj is _UnparsedInlines &&
    raw == obj.raw;
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

// TODO make aux parsers private

// TODO extract constant parsers from parsers methods

class _ListStackItem {
  int indent;
  int subIndent;
  ListBlock block;
  bool tight;

  _ListStackItem(this.indent, this.subIndent, this.block, [this.tight = true]);
}

// CommonMark parser
class CommonMarkParser {
  static const int TAB_STOP = 4;

  CommonMarkParser();

  Map<String, Target> _references;

  Map<String, Target> get references => _references; // TODO remove later

  Document parse(String s) {
    // TODO separate preprocess option

    _references = {};

    var doc = document.parse(preprocess(s) + "\n\n"); // TODO maybe remove these two newlines at the end.

    _inlinesInDocument(doc);
    return doc;

  }

  //
  // Preprocess
  //

  String preprocess(String s) {
    StringBuffer sb = new StringBuffer();

    int i = 0, len = s.length;
    int pos = 1;
    while (i < len) {
      if (s[i] == "\r") {
        if (i + 1 < len && s[i + 1] == "\n") {
          ++i;
        }

        sb.write("\n");
        pos = 0;
      } else if (s[i] == "\n") {
        if (i + 1 < len && s[i + 1] == "\r") {
          ++i;
        }

        sb.write("\n");
        pos = 0;
      } else if (s[i] == "\t") {
        int expandSize = (TAB_STOP - pos) % TAB_STOP;
        sb.write(" " * (expandSize + 1));
        pos += expandSize;
      } else {
        sb.write(s[i]);
      }

      ++i;
      ++pos;
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
    if ((block is Header || block is Para || block is Plain) && block.contents is _UnparsedInlines) {
      block.contents = _parseInlines(block.contents.raw);
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
    return inlines.parse(raw);
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
      newPos = new Position(offset + 1, pos.line + 1, 1);
    } else {
      newPos = new Position(offset, pos.line, pos.character + result.length);
    }
    return new ParseResult(s, new Expectations.empty(newPos), newPos, true, false, result);
  });

  static Parser spaceChar = oneOf(" \t") % 'space';
  static Parser nonSpaceChar = noneOf("\t\n \r");
  static Parser skipSpaces = spaceChar.skipMany;
  static Parser blankline = skipSpaces > newline % 'blankline';
  static Parser blanklines = blankline.many1 % 'blanklines';
  Parser get indentSpaces => count(TAB_STOP, char(' ')) | char('\t') % "indentation";
  static Parser get skipNonindentSpaces => atMostSpaces(TAB_STOP - 1).notFollowedBy(char(' '));
  static Parser spnl = (skipSpaces > newline);

  static Parser atMostSpaces(n) {
    if (n <= 0) {
      return success(0);
    }

    return new Parser((String s, Position pos) {
      int i = 0;
      Position position = pos;
      while (i < n) {
        var res = char(' ').run(s, position);
        if (!res.isSuccess) {
          return success(i).run(s, position);
        }
        position = res.position;
        ++i;
      }
      return success(i).run(s, position);
    });
  }

  static Parser count(int l, Parser p) => new Parser((String s, Position pos) {
    var position = pos;
    var value = [];
    ParseResult res;
    for (int i = 0; i < l; ++i) {
      res = p.run(s, position);
      if (res.isSuccess) {
        value.add(res.value);
        position = res.position;
      } else {
        return res;
      }
    }

    return res.copy(value: value);
  });

  Parser many1Until(Parser parser, Parser end) => parser + parser.manyUntil(end) ^ (a, b) {
    List<Inline> res = [a];
    if (b.length > 0) {
      res.addAll(b);
    }
    return res;
  };


  //
  // HTML
  //

  static final String _lower = "abcdefghijklmnopqrstuvwxyz";
  static final String _upper = _lower.toUpperCase();
  static final String _alpha = "$_lower$_upper";
  static final String _digit = "1234567890";
  static final String _alphanum = "$_alpha$_digit";
  static final Set<String> _allowedTags = new Set.from(["article", "header", "aside", "hgroup", "blockquote", "hr", "iframe",
    "body", "li", "map", "button", "object", "canvas", "ol", "caption", "output", "col", "p", "colgroup", "pre", "dd",
    "progress", "div", "section", "dl", "table", "td", "dt", "tbody", "embed", "textarea", "fieldset", "tfoot",
    "figcaption", "th", "figure", "thead", "footer", "footer", "tr", "form", "ul", "h1", "h2", "h3", "h4", "h5", "h6",
    "video", "script", "style"]);
  static Parser spaceOrNL = oneOf(" \t\n");

  static Parser htmlAttributeName = (oneOf(_alpha + "_:") > oneOf(_alphanum + "_.:-").many).record;
  static Parser htmlAttiributeValue = (spaceOrNL.many + char('=') + spaceOrNL.many +
    (htmlUnquotedAttributeValue | htmlSingleQuotedAttributeValue | htmlDoubleQuotedAttributeValue)).list.record;
  static Parser htmlUnquotedAttributeValue = noneOf(" \t\n\"'=<>`").many1;
  static Parser htmlSingleQuotedAttributeValue = (char("'") > noneOf("'\n").many) < char("'");
  static Parser htmlDoubleQuotedAttributeValue = (char('"') > noneOf('"\n').many) < char('"');

  static Parser get htmlAttribute => (spaceOrNL.many1 + htmlAttributeName + htmlAttiributeValue.maybe).list.record;
  static Parser htmlBlockTag(Parser p) => new Parser((String s, Position pos) {
    ParseResult res = p.run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    if (_allowedTags.contains(res.value.join().toLowerCase())) {
      return res.copy(value: s.substring(pos.offset, res.position.offset));
    }
    return fail.run(s, pos);
  });
  Parser htmlOpenTag = ((((char("<") > alphanum.many1) < htmlAttribute.many) < spaceOrNL.many) < char('/').maybe) < char('>');
  Parser get htmlBlockOpenTag => htmlBlockTag(htmlOpenTag);
  Parser get htmlInlineOpenTag => htmlOpenTag.record;
  Parser htmlCloseTag = ((string("</") > alphanum.many1) < spaceOrNL.many) < char('>');
  Parser get htmlBlockCloseTag => htmlBlockTag(htmlCloseTag);
  Parser get htmlInlineCloseTag => htmlCloseTag.record;

  Parser get htmlCompleteComment => (string('<!--') > anyChar.manyUntil(string('-->'))).record;
  Parser get htmlCompletePI => (string('<?') > anyChar.manyUntil(string('?>'))).record;
  Parser get htmlDeclaration => (string('<!') + upper.many1 + spaceOrNL.many1 + anyChar.manyUntil(char('>'))).list.record;
  Parser get htmlCompleteCDATA => (string('<![CDATA[') > anyChar.manyUntil(string(']]>'))).record;


  //
  // Links aux parsers
  //

  Parser get linkLabel => (char('[') > choice([whitespace, htmlEntity, inlineCode, str]).manyUntil(char(']')).record) ^
      (String label) => label.substring(0, label.length - 1);

  // TODO proper parentheses ()
  Parser linkDestination = (
      ((char("<") > noneOf("<>\n").many1) < char(">")) |
      noneOf("\t\n ()").many1
  ) ^ (i) => i.join();

  // TODO support escaping
  Parser linkTitle = (
      ((char("'") > noneOf("'\n").many) < char("'")) |
      ((char('"') > noneOf('"\n').many) < char('"')) |
      ((char('(') > noneOf(')\n').many) < char(')'))
  ) ^ (i) => i.join();


  //
  // Inlines
  //

  //
  // whitespace
  //

  static final Parser whitespace = (spaceChar < skipSpaces) ^ (_) => [new Space()];

  // TODO better escaped chars support
  Parser get escapedChar => (char('\\') > oneOf("!\"#\$%&'()*+,-./:;<=>?@[\\]^_`{|}~")) ^ (char) => [new Str(char)];

  //
  // html entities
  //

  static RegExp decimalEntity = new RegExp(r'^#(\d{1,8})$');
  static RegExp hexadecimalEntity = new RegExp(r'^#[xX]([0-9a-fA-F]{1,8})$');
  Parser get htmlEntity => ((char('&') >
      ((char('#').maybe + alphanum.many1) ^ (Option a, b) => (a.isDefined ? '#' : '') + b.join()) ) <
      char(';')) ^ (entity) {
    if (htmlEntities.containsKey(entity)) {
      return new Str(htmlEntities[entity]);
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
      if (code > 1114111) {
        code = 0xFFFD;
      }
      return new Str(new String.fromCharCode(code));
    }

    return new Str('&$entity;');
  };

  //
  // inline code
  //

  String _processInlineCode(String code) {
    return code.trim().replaceAll(new RegExp(r'\s+'), ' ');
  }

  static Parser _inlineCode1 = char('`').many1;
  static Parser _inlineCode2 = noneOf('`').many1;

  Parser<List<Inline>> get inlineCode => new Parser((String s, Position pos) {
    ParseResult openRes = _inlineCode1.run(s, pos);
    if (!openRes.isSuccess) {
      return openRes;
    }
    if (pos.offset > 0 && s[pos.offset - 1] == '`') {
      return fail.run(s,pos);
    }

    int fenceLength = openRes.value.length;

    StringBuffer str = new StringBuffer();
    Position position = openRes.position;
    while(true) {
      ParseResult res = _inlineCode2.run(s, position);
      if (!res.isSuccess) {
        return res;
      }
      str.write(res.value.join());
      position = res.position;

      res = _inlineCode1.run(s, position);
      if (!res.isSuccess) {
        return res;
      }
      if (res.value.length == fenceLength) {
        return res.copy(value: [new Code(_processInlineCode(str.toString()), fenceLength)]);
      }
      str.write(res.value.join());
      position = res.position;
    }
  });

  //
  // emphasis and strong
  //

  static RegExp _isSpace = new RegExp(r'\s');
  static RegExp _isAlphanum = new RegExp(r'[a-z0-9]', caseSensitive: false);
  static Parser scanDelims(String c) => new Parser((String s, Position pos) {
    ParseResult res = char(c).many1.run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    int numDelims = res.value.length;
    String charBefore = pos.offset == 0 ? '\n' : s[pos.offset - 1];
    String charAfter = res.position.offset < s.length ? s[res.position.offset] : '\n';
    bool canOpen = numDelims > 0 && numDelims <= 3 && !_isSpace.hasMatch(charAfter);
    bool canClose = numDelims > 0 && numDelims <= 3 && !_isSpace.hasMatch(charBefore);
    if (c == '_') {
      canOpen = canOpen && !_isAlphanum.hasMatch(charBefore);
      canClose = canClose && !_isAlphanum.hasMatch(charAfter);
    }
    return res.copy(value: [numDelims, canOpen, canClose]);
  });

  Parser get emphasis => new Parser((String s, Position pos) {
    ParseResult testRes = oneOf("*_").lookAhead.run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }
    String char = testRes.value;

    Parser scanParser = scanDelims(char);
    ParseResult res = scanParser.run(s, pos);
    if (!res.isSuccess) {
      return res;
    }
    int numDelims = res.value[0];
    bool canOpen = res.value[1];

    if (!canOpen) {
      return res.copy(value: [new Str(char * numDelims)]);
    }

    List<Inline> result = new Inlines();
    Position position = res.position;

    switch (numDelims) {
      case 1:
        while (true) {
          ParseResult res = scanParser.run(s, position);
          if (res.isSuccess && res.value[2]) {
            return res.copy(position: position.addChar("*"), value: [new Emph(result)]);
          }
          res = inline.run(s, position);
          if (!res.isSuccess) {
            result.insert(0, new Str(char * numDelims));
            return success(result).run(s, position);
          }
          result.addAll(res.value);
          position = res.position;
        }
        break;

      case 2:
        while (true) {
          ParseResult res = scanParser.run(s, position);
          if (res.isSuccess && res.value[0] >= 2 && res.value[2]) {
            return res.copy(position: position.addChar(char).addChar(char), value: [new Strong(result)]);
          }
          res = inline.run(s, position);
          if (!res.isSuccess) {
            result.insert(0, new Str(char * numDelims));
            return success(result).run(s, position);
          }
          result.addAll(res.value);
          position = res.position;
        }
        break;

      case 3:
        int leftToClose = 3;
        Inlines innerRes = new Inlines();
        while (true) {
          ParseResult res = scanParser.run(s, position);
          if (res.isSuccess && res.value[2]) {
            if (leftToClose == 3) {
              if (res.value[0] == 1) {
                leftToClose = 2;
                innerRes = processParsedInlines(result);
                result = [new Emph(innerRes)];
                position = res.position;
              } else if (res.value[0] == 2) {
                leftToClose = 1;
                innerRes = processParsedInlines(result);
                result = [new Strong(result)];
                position = res.position;
              } else {
                // Close
                innerRes.add(new Emph(processParsedInlines(result)));
                return res.copy(position: res.position, value: [new Strong(innerRes)]);
              }
              continue;
            }
            if (res.value[0] >= leftToClose) {
              if (leftToClose == 1) {
                return res.copy(position: position.addChar(char), value: [new Emph(processParsedInlines(result))]);
              } else if (leftToClose == 2) {
                return res.copy(position: position.addChar(char).addChar(char), value: [new Strong(processParsedInlines(result))]);
              }
            } else {
              // We should return unparsed result
              List<Inlines> ret = [new Str(char * 3)];
              ret.addAll(innerRes);
              ret.add(new Str(char * (3 - leftToClose)));
              result.removeAt(0);
              ret.addAll(result);
              ret.add(new Str(char * res.value[0]));
              return res.copy(value: ret);
            }
            continue;
          }
          res = inline.run(s, position);
          if (!res.isSuccess) {
            List<Inlines> ret = [new Str(char * 3)];
            if (leftToClose < 3) {
              ret.addAll(innerRes);
              ret.add(new Str(char * (3 - leftToClose)));
              result.removeAt(0);
            }
            ret.addAll(result);
            return success(ret).run(s, position);
          }
          result.addAll(res.value);
          position = res.position;
        }
        break;

      default:
        return res.copy(value: [new Str(char * numDelims)]);
    }
  });

  //
  // link and image
  //

  // TODO support for html and autolinks

  Parser get linkInline => (char('(') >
    ((
        ((whitespace.maybe > linkDestination) < whitespace.maybe) +
        ((whitespace > linkTitle) < whitespace.maybe).maybe
    ) ^ (a, Option b) => new Target(a, b.asNullable))
  ) < char(')');

  Parser<List<Inline>> get link => new Parser((String s, Position pos) {
    ParseResult testRes = char('[').run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }
    ParseResult labelRes = linkLabel.run(s, pos);
    if (!labelRes.isSuccess) {
      return labelRes;
    }
    // Try inline link
    ParseResult destRes = linkInline.run(s, labelRes.position);
    if (destRes.isSuccess) {
      return destRes.copy(value: [new InlineLink(inlines.parse(labelRes.value), destRes.value)]);
    }
    // Try reference link
    ParseResult refRes = (whitespace.maybe > linkLabel).run(s, labelRes.position);
    if (refRes.isSuccess) {
      String reference = refRes.value == "" ? labelRes.value : refRes.value;
      String normalizedReference = _normalizeReference(reference);
      if (_references.containsKey(normalizedReference)) {
        return refRes.copy(value: [new ReferenceLink(reference, inlines.parse(labelRes.value), _references[normalizedReference])]);
      }
    } else {
      String normalizedReference = _normalizeReference(labelRes.value);
      if (_references.containsKey(normalizedReference)) {
        return labelRes.copy(value: [new ReferenceLink(labelRes.value, inlines.parse(labelRes.value), _references[normalizedReference])]);
      }
    }

    return fail.run(s, pos);
  });

  // TODO don't recreate objects. Move common part to separate parser
  Parser<List<Inline>> get image => (char('!') > link) ^ (link) {
    // Transforming link to image
    if (link[0] is InlineLink) {
      return [new InlineImage(link[0].label, link[0].target)];
    } else if (link[0] is ReferenceLink) {
      return [new ReferenceImage(link[0].reference, link[0].label, link[0].target)];
    }
    return link;
  };

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

  Parser<List<Inline>> get autolink => new Parser((String s, Position pos) {
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

  Parser get rawInlineHtml => choice([htmlInlineOpenTag,
    htmlInlineCloseTag,
    htmlCompleteComment,
    htmlCompletePI,
    htmlDeclaration,
    htmlCompleteCDATA]) ^ (result) => [new HtmlRawInline(result)];

  //
  // Line break
  //

  Parser lineBreak = (((string('  ') < spaceChar.many) < newline) | string("\\\n")) ^ (_) => [new LineBreak()];

  //
  // str
  //

  static final String _strSpecialChars = " \n*_`![]<\\";
  static final Parser str = (noneOf(_strSpecialChars).many1 ^ (chars) => [new Str(chars.join())]) |
    (oneOf(_strSpecialChars) ^ (chars) => [new Str(chars)]);

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
      str
  ]);

  Parser<Inlines> get inlines => inline.manyUntil(eof) ^ (res) => processParsedInlines(res);

  //
  // Blocks
  //

  Parser<List<Block>> get block => choice([
      blanklines ^ (_) => [],
      hrule,
      list,
      atxHeader,
      setextHeader,
      codeBlockIndented,
      codeBlockFenced,
      rawHtml,
      linkReference,
      blockquote,
      para
  ]);

  Parser<List<Block>> get blockTight => choice([
      hrule,
      atxHeader,
      setextHeader,
      codeBlockIndented,
      codeBlockFenced,
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
    ParseResult startRes = (skipNonindentSpaces > oneOf(hruleChars)).run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    var start = startRes.value;

    return ((((count(2, skipSpaces > char(start)) > (spaceChar | char(start)).skipMany) > newline) > blanklines.maybe) >
      success([new HorizontalRule()])).run(s, startRes.position);
  });

  //
  // ATX Header
  //

  Parser get atxHeader => new Parser((String s, Position pos) {
    Parser startParser = skipNonindentSpaces > char('#').many1;
    ParseResult startRes = startParser.run(s, pos);
    if (!startRes.isSuccess) {
      return startRes;
    }
    int level = startRes.value.length;
    if (level > 6) {
      return fail.run(s, pos);
    }

    ParseResult textRes = (((spaceChar > skipSpaces) > anyChar.manyUntil(char('#').many > blankline)) |
      (newline ^ (_) => [])).run(s, startRes.position);
    if (!textRes.isSuccess) {
      return textRes;
    }
    String raw = textRes.value.join();
    // TODO parse inlines

    _UnparsedInlines inlines = new _UnparsedInlines(raw.trim());
    return textRes.copy(value: [new AtxHeader(level, inlines)]);
  });

  //
  // Setext Header
  //

  static const String setextHChars = "=-";

  Parser get setextHeader => new Parser((String s, Position pos) {
    ParseResult res = (((skipNonindentSpaces.notFollowedBy(char('>')) > anyLine) +
      (skipNonindentSpaces > oneOf(setextHChars).many1)).list < blankline).run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    String raw = res.value[0];
    int level = res.value[1][0] == '=' ? 1 : 2;
    // TODO parse inlines

    _UnparsedInlines inlines = new _UnparsedInlines(raw.trim());
    return res.copy(value: [new SetextHeader(level, inlines)]);
  });

  //
  // Indented code
  //

  Parser get indentedLine => (indentSpaces > anyLine) ^ (line) => line + "\n";

  Parser get codeBlockIndented => (indentedLine +
    ((indentedLine | (blanklines + indentedLine) ^ (b, l) => b.join('') + l).many)) ^
      (f, c) => [new IndentedCodeBlock(stripTrailingNewlines(f + c.join('')) + '\n')];

  //
  // Fenced code
  //

  Parser get openFence => new Parser((String s, Position pos) {
    Parser fenceStartParser = (skipNonindentSpaces + (string('~~~') | string('```'))).list;
    ParseResult fenceStartRes = fenceStartParser.run(s, pos);
    if (!fenceStartRes.isSuccess) {
      return fenceStartRes;
    }
    int indent = fenceStartRes.value[0];
    String fenceChar = fenceStartRes.value[1][0];
    FenceType fenceType = FenceType.BacktickFence;
    if (fenceChar == '~') {
      fenceType = FenceType.TildeFence;
    }

    Parser infoStringParser = ((skipSpaces > noneOf("\n " + fenceChar).many) < noneOf("\n" + fenceChar).many) < newline;
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
    int indent = openFenceRes.value[0];
    String fenceChar = openFenceRes.value[1];
    int fenceSize = openFenceRes.value[2];
    String infoString = openFenceRes.value[3];

    FenceType fenceType = FenceType.BacktickFence;
    if (fenceChar == '~') {
      fenceType = FenceType.TildeFence;
    }

    Parser lineParser = anyLine;
    if (indent > 0) {
      lineParser = atMostSpaces(indent) > lineParser;
    }
    Parser endFenceParser = (((skipSpaces > string(fenceChar * fenceSize)) > char(fenceChar).many) > skipSpaces) > newline;
    Parser restParser = (lineParser.manyUntil(endFenceParser) ^
        (lines) => [new FencedCodeBlock(lines.map((i) => i + '\n').join(), fenceType, fenceSize, new InfoString(infoString))])
      | (lineParser.manyUntil(eof) ^ (List lines) {
        // If fenced code block is ended by eof trim last two new lines;
        if (lines.length > 0 && lines.last == "") {
          lines.removeLast();
        }
        return [new FencedCodeBlock(lines.join('\n'), fenceType, fenceSize, new InfoString(infoString))];
      });

    return restParser.run(s, openFenceRes.position);
  });

  // TODO fenced block in list parser

  Parser listCodeBlockFenced(int listIndentValue) => new Parser((String s, Position pos) {
    assert(listIndentValue > 0);
    Parser listIndent = string(" " * listIndentValue);
    ParseResult openFenceRes = (listIndent.maybe > openFence).run(s, pos);
    if (!openFenceRes.isSuccess) {
      return openFenceRes;
    }
    int indent = openFenceRes.value[0];
    String fenceChar = openFenceRes.value[1];
    int fenceSize = openFenceRes.value[2];
    String infoString = openFenceRes.value[3];

    FenceType fenceType = FenceType.BacktickFence;
    if (fenceChar == '~') {
      fenceType = FenceType.TildeFence;
    }

    // TODO

    Parser endFenceParser = ((((listIndent > skipSpaces) > string(fenceChar * fenceSize)) > char(fenceChar).many) > skipSpaces) > newline;
    Parser lineParser;
    if (indent > 0) {
      lineParser = (listIndent > atMostSpaces(indent)) > anyLine;
    } else {
      lineParser = listIndent > anyLine;
    }

    Position position = openFenceRes.position;
    List<String> res = [];
    while (true) {
      ParseResult endParserRes = (endFenceParser | eof).run(s, position);
      if (endParserRes.isSuccess) {
        position = endParserRes.position;
        break;
      }

      ParseResult lineParserRes = (lineParser | (blankline ^ (_) => "")).run(s, position);
      if (!lineParserRes.isSuccess) {
        break;
      }

      res.add(lineParserRes.value + "\n");
      position = lineParserRes.position;
    }

    return success([new FencedCodeBlock(res.join(), fenceType, fenceSize, new InfoString(infoString))]).run(s, position);
  });

  //
  // Raw html block
  //

  Parser get rawHtml => new Parser((String s, Position pos) {
    // Simple test
    ParseResult testRes = (skipNonindentSpaces < char('<')).run(s, pos);
    if (!testRes.isSuccess) {
      return testRes;
    }

    int firstLineIndent = testRes.value;

    Parser contentParser = anyLine.manyUntil(blankline);
    ParseResult contentRes = contentParser.run(s, testRes.position);
    if (!contentRes.isSuccess) {
      return contentRes;
    }
    if (contentRes.value.length == 0) {
      return fail.run(s, pos);
    }
    String content = "<" + contentRes.value.join('\n');

    // TODO add support for partial html comments, pi and CDATA.

    ParseResult tagRes = (htmlBlockOpenTag
      | htmlBlockCloseTag
      | htmlCompleteComment
      | htmlCompletePI
      | htmlDeclaration
      | htmlCompleteCDATA).run(content);
    if (!tagRes.isSuccess) {
      return fail.run(s, pos);
    }

    return contentRes.copy(value: [new HtmlRawBlock((" " * firstLineIndent) + content)]);
  });

  //
  // Link reference
  //

  Parser get linkReference => ((((skipNonindentSpaces > linkLabel) < char(':')) +
    ((blankline.maybe > skipSpaces) > linkDestination) +
    ((blankline.maybe > skipSpaces) > linkTitle).maybe) ^
      (String label, String link, Option<String> title) =>
        new _LinkReference(label, new Target(link, title.isDefined ? title.value : null))) < blankline;

  //
  // Paragraph
  //

  // TODO paragraph could be ended by other block types
  Parser get para => new Parser((String s, Position pos) {
    // TODO replace codeBlockFenced with starting fence test
    Parser end = blankline
      | hrule
      | atxHeader
      | codeBlockFenced
      | (skipNonindentSpaces > (
        char('>')
        | (oneOf('+-*') > char(' '))));
    ParseResult res = (end.notAhead > anyLine).many1.run(s, pos);
    if (!res.isSuccess) {
      return res;
    }

    _UnparsedInlines inlines = new _UnparsedInlines(res.value.join("\n").trim());
    return res.copy(value: [new Para(inlines)]);
  });

  //
  // Blockquote
  //

  static Parser blockquoteStrictLine = ((skipNonindentSpaces > char('>')) > char(' ').maybe) > anyLine;
  static Parser blockquoteLazyLine = skipNonindentSpaces > anyLine;
  static Parser blockquoteLine = (blockquoteStrictLine ^ (l) => [true, l])
    | (blockquoteLazyLine ^ (l) => [false, l]);

  bool acceptLazy(Iterable<Block> blocks, String s) {
    if (blocks.length > 0) {
      if (blocks.last is Para) {
        blocks.last.contents.raw += "\n" + s;
        return true;
      } else if (blocks.last is Blockquote) {
        return acceptLazy(blocks.last.contents, s);
      } else if (blocks.last is ListBlock) {
        return acceptLazy(blocks.last.items.last.contents, s);
      }
    }

    return false;
  }

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
      List<Block> innerRes = (block.manyUntil(eof) ^ (res) => processParsedBlocks(res)).parse(s);
      if (!closeParagraph && innerRes.length > 0 && innerRes.first is Para && acceptLazy(blocks, innerRes.first.contents.raw)) {
        innerRes.removeAt(0);
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
          List<Block> lineBlock = block.parse(line + "\n");
          // TODO fix condition
          if (!closeParagraph && lineBlock.length == 1 && lineBlock[0] is Para && acceptLazy(blocks, lineBlock[0].contents.raw)) {

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

  static const _LIST_TYPE_ORDERED = 0;
  static const _LIST_TYPE_UNORDERED = 1;
  static ParserAccumulator3 get orderedListMarkerTest => skipNonindentSpaces + digit.many1 + oneOf('.)');
  static ParserAccumulator2 get unorderedListMarkerTest => skipNonindentSpaces.notFollowedBy(hrule) + oneOf('-+*');
  static Parser get listMarkerTest => (((orderedListMarkerTest ^ (sp, d, c) => [_LIST_TYPE_ORDERED, sp, d, c])
    | (unorderedListMarkerTest ^ (sp, c) => [_LIST_TYPE_UNORDERED, sp, c])) + (char("\n") | char(' ').many1)).list;

  Parser get list => new Parser((String s, Position pos) {
    List<_ListStackItem> stack = [];

    int getSubIndent() => stack.length > 0 ? stack.last.subIndent : 0;
    int getIndent() => stack.length > 0 ? stack.last.indent : 0;
    bool getTight() => stack.length > 0 ? stack.last.tight : true;
    void setTight(bool tight) {
      if (stack.length > 0) {
        stack.last.tight = tight;
      }
    }

    // TODO move tight to list definition
    void convertToTight(bool tight, Iterable<ListItem> items) {
      if (tight) {
        items.forEach((ListItem item) {
          item.contents = item.contents.map((Block block) {
            if (block is Para) {
              return new Plain(block.contents);
            }
            return block;
          });
        });
      }
    }

    bool closeParagraph = false;
    List<Block> blocks = [];
    List<String> buffer = [];
    void buildBuffer() {
      String s = buffer.map((l) => l + "\n").join();
      List<Block> innerBlocks;
      if (s == "\n" && blocks.length == 0) {
        // Test for empty items
        blocks = [new Plain(new _UnparsedInlines(""))]; // TODO replace with inlines
        buffer = [];
        return;
      }
      if (getTight()) {
        ParseResult innerRes = (blockTight.manyUntil(eof) ^ (res) => processParsedBlocks(res)).run(s);
        if (innerRes.isSuccess) {
          innerBlocks = innerRes.value;
        } else {
          setTight(false);
        }
      }

      if (!getTight()) {
        innerBlocks = (block.manyUntil(eof) ^ (res) => processParsedBlocks(res)).parse(s);
      }
      if (!closeParagraph && innerBlocks.length > 0 && innerBlocks.first is Para &&
          acceptLazy(blocks, ((innerBlocks.first as Para).contents as _UnparsedInlines).raw)) {
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
      if (type == _LIST_TYPE_ORDERED && block is OrderedList && block.indexSeparator == indexSeparator) {
        success = true;
      }
      if (type == _LIST_TYPE_UNORDERED && block is UnorderedList && block.bulletType == bulletType) {
        success = true;
      }
      if (success) {
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
        return new Position(res.position.offset - diff, res.position.line, res.position.character - diff);
      }
    }

    Position position = pos;

    bool nextLevel = true;

    // TODO Split loop to smaller parts
    while (true) {
      bool closeListItem = false;
      ParseResult eofRes = eof.run(s, position);
      if (eofRes.isSuccess) {
        // End of input reached
        break;
      }

      // Test for inner elements
      ParseResult blanklineRes = blankline.run(s, position);
      if (blanklineRes.isSuccess) {
        if (closeParagraph) {
          break;
        }
        closeParagraph = true;
        position = blanklineRes.position;
        continue;
      }

      if (position.character == 1 && getSubIndent() > 0) {
        // Waiting for indent
        ParseResult indentRes = string(" " * getSubIndent()).run(s, position);
        if (indentRes.isSuccess) {
          position = indentRes.position;
          nextLevel = true;
        } else {
          // Lazy line
          if (!closeParagraph) {
            if (buffer.length > 0) {
              buildBuffer();
            }

            // TODO Speedup by checking impossible starts
            ParseResult lineRes = anyLine.run(s, position);
            assert(lineRes.isSuccess);
            List<Block> lineBlock = block.parse(lineRes.value.trimLeft() + "\n");
            if (lineBlock.length == 1 && lineBlock[0] is Para &&
            acceptLazy(blocks, ((lineBlock[0] as Para).contents as _UnparsedInlines).raw)) {
              position = lineRes.position;
              continue;
            }
          }

          if (buffer.length > 0 || blocks.length > 0) {
            buildBuffer();
            addToListItem(stack.last.block.items.last, blocks);
            blocks = [];
          }

          nextLevel = false;
          while (getIndent() > 0) {
            ParseResult indentRes = string(" " * getIndent()).run(s, position);
            if (indentRes.isSuccess) {
              position = indentRes.position;
              closeListItem = true;
              break;
            }
            convertToTight(getTight(), stack.last.block.items);
            stack.removeLast();
          }
        }
      }

      // Test marker start
      ParseResult markerRes = listMarkerTest.run(s, position);
      if (markerRes.isSuccess) {
        int type = markerRes.value[0][0];
        IndexSeparator indexSeparator = (type == _LIST_TYPE_ORDERED ? IndexSeparator.fromChar(markerRes.value[0][3]) : null);
        int startIndex = type == _LIST_TYPE_ORDERED ? int.parse(markerRes.value[0][2].join(), onError: (_) => 1) : 1;
        BulletType bulletType = (type == _LIST_TYPE_UNORDERED ? BulletType.fromChar(markerRes.value[0][2]) : null);

        if (!nextLevel) {

          bool addSuccess = addListItem(type, indexSeparator: indexSeparator, bulletType: bulletType);
          if (!addSuccess) {
            if (stack.length == 1) {
              // It's a new list on top level. Stopping here
              break;
            }
            // New list on same level
            stack.removeLast();
          } else {
            int subIndent = markerRes.value[0][1] + 1;
            if (type == _LIST_TYPE_ORDERED) {
              subIndent += markerRes.value[0][2].length;
            }
            stack.last.subIndent = getIndent() + subIndent;
            if (markerRes.value[1] != "\n" && markerRes.value[1].length <= 4) {
              stack.last.subIndent += markerRes.value[1].length;
            }

            position = getNewPositionAfterListMarker(markerRes);
            continue;
          }
        }

        // Flush buffer
        if (stack.length > 0 && (buffer.length > 0 || blocks.length > 0)) {
          buildBuffer();
          addToListItem(stack.last.block.items.last, blocks);
          blocks = [];
        }

        ListBlock newListBlock;
        int subIndent = markerRes.value[0][1] + 1;
        if (type == _LIST_TYPE_ORDERED) {
          newListBlock = new OrderedList([new ListItem([])], indexSeparator, startIndex);
          subIndent += markerRes.value[0][2].length;
        } else {
          newListBlock = new UnorderedList([new ListItem([])], bulletType);
        }

        if (stack.length > 0) {
          addToListItem(stack.last.block.items.last, [newListBlock]);
        }

        int indent = getSubIndent();
        if (markerRes.value[1] == "\n" || markerRes.value[1].length > 4) {
          stack.add(new _ListStackItem(indent, indent + subIndent + 1, newListBlock));
        } else {
          stack.add(new _ListStackItem(indent, indent + subIndent + markerRes.value[1].length, newListBlock));
        }
        position = getNewPositionAfterListMarker(markerRes);
        nextLevel = true;
        continue;
      } else if (stack.length == 0) {
        // That was first marker test and it's failed
        return markerRes;
      }

      if (closeListItem) {
        convertToTight(getTight(), stack.last.block.items);
        if (stack.length > 1) {
          stack.removeLast();
        } else {
          break;
        }
      }

      if (position.character > 1) {
        // Fenced code block
        ParseResult openFenceRes = openFence.run(s, position);
        if (openFenceRes.isSuccess) {
          if (buffer.length > 0) {
            buildBuffer();
          }

          int indent = openFenceRes.value[0];
          String fenceChar = openFenceRes.value[1];
          int fenceSize = openFenceRes.value[2];
          String infoString = openFenceRes.value[3];

          FenceType fenceType = FenceType.BacktickFence;
          if (fenceChar == '~') {
            fenceType = FenceType.TildeFence;
          }

          position = openFenceRes.position;

          Parser indentParser = string(" " * getSubIndent());
          Parser endFenceParser = (((skipSpaces > string(fenceChar * fenceSize)) > char(fenceChar).many) > skipSpaces) > newline;
          Parser lineParser = anyLine;
          if (indent > 0) {
            lineParser = atMostSpaces(indent) > lineParser;
          }

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

          blocks.add(new FencedCodeBlock(code.map((i) => i + '\n').join(), fenceType, fenceSize, new InfoString(infoString)));
          closeParagraph = false;
          continue;
        }

        // Strict line
        ParseResult lineRes = anyLine.run(s, position);
        assert(lineRes.isSuccess);
        if (closeParagraph) {
          buffer.add("");
          closeParagraph = false;
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

      stack.forEach((_ListStackItem stackItem) {
        convertToTight(stackItem.tight, stackItem.block.items);
      });

      return success([stack.first.block]).run(s, position);
    } else {
      return fail.run(s, pos);
    }
  });

  //
  // Document
  //

  Parser get document => (block.manyUntil(eof) ^ (res) => new Document(processParsedBlocks(res))) % "document";

  static CommonMarkParser DEFAULT = new CommonMarkParser();
}
