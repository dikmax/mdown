library md_proc.test.service;

import 'package:test/test.dart' as t;

import 'package:md_proc/md_proc.dart';

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
              'Document [SetextHeader 1 [Str "Hello", Space, Str "world", Str "!"]]'));
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
      Document doc = new Document([new HorizontalRule()]);
      t.test('toString', () {
        t.expect(doc.toString(), t.equals('Document [HorizontalRule]'));
      });
      t.test('==', () {
        t.expect(doc, t.equals(new Document([new HorizontalRule()])));
      });
      t.test('!=', () {
        t.expect(doc, t.isNot(t.equals(new Document([]))));
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
        t.expect(attr, t.isNot(t.equals(new Document([]))));
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
    t.group('HorizontalRule', () {
      HorizontalRule rule = new HorizontalRule();
      t.test('toString', () {
        t.expect(rule.toString(), t.equals('HorizontalRule'));
      });
      t.test('==', () {
        t.expect(rule, t.equals(new HorizontalRule()));
      });
      t.test('!=', () {
        t.expect(rule, t.isNot(t.equals(new EmptyAttr())));
      });
    });

    t.group('AtxHeader', () {
      AtxHeading header =
          new AtxHeading(2, new Inlines.from([new Str('Header')]));
      t.test('toString', () {
        t.expect(header.toString(), t.equals('AtxHeader 2 [Str "Header"]'));
      });
      t.test('Special constructors', () {
        t.expect(new AtxHeading.h1(new Inlines.from([new Str('Header')])),
            t.equals(new AtxHeading(1, new Inlines.from([new Str('Header')]))));
        t.expect(new AtxHeading.h2(new Inlines.from([new Str('Header')])),
            t.equals(new AtxHeading(2, new Inlines.from([new Str('Header')]))));
        t.expect(new AtxHeading.h3(new Inlines.from([new Str('Header')])),
            t.equals(new AtxHeading(3, new Inlines.from([new Str('Header')]))));
        t.expect(new AtxHeading.h4(new Inlines.from([new Str('Header')])),
            t.equals(new AtxHeading(4, new Inlines.from([new Str('Header')]))));
        t.expect(new AtxHeading.h5(new Inlines.from([new Str('Header')])),
            t.equals(new AtxHeading(5, new Inlines.from([new Str('Header')]))));
        t.expect(new AtxHeading.h6(new Inlines.from([new Str('Header')])),
            t.equals(new AtxHeading(6, new Inlines.from([new Str('Header')]))));
      });
      t.test('==', () {
        t.expect(header,
            t.equals(new AtxHeading(2, new Inlines.from([new Str('Header')]))));
      });
      t.test('!=', () {
        t.expect(
            header,
            t.isNot(t.equals(
                new AtxHeading(3, new Inlines.from([new Str('Header')])))));
        t.expect(
            header, t.isNot(t.equals(new AtxHeading(2, new Inlines.from([])))));
        t.expect(
            header,
            t.isNot(t.equals(
                new SetextHeading(2, new Inlines.from([new Str('Header')])))));
      });
    });

    t.group('SetextHeader', () {
      SetextHeading header =
          new SetextHeading(2, new Inlines.from([new Str('Header')]));
      t.test('toString', () {
        t.expect(header.toString(), t.equals('SetextHeader 2 [Str "Header"]'));
      });
      t.test('Special constructors', () {
        t.expect(
            new SetextHeading.h1(new Inlines.from([new Str('Header')])),
            t.equals(
                new SetextHeading(1, new Inlines.from([new Str('Header')]))));
        t.expect(
            new SetextHeading.h2(new Inlines.from([new Str('Header')])),
            t.equals(
                new SetextHeading(2, new Inlines.from([new Str('Header')]))));
      });
      t.test('==', () {
        t.expect(
            header,
            t.equals(
                new SetextHeading(2, new Inlines.from([new Str('Header')]))));
      });
      t.test('!=', () {
        t.expect(
            header,
            t.isNot(t.equals(
                new SetextHeading(3, new Inlines.from([new Str('Header')])))));
        t.expect(header,
            t.isNot(t.equals(new SetextHeading(2, new Inlines.from([])))));
        t.expect(
            header,
            t.isNot(t.equals(
                new AtxHeading(2, new Inlines.from([new Str('Header')])))));
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

    t.group('Blockquote', () {
      Blockquote blockquote = new Blockquote([new HorizontalRule()]);
      t.test('toString', () {
        t.expect(
            blockquote.toString(), t.equals('Blockquote [HorizontalRule]'));
      });
      t.test('==', () {
        t.expect(blockquote, t.equals(new Blockquote([new HorizontalRule()])));
      });
      t.test('!=', () {
        t.expect(blockquote, t.isNot(t.equals(new Blockquote([]))));
        t.expect(blockquote, t.isNot(t.equals(3)));
      });
    });

    t.group('ListItem', () {
      ListItem listItem = new ListItem([new HorizontalRule()]);
      t.test('toString', () {
        t.expect(listItem.toString(), t.equals('ListItem [HorizontalRule]'));
      });
      t.test('==', () {
        t.expect(listItem, t.equals(new ListItem([new HorizontalRule()])));
      });
      t.test('!=', () {
        t.expect(listItem, t.isNot(t.equals(new ListItem([]))));
        t.expect(listItem, t.isNot(t.equals('ListItem [HorizontalRule]')));
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
      UnorderedList list = new UnorderedList([
        new ListItem([new HorizontalRule()])
      ]);
      t.test('toString', () {
        t.expect(list.toString(),
            t.equals('UnorderedList minus [ListItem [HorizontalRule]]'));
      });
      t.test('==', () {
        t.expect(
            list,
            t.equals(new UnorderedList([
              new ListItem([new HorizontalRule()])
            ], tight: false, bulletType: BulletType.minus)));
      });
      t.test('!=', () {
        t.expect(list, t.isNot(new UnorderedList([])));
        t.expect(
            list,
            t.isNot(new UnorderedList([
              new ListItem([new HorizontalRule()])
            ], tight: true)));
        t.expect(
            list,
            t.isNot(new UnorderedList([
              new ListItem([new HorizontalRule()])
            ], bulletType: BulletType.plus)));
        t.expect(
            list,
            t.isNot(new OrderedList([
              new ListItem([new HorizontalRule()])
            ])));
      });
    });

    t.group('OrderedList', () {
      OrderedList list = new OrderedList([
        new ListItem([new HorizontalRule()])
      ]);
      t.test('toString', () {
        t.expect(list.toString(),
            t.equals('OrderedList start=1 dot [ListItem [HorizontalRule]]'));
      });
      t.test('==', () {
        t.expect(
            list,
            t.equals(new OrderedList([
              new ListItem([new HorizontalRule()])
            ],
                tight: false,
                indexSeparator: IndexSeparator.dot,
                startIndex: 1)));
      });
      t.test('!=', () {
        t.expect(list, t.isNot(new OrderedList([])));
        t.expect(
            list,
            t.isNot(new OrderedList([
              new ListItem([new HorizontalRule()])
            ], tight: true)));
        t.expect(
            list,
            t.isNot(new OrderedList([
              new ListItem([new HorizontalRule()])
            ], indexSeparator: IndexSeparator.parenthesis)));
        t.expect(
            list,
            t.isNot(new OrderedList([
              new ListItem([new HorizontalRule()])
            ], startIndex: 0)));
        t.expect(
            list,
            t.isNot(new UnorderedList([
              new ListItem([new HorizontalRule()])
            ])));
      });
    });

    t.group('Para', () {
      Para para = new Para(new Inlines.from([new Str('Para.')]));
      t.test('toString', () {
        t.expect(para.toString(), t.equals('Para [Str "Para."]'));
      });
      t.test('==', () {
        t.expect(
            para, t.equals(new Para(new Inlines.from([new Str('Para.')]))));
      });
      t.test('!=', () {
        t.expect(para, t.isNot(t.equals(new Para(new Inlines()))));
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

    t.group('SmartQuote', () {
      SmartQuote smartQuote =
          new SmartQuote(new Inlines.from([new Str('Quote')]), single: false);
      t.test('toString', () {
        t.expect(smartQuote.toString(), t.equals('SmartQuote "[Str "Quote"]"'));
      });
      t.test('==', () {
        t.expect(
            smartQuote,
            t.equals(new SmartQuote(new Inlines.from([new Str('Quote')]),
                single: false)));
      });
      t.test('!=', () {
        t.expect(smartQuote,
            t.isNot(t.equals(new SmartQuote(new Inlines(), single: false))));
        t.expect(
            smartQuote,
            t.isNot(t.equals(new SmartQuote(
                new Inlines.from([new Str('Quote')]),
                single: true))));
        t.expect(
            smartQuote,
            t.isNot(t.equals(new SmartQuote(
                new Inlines.from([new Str('Quote')]),
                single: false,
                open: false))));
        t.expect(
            smartQuote,
            t.isNot(t.equals(new SmartQuote(
                new Inlines.from([new Str('Quote')]),
                single: false,
                close: false))));
        t.expect(smartQuote, t.isNot(t.equals(null)));
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

    t.group('Emph', () {
      Emph emph = new Emph(new Inlines.from([new Str('Emph')]));
      t.test('toString', () {
        t.expect(emph.toString(), t.equals('Emph [Str "Emph"]'));
      });
      t.test('==', () {
        t.expect(emph, t.equals(new Emph(new Inlines.from([new Str('Emph')]))));
      });
      t.test('!=', () {
        t.expect(emph, t.isNot(t.equals(new Emph(new Inlines()))));
        t.expect(emph, t.isNot(t.equals(null)));
      });
    });

    t.group('Strong', () {
      Strong strong = new Strong(new Inlines.from([new Str('Strong')]));
      t.test('toString', () {
        t.expect(strong.toString(), t.equals('Strong [Str "Strong"]'));
      });
      t.test('==', () {
        t.expect(strong,
            t.equals(new Strong(new Inlines.from([new Str('Strong')]))));
      });
      t.test('!=', () {
        t.expect(
            strong, t.isNot(t.equals(new Inlines.from([new Str('Emph')]))));
        t.expect(strong, t.isNot(t.equals(null)));
      });
    });

    t.group('Strikeout', () {
      Strikeout strikeout =
          new Strikeout(new Inlines.from([new Str('Strikeout')]));
      t.test('toString', () {
        t.expect(strikeout.toString(), t.equals('Strikeout [Str "Strikeout"]'));
      });
      t.test('==', () {
        t.expect(strikeout,
            t.equals(new Strikeout(new Inlines.from([new Str('Strikeout')]))));
      });
      t.test('!=', () {
        t.expect(
            strikeout, t.isNot(t.equals(new Inlines.from([new Str('Emph')]))));
        t.expect(strikeout, t.isNot(t.equals(null)));
      });
    });

    t.group('Subscript', () {
      Subscript subscript =
          new Subscript(new Inlines.from([new Str('Subscript')]));
      t.test('toString', () {
        t.expect(subscript.toString(), t.equals('Subscript [Str "Subscript"]'));
      });
      t.test('==', () {
        t.expect(subscript,
            t.equals(new Subscript(new Inlines.from([new Str('Subscript')]))));
      });
      t.test('!=', () {
        t.expect(
            subscript, t.isNot(t.equals(new Inlines.from([new Str('Emph')]))));
        t.expect(subscript, t.isNot(t.equals(null)));
      });
    });

    t.group('Superscript', () {
      Superscript superscript =
          new Superscript(new Inlines.from([new Str('Superscript')]));
      t.test('toString', () {
        t.expect(superscript.toString(),
            t.equals('Superscript [Str "Superscript"]'));
      });
      t.test('==', () {
        t.expect(
            superscript,
            t.equals(
                new Superscript(new Inlines.from([new Str('Superscript')]))));
      });
      t.test('!=', () {
        t.expect(superscript,
            t.isNot(t.equals(new Inlines.from([new Str('Emph')]))));
        t.expect(superscript, t.isNot(t.equals(null)));
      });
    });

    t.group('InlineLink', () {
      InlineLink link = new InlineLink(new Inlines.from([new Str('Dart')]),
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
            t.equals(new InlineLink(new Inlines.from([new Str('Dart')]),
                new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(
            link,
            t.isNot(t.equals(new InlineLink(new Inlines(),
                new Target('https://www.dartlang.org/', null)))));
        t.expect(
            link,
            t.isNot(t.equals(new InlineLink(new Inlines.from([new Str('Dart')]),
                new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(link, t.isNot(t.equals(null)));
      });
    });

    t.group('ReferenceLink', () {
      ReferenceLink link = new ReferenceLink(
          'dart',
          new Inlines.from([new Str('Dart')]),
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
            t.equals(new ReferenceLink(
                'dart',
                new Inlines.from([new Str('Dart')]),
                new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(
            link,
            t.isNot(t.equals(new ReferenceLink(
                'html',
                new Inlines.from([new Str('Dart')]),
                new Target('https://www.dartlang.org/', null)))));
        t.expect(
            link,
            t.isNot(t.equals(new ReferenceLink(
                'dart',
                new Inlines.from([new Str('HTML')]),
                new Target('https://www.dartlang.org/', null)))));
        t.expect(
            link,
            t.isNot(t.equals(new ReferenceLink(
                'dart',
                new Inlines.from([new Str('Dart')]),
                new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(
            link,
            t.isNot(t.equals(new InlineLink(new Inlines.from([new Str('Dart')]),
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
            t.isNot(t.equals(new InlineLink(new Inlines.from([new Str('Dart')]),
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
            t.isNot(t.equals(new InlineLink(new Inlines.from([new Str('Dart')]),
                new Target('https://www.dartlang.org/', null)))));
      });
    });

    t.group('InlineImage', () {
      InlineImage image = new InlineImage(new Inlines.from([new Str('Dart')]),
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
            t.equals(new InlineImage(new Inlines.from([new Str('Dart')]),
                new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(
            image,
            t.isNot(t.equals(new InlineImage(new Inlines(),
                new Target('https://www.dartlang.org/', null)))));
        t.expect(
            image,
            t.isNot(t.equals(new InlineImage(
                new Inlines.from([new Str('Dart')]),
                new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(image, t.isNot(t.equals(null)));
      });
    });

    t.group('ReferenceImage', () {
      ReferenceImage image = new ReferenceImage(
          'dart',
          new Inlines.from([new Str('Dart')]),
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
            t.equals(new ReferenceImage(
                'dart',
                new Inlines.from([new Str('Dart')]),
                new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(
            image,
            t.isNot(t.equals(new ReferenceImage(
                'html',
                new Inlines.from([new Str('Dart')]),
                new Target('https://www.dartlang.org/', null)))));
        t.expect(
            image,
            t.isNot(t.equals(new ReferenceImage(
                'dart',
                new Inlines.from([new Str('HTML')]),
                new Target('https://www.dartlang.org/', null)))));
        t.expect(
            image,
            t.isNot(t.equals(new ReferenceImage(
                'dart',
                new Inlines.from([new Str('Dart')]),
                new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(
            image,
            t.isNot(t.equals(new InlineImage(
                new Inlines.from([new Str('Dart')]),
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
