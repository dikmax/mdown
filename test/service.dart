library md_proc.test.service;

import 'package:test/test.dart' as t;

import 'package:mdown/mdown.dart';

/// Library APIs tests
void serviceTests() {
  /* TODO
  t.group('README examples test', () {
    t.test('Basic usage', () {
      t.expect(markdownToHtml('# Hello world!'),
          t.equals("<h1>Hello world!</h1>\n"));
    });

    t.test('Parsing', () {
      t.expect(
          CommonMarkParser.defaults.parse('Hello world!\n===').toString(),
          t.equals(
              'Document (SetextHeading 1 [Str "Hello", Space, Str "world", Str "!"] EmptyAttr)'));
    });

    t.test('Writing html', () {
      final Document doc = CommonMarkParser.defaults.parse('Hello world!\n===');
      final String res = HtmlWriter.defaults.write(doc);
      t.expect(res, t.equals('<h1>Hello world!</h1>\n'));
    });

    t.test('Writing markdown', () {
      final Document doc = CommonMarkParser.defaults.parse('Hello world!\n===');
      final String res = MarkdownWriter.defaults.write(doc);
      t.expect(res, t.equals('Hello world!\n============\n'));
    });

    t.test('Smart punctuation', () {
      final Document doc = CommonMarkParser.strict.parse('...');
      final String res = HtmlWriter.strict.write(doc);
      t.expect(res, t.equals('<p>...</p>\n'));
    });
  });*/
}
