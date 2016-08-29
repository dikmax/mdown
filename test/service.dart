library md_proc.test.service;

import 'package:test/test.dart' as t;

import 'package:md_proc/md_proc.dart';
import 'package:md_proc/markdown_writer.dart';

/// Library APIs tests
void serviceTests() {
  t.group('README examples test', () {
    t.test('Basic usage', () {
      t.expect(markdownToHtml('# Hello world!'),
          t.equals("<h1>Hello world!</h1>\n"));
    });

    t.test('Parsing', () {
      t.expect(
          CommonMarkParser.defaults.parse('Hello world!\n===').toString(),
          t.equals(
              'Document (SetextHeading 1 [Str "Hello", Space, Str "world", Str "!"])'));
    });

    t.test('Writing html', () {
      Document doc = CommonMarkParser.defaults.parse('Hello world!\n===');
      String res = HtmlWriter.defaults.write(doc);
      t.expect(res, t.equals('<h1>Hello world!</h1>\n'));
    });

    t.test('Writing markdown', () {
      Document doc = CommonMarkParser.defaults.parse('Hello world!\n===');
      String res = MarkdownWriter.defaults.write(doc);
      t.expect(res, t.equals('Hello world!\n============\n'));
    });

    t.test('Smart punctuation', () {
      Document doc = CommonMarkParser.strict.parse('...');
      String res = HtmlWriter.strict.write(doc);
      t.expect(res, t.equals('<p>...</p>\n'));
    });
  });

  t.group('Definitions', () {
    // Document
    t.group('Document', () {
      Document doc = new Document(<Block>[new ThematicBreak()]);
      t.test('toString', () {
        t.expect(doc.toString(), t.equals('Document [ThematicBreak]'));
      });
      t.test('==', () {
        t.expect(doc, t.equals(new Document(<Block>[new ThematicBreak()])));
      });
      t.test('!=', () {
        t.expect(doc, t.isNot(t.equals(new Document(<Block>[]))));
      });
    });

    // Attributes
    t.group('EmptyAttr', () {
      EmptyAttr attr = new EmptyAttr();
      t.test('toString', () {
        t.expect(attr.toString(), t.equals('EmptyAttr'));
      });
      t.test('==', () {
        t.expect(attr, t.equals(new EmptyAttr()));
      });
      t.test('!=', () {
        t.expect(attr, t.isNot(t.equals(new Document(<Block>[]))));
      });
    });

    t.group('InfoString', () {
      InfoString attr = new InfoString('dart');
      t.test('toString', () {
        t.expect(attr.toString(), t.equals('InfoString(dart)'));
      });
      t.test('==', () {
        t.expect(attr, t.equals(new InfoString('dart')));
      });
      t.test('!=', () {
        t.expect(attr, t.isNot(t.equals(new InfoString('html'))));
        t.expect(attr, t.isNot(t.equals(new EmptyAttr())));
      });
    });

    // Target
    t.group('Target', () {
      Target target = new Target('https://www.dartlang.org/', 'Dart');
      t.test('toString', () {
        t.expect(target.toString(),
            t.equals('Target "https://www.dartlang.org/" "Dart"'));
      });
      t.test('==', () {
        t.expect(
            target, t.equals(new Target('https://www.dartlang.org/', 'Dart')));
      });
      t.test('!=', () {
        t.expect(target,
            t.isNot(t.equals(new Target('https://www.dartlang.org/', null))));
        t.expect(target,
            t.isNot(t.equals(new Target('http://www.dartlang.org/', 'Dart'))));
        t.expect(target, t.isNot(t.equals(new EmptyAttr())));
      });
    });

    //Blocks
    t.group('ThematicBreak', () {
      ThematicBreak thematicBreak = new ThematicBreak();
      t.test('toString', () {
        t.expect(thematicBreak.toString(), t.equals('ThematicBreak'));
      });
      t.test('==', () {
        t.expect(thematicBreak, t.equals(new ThematicBreak()));
      });
      t.test('!=', () {
        t.expect(thematicBreak, t.isNot(t.equals(new EmptyAttr())));
      });
    });

    t.group('AtxHeading', () {
      AtxHeading heading = new AtxHeading(2, <Inline>[new Str('Heading')]);
      t.test('toString', () {
        t.expect(heading.toString(), t.equals('AtxHeading 2 [Str "Heading"]'));
      });
      t.test('Special constructors', () {
        t.expect(new AtxHeading.h1(<Inline>[new Str('Heading')]),
            t.equals(new AtxHeading(1, <Inline>[new Str('Heading')])));
        t.expect(new AtxHeading.h2(<Inline>[new Str('Heading')]),
            t.equals(new AtxHeading(2, <Inline>[new Str('Heading')])));
        t.expect(new AtxHeading.h3(<Inline>[new Str('Heading')]),
            t.equals(new AtxHeading(3, <Inline>[new Str('Heading')])));
        t.expect(new AtxHeading.h4(<Inline>[new Str('Heading')]),
            t.equals(new AtxHeading(4, <Inline>[new Str('Heading')])));
        t.expect(new AtxHeading.h5(<Inline>[new Str('Heading')]),
            t.equals(new AtxHeading(5, <Inline>[new Str('Heading')])));
        t.expect(new AtxHeading.h6(<Inline>[new Str('Heading')]),
            t.equals(new AtxHeading(6, <Inline>[new Str('Heading')])));
      });
      t.test('==', () {
        t.expect(
            heading, t.equals(new AtxHeading(2, <Inline>[new Str('Heading')])));
      });
      t.test('!=', () {
        t.expect(heading,
            t.isNot(t.equals(new AtxHeading(3, <Inline>[new Str('Heading')]))));
        t.expect(heading, t.isNot(t.equals(new AtxHeading(2, <Inline>[]))));
        t.expect(
            heading,
            t.isNot(
                t.equals(new SetextHeading(2, <Inline>[new Str('Heading')]))));
      });
    });

    t.group('SetextHeading', () {
      SetextHeading heading =
          new SetextHeading(2, <Inline>[new Str('Heading')]);
      t.test('toString', () {
        t.expect(
            heading.toString(), t.equals('SetextHeading 2 [Str "Heading"]'));
      });
      t.test('Special constructors', () {
        t.expect(new SetextHeading.h1(<Inline>[new Str('Heading')]),
            t.equals(new SetextHeading(1, <Inline>[new Str('Heading')])));
        t.expect(new SetextHeading.h2(<Inline>[new Str('Heading')]),
            t.equals(new SetextHeading(2, <Inline>[new Str('Heading')])));
      });
      t.test('==', () {
        t.expect(heading,
            t.equals(new SetextHeading(2, <Inline>[new Str('Heading')])));
      });
      t.test('!=', () {
        t.expect(
            heading,
            t.isNot(
                t.equals(new SetextHeading(3, <Inline>[new Str('Heading')]))));
        t.expect(heading, t.isNot(t.equals(new SetextHeading(2, <Inline>[]))));
        t.expect(heading,
            t.isNot(t.equals(new AtxHeading(2, <Inline>[new Str('Heading')]))));
      });
    });

    t.group('FenceType', () {
      t.test('toString', () {
        t.expect(FenceType.backtick.toString(), t.equals('backtick'));
        t.expect(FenceType.tilde.toString(), t.equals('tilde'));
      });
      t.test('==', () {
        t.expect(FenceType.backtick, t.equals(FenceType.backtick));
        t.expect(FenceType.tilde, t.equals(FenceType.tilde));
      });
      t.test('!=', () {
        t.expect(FenceType.backtick, t.isNot(t.equals(FenceType.tilde)));
      });
    });

    t.group('IndentedCodeBlock', () {
      IndentedCodeBlock code = new IndentedCodeBlock("Code");
      t.test('toString', () {
        t.expect(code.toString(), t.equals('IndentedCodeBlock Code'));
      });
      t.test('==', () {
        t.expect(code, t.equals(new IndentedCodeBlock("Code")));
      });
      t.test('!=', () {
        t.expect(code, t.isNot(t.equals(new IndentedCodeBlock("Code1"))));
        t.expect(code, t.isNot(t.equals(new FencedCodeBlock("Code"))));
      });
    });

    t.group('FencedCodeBlock', () {
      FencedCodeBlock code = new FencedCodeBlock("Code");
      t.test('toString', () {
        t.expect(code.toString(), t.equals('FencedCodeBlock EmptyAttr Code'));
      });
      t.test('==', () {
        t.expect(
            code,
            t.equals(new FencedCodeBlock("Code",
                fenceType: FenceType.backtick,
                fenceSize: 3,
                attributes: new EmptyAttr())));
      });
      t.test('!=', () {
        t.expect(code, t.isNot(t.equals(new FencedCodeBlock("Code1"))));
        t.expect(
            code,
            t.isNot(t.equals(
                new FencedCodeBlock("Code", fenceType: FenceType.tilde))));
        t.expect(
            code, t.isNot(t.equals(new FencedCodeBlock("Code", fenceSize: 5))));
        t.expect(
            code,
            t.isNot(t.equals(new FencedCodeBlock("Code",
                attributes: new InfoString('dart')))));
        t.expect(code, t.isNot(t.equals(new IndentedCodeBlock("Code"))));
      });
    });

    t.group('HtmlRawBlock', () {
      HtmlRawBlock raw = new HtmlRawBlock("<html>");
      t.test('toString', () {
        t.expect(raw.toString(), t.equals('HtmlRawBlock <html>'));
      });
      t.test('==', () {
        t.expect(raw, t.equals(new HtmlRawBlock("<html>")));
      });
      t.test('!=', () {
        t.expect(raw, t.isNot(t.equals(new HtmlRawBlock("<body>"))));
        t.expect(raw, t.isNot(t.equals(null)));
      });
    });

    t.group('TexRawBlock', () {
      TexRawBlock raw = new TexRawBlock("\\begin{env}\n\\end{env}");
      t.test('toString', () {
        t.expect(
            raw.toString(), t.equals('TexRawBlock \\begin{env}\n\\end{env}'));
      });
      t.test('==', () {
        t.expect(raw, t.equals(new TexRawBlock("\\begin{env}\n\\end{env}")));
      });
      t.test('!=', () {
        t.expect(raw,
            t.isNot(t.equals(new TexRawBlock("\\begin{enz}\n\\end{enz}"))));
        t.expect(raw, t.isNot(t.equals(null)));
      });
    });

    t.group('Blockquote', () {
      Blockquote blockquote = new Blockquote(<Block>[new ThematicBreak()]);
      t.test('toString', () {
        t.expect(blockquote.toString(), t.equals('Blockquote [ThematicBreak]'));
      });
      t.test('==', () {
        t.expect(blockquote, t.equals(new Blockquote(
            <Block>[new ThematicBreak()])));
      });
      t.test('!=', () {
        t.expect(blockquote, t.isNot(t.equals(new Blockquote(<Block>[]))));
        t.expect(blockquote, t.isNot(t.equals(3)));
      });
    });

    t.group('ListItem', () {
      ListItem listItem = new ListItem(<Block>[new ThematicBreak()]);
      t.test('toString', () {
        t.expect(listItem.toString(), t.equals('ListItem [ThematicBreak]'));
      });
      t.test('==', () {
        t.expect(listItem, t.equals(new ListItem(<Block>[new ThematicBreak()])));
      });
      t.test('!=', () {
        t.expect(listItem, t.isNot(t.equals(new ListItem(<Block>[]))));
        t.expect(listItem, t.isNot(t.equals('ListItem [ThematicBreak]')));
      });
    });

    t.group('BulletType', () {
      t.test('toString', () {
        t.expect(BulletType.minus.toString(), t.equals('minus'));
        t.expect(BulletType.plus.toString(), t.equals('plus'));
        t.expect(BulletType.star.toString(), t.equals('star'));
      });
      t.test('fromChar', () {
        t.expect(BulletType.fromChar('-'), t.equals(BulletType.minus));
        t.expect(BulletType.fromChar('+'), t.equals(BulletType.plus));
        t.expect(BulletType.fromChar('*'), t.equals(BulletType.star));
      });
      t.test('==', () {
        t.expect(BulletType.minus, t.equals(BulletType.minus));
        t.expect(BulletType.plus, t.equals(BulletType.plus));
        t.expect(BulletType.star, t.equals(BulletType.star));
      });
      t.test('!=', () {
        t.expect(BulletType.minus, t.isNot(t.equals(BulletType.plus)));
        t.expect(BulletType.minus, t.isNot(t.equals(BulletType.star)));
      });
    });

    t.group('IndexSeparator', () {
      t.test('toString', () {
        t.expect(IndexSeparator.dot.toString(), t.equals('dot'));
        t.expect(
            IndexSeparator.parenthesis.toString(), t.equals('parenthesis'));
      });
      t.test('fromChar', () {
        t.expect(IndexSeparator.fromChar('.').toString(), t.equals('dot'));
        t.expect(
            IndexSeparator.fromChar(')').toString(), t.equals('parenthesis'));
      });
      t.test('==', () {
        t.expect(IndexSeparator.dot, t.equals(IndexSeparator.dot));
        t.expect(
            IndexSeparator.parenthesis, t.equals(IndexSeparator.parenthesis));
      });
      t.test('!=', () {
        t.expect(
            IndexSeparator.parenthesis, t.isNot(t.equals(IndexSeparator.dot)));
      });
    });

    t.group('UnorderedList', () {
      UnorderedList list = new UnorderedList(<ListItem>[
        new ListItem(<Block>[new ThematicBreak()])
      ]);
      t.test('toString', () {
        t.expect(list.toString(),
            t.equals('UnorderedList minus [ListItem [ThematicBreak]]'));
      });
      t.test('==', () {
        t.expect(
            list,
            t.equals(new UnorderedList(<ListItem>[
              new ListItem(<Block>[new ThematicBreak()])
            ], tight: false, bulletType: BulletType.minus)));
      });
      t.test('!=', () {
        t.expect(list, t.isNot(new UnorderedList(<ListItem>[])));
        t.expect(
            list,
            t.isNot(new UnorderedList(<ListItem>[
              new ListItem(<Block>[new ThematicBreak()])
            ], tight: true)));
        t.expect(
            list,
            t.isNot(new UnorderedList(<ListItem>[
              new ListItem(<Block>[new ThematicBreak()])
            ], bulletType: BulletType.plus)));
        t.expect(
            list,
            t.isNot(new OrderedList(<ListItem>[
              new ListItem(<Block>[new ThematicBreak()])
            ])));
      });
    });

    t.group('OrderedList', () {
      OrderedList list = new OrderedList(<ListItem>[
        new ListItem(<Block>[new ThematicBreak()])
      ]);
      t.test('toString', () {
        t.expect(list.toString(),
            t.equals('OrderedList start=1 dot [ListItem [ThematicBreak]]'));
      });
      t.test('==', () {
        t.expect(
            list,
            t.equals(new OrderedList(<ListItem>[
              new ListItem(<Block>[new ThematicBreak()])
            ],
                tight: false,
                indexSeparator: IndexSeparator.dot,
                startIndex: 1)));
      });
      t.test('!=', () {
        t.expect(list, t.isNot(new OrderedList(<ListItem>[])));
        t.expect(
            list,
            t.isNot(new OrderedList(<ListItem>[
              new ListItem(<Block>[new ThematicBreak()])
            ], tight: true)));
        t.expect(
            list,
            t.isNot(new OrderedList(<ListItem>[
              new ListItem(<Block>[new ThematicBreak()])
            ], indexSeparator: IndexSeparator.parenthesis)));
        t.expect(
            list,
            t.isNot(new OrderedList(<ListItem>[
              new ListItem(<Block>[new ThematicBreak()])
            ], startIndex: 0)));
        t.expect(
            list,
            t.isNot(new UnorderedList(<ListItem>[
              new ListItem(<Block>[new ThematicBreak()])
            ])));
      });
    });

    t.group('Para', () {
      Para para = new Para(<Inline>[new Str('Para.')]);
      t.test('toString', () {
        t.expect(para.toString(), t.equals('Para [Str "Para."]'));
      });
      t.test('==', () {
        t.expect(para, t.equals(new Para(<Inline>[new Str('Para.')])));
      });
      t.test('!=', () {
        t.expect(para, t.isNot(t.equals(new Para(<Inline>[]))));
        t.expect(para, t.isNot(t.equals(new NDash())));
      });
    });

    // Inlines

    t.group('Str', () {
      Str str = new Str('Str');
      t.test('toString', () {
        t.expect(str.toString(), t.equals('Str "Str"'));
      });
      t.test('==', () {
        t.expect(str, t.equals(new Str('Str')));
      });
      t.test('!=', () {
        t.expect(str, t.isNot(t.equals(new Str('_'))));
        t.expect(str, t.isNot(t.equals(null)));
      });
    });

    t.group('Space', () {
      Space space = new Space();
      t.test('toString', () {
        t.expect(space.toString(), t.equals('Space'));
      });
      t.test('==', () {
        t.expect(space, t.equals(new Space()));
      });
      t.test('!=', () {
        t.expect(space, t.isNot(t.equals(new EmptyAttr())));
      });
    });

    t.group('NonBreakableSpace', () {
      NonBreakableSpace nbsp = new NonBreakableSpace();
      t.test('toString', () {
        t.expect(nbsp.toString(), t.equals('NonBreakableSpace'));
      });
      t.test('==', () {
        t.expect(nbsp, t.equals(new NonBreakableSpace()));
      });
      t.test('!=', () {
        t.expect(nbsp, t.isNot(t.equals(new Space())));
      });
    });

    t.group('Tab', () {
      Tab tab = new Tab();
      t.test('toString', () {
        t.expect(tab.toString(), t.equals('Tab'));
      });
      t.test('==', () {
        t.expect(tab, t.equals(new Tab()));
      });
      t.test('!=', () {
        t.expect(tab, t.isNot(t.equals(new EmptyAttr())));
      });
    });

    t.group('LineBreak', () {
      LineBreak lineBreak = new LineBreak();
      t.test('toString', () {
        t.expect(lineBreak.toString(), t.equals('LineBreak'));
      });
      t.test('==', () {
        t.expect(lineBreak, t.equals(new LineBreak()));
      });
      t.test('!=', () {
        t.expect(lineBreak, t.isNot(t.equals(new Space())));
      });
    });

    t.group('MDash', () {
      MDash mdash = new MDash();
      t.test('toString', () {
        t.expect(mdash.toString(), t.equals('MDash'));
      });
      t.test('==', () {
        t.expect(mdash, t.equals(new MDash()));
      });
      t.test('!=', () {
        t.expect(mdash, t.isNot(t.equals(new NDash())));
      });
    });

    t.group('NDash', () {
      NDash ndash = new NDash();
      t.test('toString', () {
        t.expect(ndash.toString(), t.equals('NDash'));
      });
      t.test('==', () {
        t.expect(ndash, t.equals(new NDash()));
      });
      t.test('!=', () {
        t.expect(ndash, t.isNot(t.equals(new Ellipsis())));
      });
    });

    t.group('Ellipsis', () {
      Ellipsis ellipsis = new Ellipsis();
      t.test('toString', () {
        t.expect(ellipsis.toString(), t.equals('Ellipsis'));
      });
      t.test('==', () {
        t.expect(ellipsis, t.equals(new Ellipsis()));
      });
      t.test('!=', () {
        t.expect(ellipsis, t.isNot(t.equals(new MDash())));
      });
    });

    t.group('SingleOpenQuote', () {
      SingleOpenQuote singleOpenQuote = new SingleOpenQuote();
      t.test('toString', () {
        t.expect(singleOpenQuote.toString(), t.equals('SingleOpenQuote'));
      });
      t.test('==', () {
        t.expect(singleOpenQuote, t.equals(new SingleOpenQuote()));
      });
      t.test('!=', () {
        t.expect(singleOpenQuote, t.isNot(t.equals(new MDash())));
      });
    });

    t.group('SingleCloseQuote', () {
      SingleCloseQuote singleCloseQuote = new SingleCloseQuote();
      t.test('toString', () {
        t.expect(singleCloseQuote.toString(), t.equals('SingleCloseQuote'));
      });
      t.test('==', () {
        t.expect(singleCloseQuote, t.equals(new SingleCloseQuote()));
      });
      t.test('!=', () {
        t.expect(singleCloseQuote, t.isNot(t.equals(new MDash())));
      });
    });

    t.group('DoubleOpenQuote', () {
      DoubleOpenQuote doubleOpenQuote = new DoubleOpenQuote();
      t.test('toString', () {
        t.expect(doubleOpenQuote.toString(), t.equals('DoubleOpenQuote'));
      });
      t.test('==', () {
        t.expect(doubleOpenQuote, t.equals(new DoubleOpenQuote()));
      });
      t.test('!=', () {
        t.expect(doubleOpenQuote, t.isNot(t.equals(new MDash())));
      });
    });

    t.group('DoubleCloseQuote', () {
      DoubleCloseQuote doubleCloseQuote = new DoubleCloseQuote();
      t.test('toString', () {
        t.expect(doubleCloseQuote.toString(), t.equals('DoubleCloseQuote'));
      });
      t.test('==', () {
        t.expect(doubleCloseQuote, t.equals(new DoubleCloseQuote()));
      });
      t.test('!=', () {
        t.expect(doubleCloseQuote, t.isNot(t.equals(new MDash())));
      });
    });

    t.group('Code', () {
      Code code = new Code("Code");
      t.test('toString', () {
        t.expect(code.toString(), t.equals('Code "Code"'));
      });
      t.test('==', () {
        t.expect(code, t.equals(new Code("Code", fenceSize: 1)));
      });
      t.test('!=', () {
        t.expect(code, t.isNot(t.equals(new Code("Code1"))));
        t.expect(code, t.isNot(t.equals(new Code("Code", fenceSize: 2))));
        t.expect(code, t.isNot(t.equals(null)));
      });
    });

    t.group('Apostrophe', () {
      Apostrophe apostrophe = new Apostrophe();
      t.test('toString', () {
        t.expect(apostrophe.toString(), t.equals('Apostrophe'));
      });
      t.test('==', () {
        t.expect(apostrophe, t.equals(new Apostrophe()));
      });
      t.test('!=', () {
        t.expect(apostrophe, t.isNot(t.equals(new MDash())));
      });
    });


    t.group('Emph', () {
      Emph emph = new Emph(<Inline>[new Str('Emph')]);
      t.test('toString', () {
        t.expect(emph.toString(), t.equals('Emph [Str "Emph"]'));
      });
      t.test('==', () {
        t.expect(emph, t.equals(new Emph(<Inline>[new Str('Emph')])));
      });
      t.test('!=', () {
        t.expect(emph, t.isNot(t.equals(new Emph(<Inline>[]))));
        t.expect(emph, t.isNot(t.equals(null)));
      });
    });

    t.group('Strong', () {
      Strong strong = new Strong(<Inline>[new Str('Strong')]);
      t.test('toString', () {
        t.expect(strong.toString(), t.equals('Strong [Str "Strong"]'));
      });
      t.test('==', () {
        t.expect(strong, t.equals(new Strong(<Inline>[new Str('Strong')])));
      });
      t.test('!=', () {
        t.expect(strong, t.isNot(t.equals(<Inline>[new Str('Emph')])));
        t.expect(strong, t.isNot(t.equals(null)));
      });
    });

    t.group('Strikeout', () {
      Strikeout strikeout = new Strikeout(<Inline>[new Str('Strikeout')]);
      t.test('toString', () {
        t.expect(strikeout.toString(), t.equals('Strikeout [Str "Strikeout"]'));
      });
      t.test('==', () {
        t.expect(
            strikeout, t.equals(new Strikeout(<Inline>[new Str('Strikeout')])));
      });
      t.test('!=', () {
        t.expect(strikeout, t.isNot(t.equals(<Inline>[new Str('Emph')])));
        t.expect(strikeout, t.isNot(t.equals(null)));
      });
    });

    t.group('Subscript', () {
      Subscript subscript = new Subscript(<Inline>[new Str('Subscript')]);
      t.test('toString', () {
        t.expect(subscript.toString(), t.equals('Subscript [Str "Subscript"]'));
      });
      t.test('==', () {
        t.expect(
            subscript, t.equals(new Subscript(<Inline>[new Str('Subscript')])));
      });
      t.test('!=', () {
        t.expect(subscript, t.isNot(t.equals(<Inline>[new Str('Emph')])));
        t.expect(subscript, t.isNot(t.equals(null)));
      });
    });

    t.group('Superscript', () {
      Superscript superscript =
          new Superscript(<Inline>[new Str('Superscript')]);
      t.test('toString', () {
        t.expect(superscript.toString(),
            t.equals('Superscript [Str "Superscript"]'));
      });
      t.test('==', () {
        t.expect(superscript,
            t.equals(new Superscript(<Inline>[new Str('Superscript')])));
      });
      t.test('!=', () {
        t.expect(superscript, t.isNot(t.equals(<Inline>[new Str('Emph')])));
        t.expect(superscript, t.isNot(t.equals(null)));
      });
    });

    t.group('InlineLink', () {
      InlineLink link = new InlineLink(<Inline>[new Str('Dart')],
          new Target('https://www.dartlang.org/', null));
      t.test('toString', () {
        t.expect(
            link.toString(),
            t.equals(
                'InlineLink [Str "Dart"] (Target "https://www.dartlang.org/" null)'));
      });
      t.test('==', () {
        t.expect(
            link,
            t.equals(new InlineLink(<Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(
            link,
            t.isNot(t.equals(new InlineLink(
                <Inline>[], new Target('https://www.dartlang.org/', null)))));
        t.expect(
            link,
            t.isNot(t.equals(new InlineLink(<Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(link, t.isNot(t.equals(null)));
      });
    });

    t.group('ReferenceLink', () {
      ReferenceLink link = new ReferenceLink('dart', <Inline>[new Str('Dart')],
          new Target('https://www.dartlang.org/', null));
      t.test('toString', () {
        t.expect(
            link.toString(),
            t.equals(
                'ReferenceLink[dart] [Str "Dart"] (Target "https://www.dartlang.org/" null)'));
      });
      t.test('==', () {
        t.expect(
            link,
            t.equals(new ReferenceLink('dart', <Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(
            link,
            t.isNot(t.equals(new ReferenceLink(
                'html',
                <Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', null)))));
        t.expect(
            link,
            t.isNot(t.equals(new ReferenceLink(
                'dart',
                <Inline>[new Str('HTML')],
                new Target('https://www.dartlang.org/', null)))));
        t.expect(
            link,
            t.isNot(t.equals(new ReferenceLink(
                'dart',
                <Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(
            link,
            t.isNot(t.equals(new InlineLink(<Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', null)))));
        t.expect(link, t.isNot(t.equals(null)));
      });
    });

    t.group('Autolink', () {
      Autolink link = new Autolink('https://www.dartlang.org/');
      t.test('toString', () {
        t.expect(
            link.toString(), t.equals('Autolink (https://www.dartlang.org/)'));
      });
      t.test('==', () {
        t.expect(link, t.equals(new Autolink('https://www.dartlang.org/')));
      });
      t.test('!=', () {
        t.expect(
            link, t.isNot(t.equals(new Autolink('http://www.dartlang.org/'))));
        t.expect(
            link,
            t.isNot(t.equals(new InlineLink(<Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', null)))));
      });
    });

    t.group('Autolink.email', () {
      Autolink link = new Autolink.email('test@test.com');
      t.test('toString', () {
        t.expect(link.toString(), t.equals('Autolink (mailto:test@test.com)'));
      });
      t.test('==', () {
        t.expect(link, new Autolink.email('test@test.com'));
        t.expect(link, new Autolink('mailto:test@test.com'));
      });
      t.test('!=', () {
        t.expect(
            link, t.isNot(t.equals(new Autolink('http://www.dartlang.org/'))));
        t.expect(
            link,
            t.isNot(t.equals(new InlineLink(<Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', null)))));
      });
    });

    t.group('InlineImage', () {
      InlineImage image = new InlineImage(<Inline>[new Str('Dart')],
          new Target('https://www.dartlang.org/', null));
      t.test('toString', () {
        t.expect(
            image.toString(),
            t.equals(
                'InlineImage [Str "Dart"] (Target "https://www.dartlang.org/" null)'));
      });
      t.test('==', () {
        t.expect(
            image,
            t.equals(new InlineImage(<Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(
            image,
            t.isNot(t.equals(new InlineImage(
                <Inline>[], new Target('https://www.dartlang.org/', null)))));
        t.expect(
            image,
            t.isNot(t.equals(new InlineImage(<Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(image, t.isNot(t.equals(null)));
      });
    });

    t.group('ReferenceImage', () {
      ReferenceImage image = new ReferenceImage(
          'dart',
          <Inline>[new Str('Dart')],
          new Target('https://www.dartlang.org/', null));
      t.test('toString', () {
        t.expect(
            image.toString(),
            t.equals(
                'ReferenceImage[dart] [Str "Dart"] (Target "https://www.dartlang.org/" null)'));
      });
      t.test('==', () {
        t.expect(
            image,
            t.equals(new ReferenceImage('dart', <Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(
            image,
            t.isNot(t.equals(new ReferenceImage(
                'html',
                <Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', null)))));
        t.expect(
            image,
            t.isNot(t.equals(new ReferenceImage(
                'dart',
                <Inline>[new Str('HTML')],
                new Target('https://www.dartlang.org/', null)))));
        t.expect(
            image,
            t.isNot(t.equals(new ReferenceImage(
                'dart',
                <Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(
            image,
            t.isNot(t.equals(new InlineImage(<Inline>[new Str('Dart')],
                new Target('https://www.dartlang.org/', null)))));
        t.expect(image, t.isNot(t.equals(null)));
      });
    });

    t.group('HtmlRawInline', () {
      HtmlRawInline raw = new HtmlRawInline("<a>");
      t.test('toString', () {
        t.expect(raw.toString(), t.equals('HtmlRawInline <a>'));
      });
      t.test('==', () {
        t.expect(raw, t.equals(new HtmlRawInline("<a>")));
      });
      t.test('!=', () {
        t.expect(raw, t.isNot(t.equals(new HtmlRawInline("<b>"))));
        t.expect(raw, t.isNot(t.equals(null)));
      });
    });

    t.group('TexMathInline', () {
      TexMathInline raw = new TexMathInline("a+b=c");
      t.test('toString', () {
        t.expect(raw.toString(), t.equals('TexMathInline a+b=c'));
      });
      t.test('==', () {
        t.expect(raw, t.equals(new TexMathInline("a+b=c")));
      });
      t.test('!=', () {
        t.expect(raw, t.isNot(t.equals(new TexMathInline("a-b=c"))));
        t.expect(raw, t.isNot(t.equals(new TexMathDisplay("a+b=c"))));
        t.expect(raw, t.isNot(t.equals(null)));
      });
    });

    t.group('TexMathDisplay', () {
      TexMathDisplay raw = new TexMathDisplay("a+b=c");
      t.test('toString', () {
        t.expect(raw.toString(), t.equals('TexMathDisplay a+b=c'));
      });
      t.test('==', () {
        t.expect(raw, t.equals(new TexMathDisplay("a+b=c")));
      });
      t.test('!=', () {
        t.expect(raw, t.isNot(t.equals(new TexMathDisplay("a-b=c"))));
        t.expect(raw, t.isNot(t.equals(new TexMathInline("a+b=c"))));
        t.expect(raw, t.isNot(t.equals(null)));
      });
    });
  });
}
