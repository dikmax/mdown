library mdown.test.service;

import 'package:test/test.dart' as t;

import 'package:mdown/mdown.dart';
import 'package:mdown/ast/standard_ast_factory.dart';

/// Library APIs tests
void serviceTests() {
  t.group('README examples test', () {
    t.test('Basic usage', () {
      t.expect(
          markdownToHtml('# Hello world!'), t.equals('<h1>Hello world!</h1>\n'));
    });

    t.test('Extensions 1', () {
      const Options options = Options(superscript: true);
      final String res = markdownToHtml('Hello world!\n===\n', options);
      t.expect(res, t.equals('<h1>Hello world!</h1>\n'));
    });

    t.test('Extensions 2', () {
      final String res = markdownToHtml('Hello world!\n===', Options.strict);
      t.expect(res, t.equals('<h1>Hello world!</h1>\n'));
    });

    t.test('Fenced code attributes', () {
      final String res = markdownToHtml(
          '``` {#someId .class1 .class2 key=value}\ncode\n```',
          const Options(fencedCodeAttributes: true));
      t.expect(
          res,
          t.equals('<pre id="someId" class="class1 class2" key="value">'
              '<code>code\n</code></pre>\n'));
    });

    t.test('Heading attributes', () {
      final String res = markdownToHtml(
          '# Heading 1 {#someId}\n\n'
              'Heading 2 {.someClass}\n'
              '-------------------',
          const Options(headingAttributes: true));
      t.expect(
          res,
          t.equals('<h1 id="someId">Heading 1</h1>\n'
              '<h2 class="someClass">Heading 2</h2>\n'));
    });

    t.test('Link attributes', () {
      final String res = markdownToHtml(
          '![](image.jpg){width="800" height="600"}\n\n'
          '[test][ref]\n\n'
          '[ref]: http://test.com/ {#id}\n',
          const Options(linkAttributes: true));
      t.expect(
          res,
          t.equals('<p><img src="image.jpg" alt="" width="800" height="600" /></p>\n'
            '<p><a href="http://test.com/" id="id">test</a></p>\n'));
    });

    t.test('Link resolver', () {
      const String library = 'mdown';
      const String version = '0.11.0';
      Target linkResolver(String normalizedReference, String reference) {
        if (reference.startsWith('new ')) {
          final String className = reference.substring(4);
          return astFactory.target(
              'http://www.dartdocs.org/documentation/$library/$version/index.html#$library/$library.$className@id_$className-',
              null);
        } else {
          return null;
        }
      }

      final String res = markdownToHtml(
          'Hello world!\n===', Options(linkResolver: linkResolver));
      t.expect(res, t.equals('<h1>Hello world!</h1>\n'));
    });
  });
}
