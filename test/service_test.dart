library serviceTest;

import 'package:unittest/unittest.dart' as t;

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
}
