library md_proc.test.parser;

import 'package:test/test.dart' as t;
import 'package:md_proc/md_proc.dart';
import 'package:md_proc/markdown_writer.dart';

/// Types of tests
enum TestType {
  /// html->md test
  html,

  /// html->md->html->md test
  markdown
}

/// Filter function
typedef bool FilterFunc(TestType type, int num);

/// Default filter function, that accepts everything
bool emptyFilter(TestType type, int num) => true;

/// Inner tests iterable function
typedef void TestFunc(int num, String source, String destination);

/// Actual test function
void tests(String name, Map<String, String> tests, TestFunc testFunc) {
  t.group(name, () {
    int num = 0;
    tests.forEach((String source, String destination) {
      ++num;
      testFunc(num, source, destination);
    });
  });
}

class _ExampleDescription extends t.Matcher {
  t.Matcher inner;
  String example;

  _ExampleDescription(this.inner, this.example);

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) =>
      inner.matches(item, matchState);

  @override
  t.Description describe(t.Description description) =>
      inner.describe(description);

  @override
  t.Description describeMismatch(
      dynamic item,
      t.Description mismatchDescription,
      Map<dynamic, dynamic> matchState,
      bool verbose) {
    t.Description d =
        inner.describeMismatch(item, mismatchDescription, matchState, verbose);
    d.add("\n  Source: \n" + example);
    return d;
  }
}

class _Example2Description extends t.Matcher {
  t.Matcher inner;
  String example;
  String example2;

  _Example2Description(this.inner, this.example, this.example2);

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) =>
      inner.matches(item, matchState);

  @override
  t.Description describe(t.Description description) =>
      inner.describe(description);

  @override
  t.Description describeMismatch(
      dynamic item,
      t.Description mismatchDescription,
      Map<dynamic, dynamic> matchState,
      bool verbose) {
    t.Description d =
        inner.describeMismatch(item, mismatchDescription, matchState, verbose);
    d.add("\n  Source: \n" + example);
    d.add("\n  Source 2: \n" + example2);
    return d;
  }
}

RegExp _leadingSpacesRegExp = new RegExp(r'^ *');
RegExp _trailingSpacesRegExp = new RegExp(r' *$');
RegExp _consecutiveSpacesRegExp = new RegExp(r' +');
RegExp _spaceBeforeTagCloseRegExp = new RegExp(r' *\/>');

String _tidy(String html) {
  List<String> lines = html.split('\n');
  bool inPre = false;
  List<String> result = <String>[];
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
      line = line.replaceAll(_leadingSpacesRegExp, '');
      // remove trailing spaces
      line = line.replaceAll(_trailingSpacesRegExp, '');
      // collapse consecutive spaces
      line = line.replaceAll(_consecutiveSpacesRegExp, ' ');
      // collapse space before /> in tag
      line = line.replaceAll(_spaceBeforeTagCloseRegExp, '/>');
      // skip blank line
      if (line == '') {
        continue;
      }
      result.add(line);
    }
  }

  return result.join('\n').trim();
}

/// Generate md->html tests
TestFunc mhTest(Options options, [FilterFunc filter = emptyFilter]) {
  CommonMarkParser parser = new CommonMarkParser(options);
  HtmlWriter writer = new HtmlWriter(options);

  return (int num, String mdOrig, String html) {
    if (filter(TestType.html, num)) {
      t.test('html $num', () {
        String md = mdOrig.replaceAll("→", "\t").replaceAll("␣", " ");
        html = html.replaceAll("→", "\t").replaceAll("␣", " ");

        Document doc = parser.parse(md);
        t.expect(_tidy(writer.write(doc)),
            new _ExampleDescription(t.equals(_tidy(html)), mdOrig));
      });
    }
  };
}

/// Generate md->html->md->html tests
TestFunc mhmhTest(Options options, [FilterFunc filter = emptyFilter]) {
  CommonMarkParser parser = new CommonMarkParser(options);
  HtmlWriter writer = new HtmlWriter(options);
  MarkdownWriter mdWriter = new MarkdownWriter(options);

  return (int num, String mdOrig, String html) {
    if (filter(TestType.markdown, num)) {
      t.test('markdown $num', () {
        String md = mdOrig.replaceAll("→", "\t").replaceAll("␣", " ");
        html = html.replaceAll("→", "\t").replaceAll("␣", " ");

        String generatedMarkdown = mdWriter.write(parser.parse(md));
        Document doc = parser.parse(generatedMarkdown);
        t.expect(
            _tidy(writer.write(doc)),
            new _Example2Description(
                t.equals(_tidy(html)), mdOrig, generatedMarkdown));
      });
    }
  };
}

/// Generate md->html->md tests
/*
TestFunc mdToMdTest(Options options, [FilterFunc filter = emptyFilter]) =>
    (int num, String md, String destMd) {
      CommonMarkParser parser = new CommonMarkParser(options);
      MarkdownWriter writer = new MarkdownWriter(options);

      if (filter(TestType.markdown, num)) {
        t.test(num.toString(), () {
          String generatedMarkdown = writer.write(parser.parse(md));
          t.expect(
              generatedMarkdown, new _ExampleDescription(t.equals(destMd), md));
        });
      }
    };*/

/*
void preprocessTest() {
  t.group('Markdown preprocess', () {
    CommonMarkParser parser = new CommonMarkParser(options);
    HtmlWriter writer = new HtmlWriter(options);

    t.test('Line endings', () {

    });
  });
}
*/
