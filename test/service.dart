library serviceTest;

import 'package:test/test.dart' as t;

import 'package:md_proc/md_proc.dart';

void serviceTests() {
  t.group('README examples test', () {
    t.test('Basic usage', () {
      t.expect(markdownToHtml('# Hello world!'), t.equals("<h1>Hello world!</h1>\n"));
    });

    t.test('Parsing', () {
      t.expect(CommonMarkParser.DEFAULT.parse('Hello world!\n===').toString(),
        t.equals('Document [SetextHeader 1 [Str "Hello", Space, Str "world", Str "!"]]'));
    });

    t.test('Writing html', () {
      Document doc = CommonMarkParser.DEFAULT.parse('Hello world!\n===');
      String res = HtmlWriter.DEFAULT.write(doc);
      t.expect(res, t.equals('<h1>Hello world!</h1>\n'));
    });

    t.test('Writing markdown', () {
      Document doc = CommonMarkParser.DEFAULT.parse('Hello world!\n===');
      String res = MarkdownWriter.DEFAULT.write(doc);
      t.expect(res, t.equals('Hello world!\n============\n'));
    });

    t.test('Smart punctuation', () {
      Document doc = CommonMarkParser.STRICT.parse('...');
      String res = HtmlWriter.STRICT.write(doc);
      t.expect(res, t.equals('<p>...</p>\n'));
    });
  });

  t.group('Definitions', () {
    // Document
    t.group('Document', () {
      var doc = new Document([new HorizontalRule()]);
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
      var attr = new EmptyAttr();
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
      var attr = new InfoString('dart');
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
      var target = new Target('https://www.dartlang.org/', 'Dart');
      t.test('toString', () {
        t.expect(target.toString(), t.equals('Target "https://www.dartlang.org/" "Dart"'));
      });
      t.test('==', () {
        t.expect(target, t.equals(new Target('https://www.dartlang.org/', 'Dart')));
      });
      t.test('!=', () {
        t.expect(target, t.isNot(t.equals(new Target('https://www.dartlang.org/', null))));
        t.expect(target, t.isNot(t.equals(new Target('http://www.dartlang.org/', 'Dart'))));
        t.expect(target, t.isNot(t.equals(new EmptyAttr())));
      });
    });

    //Blocks
    t.group('HorizontalRule', () {
      var rule = new HorizontalRule();
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
      var header = new AtxHeader(2, new Inlines.from([new Str('Header')]));
      t.test('toString', () {
        t.expect(header.toString(), t.equals('AtxHeader 2 [Str "Header"]'));
      });
      t.test('Special constructors', () {
        t.expect(new AtxHeader.h1(new Inlines.from([new Str('Header')])), t.equals(new AtxHeader(1, new Inlines.from([new Str('Header')]))));
        t.expect(new AtxHeader.h2(new Inlines.from([new Str('Header')])), t.equals(new AtxHeader(2, new Inlines.from([new Str('Header')]))));
        t.expect(new AtxHeader.h3(new Inlines.from([new Str('Header')])), t.equals(new AtxHeader(3, new Inlines.from([new Str('Header')]))));
        t.expect(new AtxHeader.h4(new Inlines.from([new Str('Header')])), t.equals(new AtxHeader(4, new Inlines.from([new Str('Header')]))));
        t.expect(new AtxHeader.h5(new Inlines.from([new Str('Header')])), t.equals(new AtxHeader(5, new Inlines.from([new Str('Header')]))));
        t.expect(new AtxHeader.h6(new Inlines.from([new Str('Header')])), t.equals(new AtxHeader(6, new Inlines.from([new Str('Header')]))));
      });
      t.test('==', () {
        t.expect(header, t.equals(new AtxHeader(2, new Inlines.from([new Str('Header')]))));
      });
      t.test('!=', () {
        t.expect(header, t.isNot(t.equals(new AtxHeader(3, new Inlines.from([new Str('Header')])))));
        t.expect(header, t.isNot(t.equals(new AtxHeader(2, new Inlines.from([])))));
        t.expect(header, t.isNot(t.equals(new SetextHeader(2, new Inlines.from([new Str('Header')])))));
      });
    });

    t.group('SetextHeader', () {
      var header = new SetextHeader(2, new Inlines.from([new Str('Header')]));
      t.test('toString', () {
        t.expect(header.toString(), t.equals('SetextHeader 2 [Str "Header"]'));
      });
      t.test('Special constructors', () {
        t.expect(new SetextHeader.h1(new Inlines.from([new Str('Header')])), t.equals(new SetextHeader(1, new Inlines.from([new Str('Header')]))));
        t.expect(new SetextHeader.h2(new Inlines.from([new Str('Header')])), t.equals(new SetextHeader(2, new Inlines.from([new Str('Header')]))));
      });
      t.test('==', () {
        t.expect(header, t.equals(new SetextHeader(2, new Inlines.from([new Str('Header')]))));
      });
      t.test('!=', () {
        t.expect(header, t.isNot(t.equals(new SetextHeader(3, new Inlines.from([new Str('Header')])))));
        t.expect(header, t.isNot(t.equals(new SetextHeader(2, new Inlines.from([])))));
        t.expect(header, t.isNot(t.equals(new AtxHeader(2, new Inlines.from([new Str('Header')])))));
      });
    });

    t.group('FenceType', () {
      t.test('toString', () {
        t.expect(FenceType.BacktickFence.toString(), t.equals('BacktickFence'));
        t.expect(FenceType.TildeFence.toString(), t.equals('TildeFence'));
      });
      t.test('==', () {
        t.expect(FenceType.BacktickFence, t.equals(FenceType.BacktickFence));
        t.expect(FenceType.TildeFence, t.equals(FenceType.TildeFence));
      });
      t.test('!=', () {
        t.expect(FenceType.BacktickFence, t.isNot(t.equals(FenceType.TildeFence)));
      });
    });

    t.group('IndentedCodeBlock', () {
      var code = new IndentedCodeBlock("Code");
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
      var code = new FencedCodeBlock("Code");
      t.test('toString', () {
        t.expect(code.toString(), t.equals('FencedCodeBlock EmptyAttr Code'));
      });
      t.test('==', () {
        t.expect(code, t.equals(new FencedCodeBlock("Code",
            fenceType: FenceType.BacktickFence, fenceSize: 3, attributes: new EmptyAttr())));
      });
      t.test('!=', () {
        t.expect(code, t.isNot(t.equals(new FencedCodeBlock("Code1"))));
        t.expect(code, t.isNot(t.equals(new FencedCodeBlock("Code", fenceType: FenceType.TildeFence))));
        t.expect(code, t.isNot(t.equals(new FencedCodeBlock("Code", fenceSize: 5))));
        t.expect(code, t.isNot(t.equals(new FencedCodeBlock("Code", attributes: new InfoString('dart')))));
        t.expect(code, t.isNot(t.equals(new IndentedCodeBlock("Code"))));
      });
    });

    t.group('HtmlRawBlock', () {
      var raw = new HtmlRawBlock("<html>");
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
      var blockquote = new Blockquote([new HorizontalRule()]);
      t.test('toString', () {
        t.expect(blockquote.toString(), t.equals('Blockquote [HorizontalRule]'));
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
      var listItem = new ListItem([new HorizontalRule()]);
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
        t.expect(BulletType.MinusBullet.toString(), t.equals('MinusBullet'));
        t.expect(BulletType.PlusBullet.toString(), t.equals('PlusBullet'));
        t.expect(BulletType.StarBullet.toString(), t.equals('StarBullet'));
      });
      t.test('fromChar', () {
        t.expect(BulletType.fromChar('-'), t.equals(BulletType.MinusBullet));
        t.expect(BulletType.fromChar('+'), t.equals(BulletType.PlusBullet));
        t.expect(BulletType.fromChar('*'), t.equals(BulletType.StarBullet));
      });
      t.test('==', () {
        t.expect(BulletType.MinusBullet, t.equals(BulletType.MinusBullet));
        t.expect(BulletType.PlusBullet, t.equals(BulletType.PlusBullet));
        t.expect(BulletType.StarBullet, t.equals(BulletType.StarBullet));
      });
      t.test('!=', () {
        t.expect(BulletType.MinusBullet, t.isNot(t.equals(BulletType.PlusBullet)));
        t.expect(BulletType.MinusBullet, t.isNot(t.equals(BulletType.StarBullet)));
      });
    });

    t.group('IndexSeparator', () {
      t.test('toString', () {
        t.expect(IndexSeparator.DotSeparator.toString(), t.equals('DotSeparator'));
        t.expect(IndexSeparator.ParenthesisSeparator.toString(), t.equals('ParenthesisSeparator'));
      });
      t.test('fromChar', () {
        t.expect(IndexSeparator.fromChar('.').toString(), t.equals('DotSeparator'));
        t.expect(IndexSeparator.fromChar(')').toString(), t.equals('ParenthesisSeparator'));
      });
      t.test('==', () {
        t.expect(IndexSeparator.DotSeparator, t.equals(IndexSeparator.DotSeparator));
        t.expect(IndexSeparator.ParenthesisSeparator, t.equals(IndexSeparator.ParenthesisSeparator));
      });
      t.test('!=', () {
        t.expect(IndexSeparator.ParenthesisSeparator, t.isNot(t.equals(IndexSeparator.DotSeparator)));
      });
    });

    t.group('UnorderedList', () {
      var list = new UnorderedList([new ListItem([new HorizontalRule()])]);
      t.test('toString', () {
        t.expect(list.toString(), t.equals('UnorderedList MinusBullet [ListItem [HorizontalRule]]'));
      });
      t.test('==', () {
        t.expect(list, t.equals(new UnorderedList([new ListItem([new HorizontalRule()])],
            tight: false, bulletType: BulletType.MinusBullet)));
      });
      t.test('!=', () {
        t.expect(list, t.isNot(new UnorderedList([])));
        t.expect(list, t.isNot(new UnorderedList([new ListItem([new HorizontalRule()])], tight: true)));
        t.expect(list, t.isNot(new UnorderedList([new ListItem([new HorizontalRule()])], bulletType: BulletType.PlusBullet)));
        t.expect(list, t.isNot(new OrderedList([new ListItem([new HorizontalRule()])])));
      });
    });

    t.group('OrderedList', () {
      var list = new OrderedList([new ListItem([new HorizontalRule()])]);
      t.test('toString', () {
        t.expect(list.toString(), t.equals('OrderedList start=1 DotSeparator [ListItem [HorizontalRule]]'));
      });
      t.test('==', () {
        t.expect(list, t.equals(new OrderedList([new ListItem([new HorizontalRule()])],
            tight: false, indexSeparator: IndexSeparator.DotSeparator, startIndex: 1)));
      });
      t.test('!=', () {
        t.expect(list, t.isNot(new OrderedList([])));
        t.expect(list, t.isNot(new OrderedList([new ListItem([new HorizontalRule()])], tight: true)));
        t.expect(list, t.isNot(new OrderedList([new ListItem([new HorizontalRule()])], indexSeparator: IndexSeparator.ParenthesisSeparator)));
        t.expect(list, t.isNot(new OrderedList([new ListItem([new HorizontalRule()])], startIndex: 0)));
        t.expect(list, t.isNot(new UnorderedList([new ListItem([new HorizontalRule()])])));
      });
    });

    t.group('Para', () {
      var para = new Para(new Inlines.from([new Str('Para.')]));
      t.test('toString', () {
        t.expect(para.toString(), t.equals('Para [Str "Para."]'));
      });
      t.test('==', () {
        t.expect(para, t.equals(new Para(new Inlines.from([new Str('Para.')]))));
      });
      t.test('!=', () {
        t.expect(para, t.isNot(t.equals(new Para(new Inlines()))));
        t.expect(para, t.isNot(t.equals(new NDash())));
      });
    });

    // Inlines

    t.group('Str', () {
      var str = new Str('Str');
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
      var space = new Space();
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
      var nbsp = new NonBreakableSpace();
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

    t.group('LineBreak', () {
      var lineBreak = new LineBreak();
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
      var mdash = new MDash();
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
      var ndash = new NDash();
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
      var ellipsis = new Ellipsis();
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
      var smartQuote = new SmartQuote(new Inlines.from([new Str('Quote')]), single: false);
      t.test('toString', () {
        t.expect(smartQuote.toString(), t.equals('SmartQuote "[Str "Quote"]"'));
      });
      t.test('==', () {
        t.expect(smartQuote, t.equals(new SmartQuote(new Inlines.from([new Str('Quote')]), single: false)));
      });
      t.test('!=', () {
        t.expect(smartQuote, t.isNot(t.equals(new SmartQuote(new Inlines(), single: false))));
        t.expect(smartQuote, t.isNot(t.equals(new SmartQuote(new Inlines.from([new Str('Quote')]), single: true))));
        t.expect(smartQuote,
            t.isNot(t.equals(new SmartQuote(new Inlines.from([new Str('Quote')]), single: false, open: false))));
        t.expect(smartQuote,
            t.isNot(t.equals(new SmartQuote(new Inlines.from([new Str('Quote')]), single: false, close: false))));
        t.expect(smartQuote, t.isNot(t.equals(null)));
      });
    });

    t.group('Code', () {
      var code = new Code("Code");
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
      var emph = new Emph(new Inlines.from([new Str('Emph')]));
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
      var strong = new Strong(new Inlines.from([new Str('Strong')]));
      t.test('toString', () {
        t.expect(strong.toString(), t.equals('Strong [Str "Strong"]'));
      });
      t.test('==', () {
        t.expect(strong, t.equals(new Strong(new Inlines.from([new Str('Strong')]))));
      });
      t.test('!=', () {
        t.expect(strong, t.isNot(t.equals(new Inlines.from([new Str('Emph')]))));
        t.expect(strong, t.isNot(t.equals(null)));
      });
    });

    t.group('InlineLink', () {
      var link = new InlineLink(new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null));
      t.test('toString', () {
        t.expect(link.toString(), t.equals('InlineLink [Str "Dart"] (Target "https://www.dartlang.org/" null)'));
      });
      t.test('==', () {
        t.expect(link, t.equals(new InlineLink(new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(link, t.isNot(t.equals(new InlineLink(new Inlines(), new Target('https://www.dartlang.org/', null)))));
        t.expect(link, t.isNot(t.equals(new InlineLink(new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(link, t.isNot(t.equals(null)));
      });
    });

    t.group('ReferenceLink', () {
      var link = new ReferenceLink('dart', new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null));
      t.test('toString', () {
        t.expect(link.toString(), t.equals('ReferenceLink[dart] [Str "Dart"] (Target "https://www.dartlang.org/" null)'));
      });
      t.test('==', () {
        t.expect(link, t.equals(new ReferenceLink('dart', new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(link, t.isNot(t.equals(new ReferenceLink('html', new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null)))));
        t.expect(link, t.isNot(t.equals(new ReferenceLink('dart', new Inlines.from([new Str('HTML')]), new Target('https://www.dartlang.org/', null)))));
        t.expect(link, t.isNot(t.equals(new ReferenceLink('dart', new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(link, t.isNot(t.equals(new InlineLink(new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null)))));
        t.expect(link, t.isNot(t.equals(null)));
      });
    });

    t.group('Autolink', () {
      var link = new Autolink('https://www.dartlang.org/');
      t.test('toString', () {
        t.expect(link.toString(), t.equals('Autolink (https://www.dartlang.org/)'));
      });
      t.test('==', () {
        t.expect(link, t.equals(new Autolink('https://www.dartlang.org/')));
      });
      t.test('!=', () {
        t.expect(link, t.isNot(t.equals(new Autolink('http://www.dartlang.org/'))));
        t.expect(link, t.isNot(t.equals(new InlineLink(new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null)))));
      });
    });

    t.group('Autolink.email', () {
      var link = new Autolink.email('test@test.com');
      t.test('toString', () {
        t.expect(link.toString(), t.equals('Autolink (mailto:test@test.com)'));
      });
      t.test('==', () {
        t.expect(link, new Autolink.email('test@test.com'));
        t.expect(link, new Autolink('mailto:test@test.com'));
      });
      t.test('!=', () {
        t.expect(link, t.isNot(t.equals(new Autolink('http://www.dartlang.org/'))));
        t.expect(link, t.isNot(t.equals(new InlineLink(new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null)))));
      });
    });


    t.group('InlineImage', () {
      var image = new InlineImage(new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null));
      t.test('toString', () {
        t.expect(image.toString(), t.equals('InlineImage [Str "Dart"] (Target "https://www.dartlang.org/" null)'));
      });
      t.test('==', () {
        t.expect(image, t.equals(new InlineImage(new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(image, t.isNot(t.equals(new InlineImage(new Inlines(), new Target('https://www.dartlang.org/', null)))));
        t.expect(image, t.isNot(t.equals(new InlineImage(new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(image, t.isNot(t.equals(null)));
      });
    });

    t.group('ReferenceImage', () {
      var image = new ReferenceImage('dart', new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null));
      t.test('toString', () {
        t.expect(image.toString(), t.equals('ReferenceImage[dart] [Str "Dart"] (Target "https://www.dartlang.org/" null)'));
      });
      t.test('==', () {
        t.expect(image, t.equals(new ReferenceImage('dart', new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null))));
      });
      t.test('!=', () {
        t.expect(image, t.isNot(t.equals(new ReferenceImage('html', new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null)))));
        t.expect(image, t.isNot(t.equals(new ReferenceImage('dart', new Inlines.from([new Str('HTML')]), new Target('https://www.dartlang.org/', null)))));
        t.expect(image, t.isNot(t.equals(new ReferenceImage('dart', new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', 'Dart')))));
        t.expect(image, t.isNot(t.equals(new InlineImage(new Inlines.from([new Str('Dart')]), new Target('https://www.dartlang.org/', null)))));
        t.expect(image, t.isNot(t.equals(null)));
      });
    });

    t.group('HtmlRawInline', () {
      var raw = new HtmlRawInline("<a>");
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
  });
}
