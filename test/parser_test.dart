import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:unittest/unittest.dart' as t;
import 'package:markdowntypography/markdown.dart';
import 'package:parsers/parsers.dart';
import 'package:markdowntypography/builder.dart' as B;
import 'package:markdowntypography/htmlWriter.dart' as HW;

const int STATE_WAIT = 0;
const int STATE_MARKDOWN = 1;
const int STATE_HTML = 2;

void main() {
  // Common Markdown tests
  t.group("STMD", () {
    File file = new File("stmd/spec.txt");
    int state = STATE_WAIT;
    List<String> html = [];
    List<String> markdown = [];
    List<String> lines = file.readAsLinesSync();
    int testNo = 0;
    for (String line in lines) {
      if (line == ".") {
        state++;
        if (state == 3) {
          ++testNo;
          testCommonMarkdown(testNo, markdown.join('\n') + "\n", html.join('\n') + "\n");
          state = STATE_WAIT;
          html = [];
          markdown = [];
        }
      } else if (state == STATE_MARKDOWN) {
        markdown.add(line);
      } else if (state == STATE_HTML) {
        html.add(line);
      }
    }
  });

  // My tests
  MarkdownParser emptyParser = new MarkdownParser(new MarkdownParserExtensions(headerAttributes: false));
  t.group('headers', () {
    MarkdownParser headerAttributes = new MarkdownParser(new MarkdownParserExtensions(headerAttributes: true));
    MarkdownParser mmdHeaderIdentifiers = new MarkdownParser(new MarkdownParserExtensions(mmdHeaderIdentifiers: true));
    testEquals("atx with header attributes", '## Header ### {#header}\n\nParagraph',
      B.doc(B.header(2, B.attr('header', [], {}), B.str('Header')),
        B.para(B.str("Paragraph"))), headerAttributes);
    testEquals("atx with mmd identifiers", '## Header [mmd-header]###\n\nParagraph',
      B.doc(B.header(2, B.attr('mmd-header', [], {}), B.str('Header')),
        B.para(B.str("Paragraph"))), mmdHeaderIdentifiers);
    testEquals("atx without header attributes", '## Header ### {#header}\n\nParagraph',
      B.doc(B.header(2, B.nullAttr, B.str('Header'), B.space, B.str('###'), B.space, B.str('{#header}')),
        B.para(B.str("Paragraph"))), emptyParser);

    testEquals("setext with header attributes", "Header 1\n=======\nHeader 2 {#id2}\n------\n\nParagraph",
      B.doc(
          B.header(1, B.nullAttr, B.str('Header'), B.space, B.str('1')),
          B.header(2, B.attr('id2', [], {}), B.str('Header'), B.space, B.str('2')),
          B.para(B.str("Paragraph"))
      ), headerAttributes
    );
    testEquals("setext with mmd identifiers", "Header 1 [id1] z\n=======\nHeader 2 [id2]\n------\n\nParagraph",
      B.doc(
          B.header(1, B.nullAttr, B.str('Header'), B.space, B.str('1'), B.space, B.str('[id1]'), B.space, B.str('z')),
          B.header(2, B.attr('id2', [], {}), B.str('Header'), B.space, B.str('2')),
          B.para(B.str("Paragraph"))
      ), mmdHeaderIdentifiers
    );
    testEquals("setext without header attributes", "Header 1\n=======\nHeader 2 {#id2}\n------\n\nParagraph",
      B.doc(
          B.header(1, B.nullAttr, B.str('Header'), B.space, B.str('1')),
          B.header(2, B.nullAttr, B.str('Header'), B.space, B.str('2'), B.space, B.str('{#id2}')),
          B.para(B.str("Paragraph"))
      ), emptyParser
    );
  });

  t.group("indented code block", () {
    testEquals('single line', '    code\n', B.codeBlock('code'), emptyParser);
    testEquals('include leading whitespace after indentation',
      '    zero\n     one\n      two\n       three',
      B.codeBlock('zero\n one\n  two\n   three'), emptyParser);
    testEquals('code blocks separated by newlines form one block',
      '    zero\n    one\n\n    two\n\n\n    three\n',
      B.codeBlock('zero\none\n\ntwo\n\n\nthree'), emptyParser);
  });

  t.group("fenched code block", () {
    MarkdownParser backtickCodeBlocks = new MarkdownParser(new MarkdownParserExtensions(backtickCodeBlocks: true));
    MarkdownParser fencedCodeBlocks = new MarkdownParser(new MarkdownParserExtensions(fencedCodeBlocks: true));
    MarkdownParser codeBlocks = new MarkdownParser(new MarkdownParserExtensions(
        backtickCodeBlocks: true,
        fencedCodeBlocks: true,
        fencedCodeAttributes: true
    ));
    testEquals("without an optional language identifier", "```\ncode\n```\n",
      B.codeBlock("code", B.nullAttr), backtickCodeBlocks);
    testEquals("with an optional language identifier", "```dart\ncode\n```\n",
      B.codeBlock("code", B.attr("", ["dart"], {})), backtickCodeBlocks);
    testEquals("pandoc style without language identifier", "~~~~~\ncode\n~~~~~\n",
      B.codeBlock("code", B.nullAttr), fencedCodeBlocks);
    testEquals("pandoc style with language identifier", "~~~~~dart\ncode\n~~~~~\n",
      B.codeBlock("code", B.attr("", ["dart"], {})), fencedCodeBlocks);
    testEquals("pandoc style with inner tildes row", "~~~~~\n~~~\ncode\n~~~\n~~~~~\n",
      B.codeBlock("~~~\ncode\n~~~", B.nullAttr), fencedCodeBlocks);
    testEquals("backticks with attributes", "``` {.dart #id}\ncode\n```\n",
      B.codeBlock("code", B.attr("id", ["dart"], {})), codeBlocks);
  });

  t.group('horizontal rule', () {
    testEquals('from dashes', '---\n', B.horizontalRule, emptyParser);
    testEquals('from asterisks', '*****\n', B.horizontalRule, emptyParser);
    testEquals('from underscores', '___\n', B.horizontalRule, emptyParser);
    testEquals('from underscores with spaces', '_    _     _\n', B.horizontalRule, emptyParser);
    testEquals('from asterisks not at first position', '  *****\n', B.horizontalRule, emptyParser);
    testEquals('different chars not forms rule', '-_-_-', B.para(B.str('-'), B.emph(B.str('-')), B.str('-')), emptyParser);
  });



  t.group('images', () {
    testEquals("regular", "![Caption](http://asdf.asdf/asdf.jpg)",
    B.image(B.target("http://asdf.asdf/asdf.jpg", ""), B.str("Caption")));
  });

  t.group('formatting', () {
    testEquals("strikeout", "This ~~is strikeout~~ test.",
      B.para(B.str("This"), B.space, B.strikeout(B.str("is"), B.space, B.str("strikeout")), B.space, B.str("test.")));

    testEquals("subscript", "H~2~0",
      B.para(B.str("H"), B.subscript(B.str("2")), B.str('0')));

    testEquals("superscript", "m^3^z",
      B.para(B.str("m"), B.superscript(B.str("3")), B.str('z')));
  });
  t.group('escaped chars', () {
    testEquals("nbsp", "a\\ b",
      B.para(B.str("a"), B.nbsp, B.str("b")));
    testEquals("linebreak", "a\\\nb",
      B.para(B.str("a"), B.linebreak, B.str("b")));
  });

  t.group('subparsers', () {
    t.group('attributes', () {
      testEquals1("identifierAttr", "#i_d", B.attr('i_d', [], {}), MarkdownParser.identifierAttr);
      testEquals1("identifier attribute",  "{#i_d}", B.attr('i_d', [], {}), MarkdownParser.DEFAULT.attributes);
      testEquals1("key-value attribute", "src='value'", B.attr('', [], {"src": "value"}), MarkdownParser.DEFAULT.keyValAttr);
      testEquals1("attributes", "{.haskell .special x=\"7\"}", B.attr("", ["haskell","special"], {"x": "7"}), MarkdownParser.DEFAULT.attributes);
    });
  });

  t.group('inline code', () {
    testEquals("simple",
      "`some code`",
      B.para(B.code("some code"))
    );
    testEquals("with id",
      "`some code` {#i_d}",
      B.para(B.code("some code", B.attr("i_d", [], {})))
    );
    testEquals("with attribute",
      "`document.write(\"Hello\");`{.javascript}",
      B.para(B.code("document.write(\"Hello\");", B.attr("", ["javascript"], {})))
    );
    testEquals("with attribute space",
      "`*` {.haskell .special x=\"7\"}",
      B.para(B.code("*", B.attr("", ["haskell","special"], {"x": "7"})))
    );
    testEquals("with attribute space",
      "`*\n*` {.haskell .special x=\"7\"}",
      B.para(B.code("* *", B.attr("", ["haskell","special"], {"x": "7"})))
    );
  });
  t.group('emph and strong', () {
    testEquals("two strongs in emph",
      "***a**b **c**d*",
      B.para(B.emph(B.strong(B.str("a")), B.str("b"), B.space, B.strong(B.str("c")), B.str("d"))));
    testEquals('emph and strong emph alternating',
      "*xxx* ***xxx*** xxx\n*xxx* ***xxx*** xxx",
      B.para(B.emph(B.str("xxx")), B.space, B.strong(B.emph(B.str("xxx"))),
        B.space, B.str("xxx"), B.space,
        B.emph(B.str("xxx")), B.space, B.strong(B.emph(B.str("xxx"))),
        B.space, B.str("xxx"))
    );
    testEquals("emph with spaced strong",
      "*x **xx** x*",
      B.para(B.emph(B.str("x"), B.space, B.strong(B.str("xx")), B.space, B.str("x")))
    );
    testEquals("intraword underscore with opening underscore",
      "_foot_ball_",
      B.para(B.emph(B.str("foot"), B.str("_"), B.str("ball")))
    );
    testEquals("intraword underscore with opening underscore and disabled intrawords",
      "_foot_ball_",
      B.para(B.emph(B.str("foot")), B.str("ball_")),
      noIntrawordUnderscoreParser
    );
  });
  testEquals("unbalanced brackets",
    "[[[[[[[[[[[[[[[hi",
    B.para(B.str("[[[[[[[[[[[[[[[hi")));
  t.group("backslash escapes", () {
    testEquals("in URL",
      "[hi](/there\\))",
      B.para(B.link(B.target("/there)", ""), B.str("hi"))));
    testEquals("in title",
      "[hi](/there \"a\\\"a\")",
      B.para(B.link(B.target("/there", "a\"a"), B.str("hi"))));
    /*testEquals("in reference link title",
      "[hi]\n\n[hi]: /there (a\\)a)",
      B.para(B.link(B.target("/there", "a)a"), B.str("hi"))));
    testEquals("in reference link title",
      "[hi]\n\n[hi]: /there (a\\)a)",
      B.para(B.link(B.target("/there", "a)a"), B.str("hi"))));
    testEquals("in reference link URL",
      "[hi]\n\n[hi]: /there\\.0",
      B.para(B.link(B.target("/there.0", ""), B.str("hi"))));*/
  });
}

/*
tests :: [Test]
tests = [
        , testGroup "raw LaTeX"
          [ "in URL" =:
            "\\begin\n" =?> para (text "\\begin")
          ]
        , testGroup "raw HTML"
          [ "nesting (issue #1330)" =:
            "<del>test</del>" =?>
            rawBlock "html" "<del>" <> plain (str "test") <>
            rawBlock "html" "</del>"
          ]
        , testGroup "bare URIs"
          (map testBareLink bareLinkTests)
        , testGroup "Headers"
          [ "blank line before header" =:
            "\n# Header\n"
            =?> headerWith ("header",[],[]) 1 "Header"
          ]
        , testGroup "smart punctuation"
          [ test markdownSmart "quote before ellipses"
            ("'...hi'"
            =?> para (singleQuoted "…hi"))
          , test markdownSmart "apostrophe before emph"
            ("D'oh! A l'*aide*!"
            =?> para ("D’oh! A l’" <> emph "aide" <> "!"))
          , test markdownSmart "apostrophe in French"
            ("À l'arrivée de la guerre, le thème de l'«impossibilité du socialisme»"
            =?> para "À l’arrivée de la guerre, le thème de l’«impossibilité du socialisme»")
          ]
        , testGroup "footnotes"
          [ "indent followed by newline and flush-left text" =:
            "[^1]\n\n[^1]: my note\n\n     \nnot in note\n"
            =?> para (note (para "my note")) <> para "not in note"
          , "indent followed by newline and indented text" =:
            "[^1]\n\n[^1]: my note\n     \n    in note\n"
            =?> para (note (para "my note" <> para "in note"))
          , "recursive note" =:
            "[^1]\n\n[^1]: See [^1]\n"
            =?> para (note (para "See [^1]"))
          ]
        , testGroup "lhs"
          [ test (readMarkdown def{ readerExtensions = Set.insert
                       Ext_literate_haskell $ readerExtensions def })
              "inverse bird tracks and html" $
              "> a\n\n< b\n\n<div>\n"
              =?> codeBlockWith ("",["sourceCode","literate","haskell"],[]) "a"
                  <>
                  codeBlockWith ("",["sourceCode","haskell"],[]) "b"
                  <>
                  rawBlock "html" "<div>\n\n"
          ]
-- the round-trip properties frequently fail
--        , testGroup "round trip"
--          [ property "p_markdown_round_trip" p_markdown_round_trip
--          ]
        , testGroup "definition lists"
          [ "no blank space" =:
            "foo1\n  :  bar\n\nfoo2\n  : bar2\n  : bar3\n" =?>
            definitionList [ (text "foo1", [plain (text "bar")])
                           , (text "foo2", [plain (text "bar2"),
                                            plain (text "bar3")])
                           ]
          , "blank space before first def" =:
            "foo1\n\n  :  bar\n\nfoo2\n\n  : bar2\n  : bar3\n" =?>
            definitionList [ (text "foo1", [para (text "bar")])
                           , (text "foo2", [para (text "bar2"),
                                            plain (text "bar3")])
                           ]
          , "blank space before second def" =:
            "foo1\n  :  bar\n\nfoo2\n  : bar2\n\n  : bar3\n" =?>
            definitionList [ (text "foo1", [plain (text "bar")])
                           , (text "foo2", [plain (text "bar2"),
                                            para (text "bar3")])
                           ]
          , "laziness" =:
            "foo1\n  :  bar\nbaz\n  : bar2\n" =?>
            definitionList [ (text "foo1", [plain (text "bar baz"),
                                            plain (text "bar2")])
                           ]
          , "no blank space before first of two paragraphs" =:
            "foo1\n  : bar\n\n    baz\n" =?>
            definitionList [ (text "foo1", [para (text "bar") <>
                                            para (text "baz")])
                           ]
          ]
        , testGroup "+compact_definition_lists"
          [ test markdownCDL "basic compact list" $
            "foo1\n:   bar\n    baz\nfoo2\n:   bar2\n" =?>
            definitionList [ (text "foo1", [plain (text "bar baz")])
                           , (text "foo2", [plain (text "bar2")])
                           ]
          ]
        , testGroup "lists"
          [ "issue #1154" =:
              " -  <div>\n    first div breaks\n    </div>\n\n    <button>if this button exists</button>\n\n    <div>\n    with this div too.\n    </div>\n"
              =?> bulletList [divWith nullAttr (plain $ text "first div breaks") <>
                              rawBlock "html" "<button>" <>
                              plain (text "if this button exists") <>
                              rawBlock "html" "</button>" <>
                              divWith nullAttr (plain $ text "with this div too.")]
          ]
        ]

bareLinkTests :: [(String, Inlines)]
bareLinkTests =
  [ ("http://google.com is a search engine.",
     autolink "http://google.com" <> " is a search engine.")
  , ("<a href=\"http://foo.bar.baz\">http://foo.bar.baz</a>",
     rawInline "html" "<a href=\"http://foo.bar.baz\">" <>
     "http://foo.bar.baz" <> rawInline "html" "</a>")
  , ("Try this query: http://google.com?search=fish&time=hour.",
     "Try this query: " <> autolink "http://google.com?search=fish&time=hour" <> ".")
  , ("HTTPS://GOOGLE.COM,",
      autolink "HTTPS://GOOGLE.COM" <> ",")
  , ("http://el.wikipedia.org/wiki/Τεχνολογία,",
      autolink "http://el.wikipedia.org/wiki/Τεχνολογία" <> ",")
  , ("doi:10.1000/182,",
      autolink "doi:10.1000/182" <> ",")
  , ("git://github.com/foo/bar.git,",
      autolink "git://github.com/foo/bar.git" <> ",")
  , ("file:///Users/joe/joe.txt, and",
      autolink "file:///Users/joe/joe.txt" <> ", and")
  , ("mailto:someone@somedomain.com.",
      autolink "mailto:someone@somedomain.com" <> ".")
  , ("Use http: this is not a link!",
      "Use http: this is not a link!")
  , ("(http://google.com).",
      "(" <> autolink "http://google.com" <> ").")
  , ("http://en.wikipedia.org/wiki/Sprite_(computer_graphics)",
      autolink "http://en.wikipedia.org/wiki/Sprite_(computer_graphics)")
  , ("http://en.wikipedia.org/wiki/Sprite_[computer_graphics]",
      autolink "http://en.wikipedia.org/wiki/Sprite_[computer_graphics]")
  , ("http://en.wikipedia.org/wiki/Sprite_{computer_graphics}",
      autolink "http://en.wikipedia.org/wiki/Sprite_{computer_graphics}")
  , ("http://example.com/Notification_Center-GitHub-20101108-140050.jpg",
      autolink "http://example.com/Notification_Center-GitHub-20101108-140050.jpg")
  , ("https://github.com/github/hubot/blob/master/scripts/cream.js#L20-20",
      autolink "https://github.com/github/hubot/blob/master/scripts/cream.js#L20-20")
  , ("http://www.rubyonrails.com",
      autolink "http://www.rubyonrails.com")
  , ("http://www.rubyonrails.com:80",
      autolink "http://www.rubyonrails.com:80")
  , ("http://www.rubyonrails.com/~minam",
      autolink "http://www.rubyonrails.com/~minam")
  , ("https://www.rubyonrails.com/~minam",
      autolink "https://www.rubyonrails.com/~minam")
  , ("http://www.rubyonrails.com/~minam/url%20with%20spaces",
      autolink "http://www.rubyonrails.com/~minam/url%20with%20spaces")
  , ("http://www.rubyonrails.com/foo.cgi?something=here",
      autolink "http://www.rubyonrails.com/foo.cgi?something=here")
  , ("http://www.rubyonrails.com/foo.cgi?something=here&and=here",
      autolink "http://www.rubyonrails.com/foo.cgi?something=here&and=here")
  , ("http://www.rubyonrails.com/contact;new",
      autolink "http://www.rubyonrails.com/contact;new")
  , ("http://www.rubyonrails.com/contact;new%20with%20spaces",
      autolink "http://www.rubyonrails.com/contact;new%20with%20spaces")
  , ("http://www.rubyonrails.com/contact;new?with=query&string=params",
      autolink "http://www.rubyonrails.com/contact;new?with=query&string=params")
  , ("http://www.rubyonrails.com/~minam/contact;new?with=query&string=params",
      autolink "http://www.rubyonrails.com/~minam/contact;new?with=query&string=params")
  , ("http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_picture_%28animation%29/January_20%2C_2007",
      autolink "http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_picture_%28animation%29/January_20%2C_2007")
  , ("http://www.mail-archive.com/rails@lists.rubyonrails.org/",
      autolink "http://www.mail-archive.com/rails@lists.rubyonrails.org/")
  , ("http://www.amazon.com/Testing-Equal-Sign-In-Path/ref=pd_bbs_sr_1?ie=UTF8&s=books&qid=1198861734&sr=8-1",
      autolink "http://www.amazon.com/Testing-Equal-Sign-In-Path/ref=pd_bbs_sr_1?ie=UTF8&s=books&qid=1198861734&sr=8-1")
  , ("http://en.wikipedia.org/wiki/Texas_hold%27em",
      autolink "http://en.wikipedia.org/wiki/Texas_hold%27em")
  , ("https://www.google.com/doku.php?id=gps:resource:scs:start",
      autolink "https://www.google.com/doku.php?id=gps:resource:scs:start")
  , ("http://www.rubyonrails.com",
      autolink "http://www.rubyonrails.com")
  , ("http://manuals.ruby-on-rails.com/read/chapter.need_a-period/103#page281",
      autolink "http://manuals.ruby-on-rails.com/read/chapter.need_a-period/103#page281")
  , ("http://foo.example.com/controller/action?parm=value&p2=v2#anchor123",
      autolink "http://foo.example.com/controller/action?parm=value&p2=v2#anchor123")
  , ("http://foo.example.com:3000/controller/action",
      autolink "http://foo.example.com:3000/controller/action")
  , ("http://foo.example.com:3000/controller/action+pack",
      autolink "http://foo.example.com:3000/controller/action+pack")
  , ("http://business.timesonline.co.uk/article/0,,9065-2473189,00.html",
      autolink "http://business.timesonline.co.uk/article/0,,9065-2473189,00.html")
  , ("http://www.mail-archive.com/ruby-talk@ruby-lang.org/",
      autolink "http://www.mail-archive.com/ruby-talk@ruby-lang.org/")
  ]

 */

final MarkdownParser defaultParser = MarkdownParser.DEFAULT;
final MarkdownParser noIntrawordUnderscoreParser = new MarkdownParser(new MarkdownParserExtensions(intrawordUnderscores: false));
void testEquals(description, String str, result, [MarkdownParser parser]) {
  t.test(description, () {
    if (parser == null) {
      parser = defaultParser;
    }

    if (result is Inline) {
      result = B.doc(B.para(result));
    } else if (result is Block) {
      result = B.doc(result);
    }
    t.expect(parser.parse(str), t.equals(result));
  });
}

void testEquals1(description, String str, result, Parser parser) {
  t.test(description, () {
    t.expect(parser.parse(str), t.equals(result));
  });
}

class ExampleDescription extends t.Matcher {
  t.Matcher inner;
  String example;

  ExampleDescription(this.inner, this.example);

  bool matches(item, Map matchState) => inner.matches(item, matchState);

  t.Description describe(t.Description description) => inner.describe(description);

  t.Description describeMismatch(item, t.Description mismatchDescription,
                                 Map matchState, bool verbose) {
    t.Description d = inner.describeMismatch(item, mismatchDescription, matchState, verbose);
    d.add("\n  Source: \n" + example);
    return d;
  }


}

final commonMarkdownParser = MarkdownParser.STRICT;
RegExp leadingSpacesRegExp = new RegExp(r'^ *');
RegExp trailingSpacesRegExp = new RegExp(r' *$');
RegExp consecutiveSpacesRegExp = new RegExp(r' +');
RegExp spaceBeforeTagCloseRegExp = new RegExp(r' *\/>');
String tidy(String html) {
  List<String> lines = html.split('\n');
  bool inPre = false;
  List<String> result = [];
  for (String line in lines) {
    if (line.contains("<pre")) {
      inPre = true;
    } else if (line.contains("</pre")) {
      inPre = false;
    }
    if (inPre) {
      result.add(line);
    } else {
      // remove leading spaces
      line = line.replaceAll(leadingSpacesRegExp, '');
      // remove trailing spaces
      line = line.replaceAll(trailingSpacesRegExp, '');
      // collapse consecutive spaces
      line = line.replaceAll(consecutiveSpacesRegExp, ' ');
      // collapse space before /> in tag
      line = line.replaceAll(spaceBeforeTagCloseRegExp, '/>');
      // skip blank line
      if (line == '') {
        continue;
      }
      result.add(line);
    }
  }

  return result.join('\n');
}
void testCommonMarkdown(int num, String md, String html) {
  md = md.replaceAll("→", "\t").replaceAll("␣", " ");
  html = html.replaceAll("→", "\t").replaceAll("␣", " ");

  t.test(num.toString(), () {
    Document doc = commonMarkdownParser.parse(md);
    String result = HW.write(doc);
    t.expect(tidy(HW.write(doc)), new ExampleDescription(t.equals(tidy(html)), md));
  });
}