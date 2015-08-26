library md_proc.test.parser;

import 'package:test/test.dart' as t;
import 'package:md_proc/md_proc.dart';
import 'package:md_proc/markdown_writer.dart';

const int stateWait = 0;
const int stateMarkdown = 1;
const int stateHtml = 2;

enum TestType { html, markdown }

typedef bool FilterFunc(TestType type, int num);
bool emptyFilter(type, num) => true;
typedef void TestFunc(int num, String source, String destination);

void tests(String name, Map<String, String> tests, TestFunc testFunc) {
  t.group(name, () {
    int num = 0;
    tests.forEach((String source, String destination) {
      ++num;
      testFunc(num, source, destination);
    });
  });
}

class ExampleDescription extends t.Matcher {
  t.Matcher inner;
  String example;

  ExampleDescription(this.inner, this.example);

  bool matches(item, Map matchState) => inner.matches(item, matchState);

  t.Description describe(t.Description description) =>
      inner.describe(description);

  t.Description describeMismatch(
      item, t.Description mismatchDescription, Map matchState, bool verbose) {
    t.Description d =
        inner.describeMismatch(item, mismatchDescription, matchState, verbose);
    d.add("\n  Source: \n" + example);
    return d;
  }
}

class Example2Description extends t.Matcher {
  t.Matcher inner;
  String example;
  String example2;

  Example2Description(this.inner, this.example, this.example2);

  bool matches(item, Map matchState) => inner.matches(item, matchState);

  t.Description describe(t.Description description) =>
      inner.describe(description);

  t.Description describeMismatch(
      item, t.Description mismatchDescription, Map matchState, bool verbose) {
    t.Description d =
        inner.describeMismatch(item, mismatchDescription, matchState, verbose);
    d.add("\n  Source: \n" + example);
    d.add("\n  Source 2: \n" + example2);
    return d;
  }
}

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

  return result.join('\n').trim();
}

TestFunc mdToHtmlTest(Options options, [FilterFunc filter = emptyFilter]) =>
    (int num, String mdOrig, String html) {
      CommonMarkParser parser = new CommonMarkParser(options);
      HtmlWriter writer = new HtmlWriter(options);
      MarkdownWriter mdWriter = new MarkdownWriter(options);

      String md = mdOrig.replaceAll("→", "\t").replaceAll("␣", " ");
      html = html.replaceAll("→", "\t").replaceAll("␣", " ");

      if (filter(TestType.html, num)) {
        t.test('html $num', () {
          Document doc = parser.parse(md);
          t.expect(tidy(writer.write(doc)),
              new ExampleDescription(t.equals(tidy(html)), mdOrig));
        });
      }
      if (filter(TestType.markdown, num)) {
        t.test('markdown $num', () {
          var generatedMarkdown = mdWriter.write(parser.parse(md));
          Document doc = parser.parse(generatedMarkdown);
          t.expect(
              tidy(writer.write(doc)),
              new Example2Description(
                  t.equals(tidy(html)), mdOrig, generatedMarkdown));
        });
      }
    };

TestFunc mdToMdTest(Options options, [FilterFunc filter = emptyFilter]) =>
    (int num, String md, String destMd) {
      CommonMarkParser parser = new CommonMarkParser(options);
      MarkdownWriter writer = new MarkdownWriter(options);

      if (filter(TestType.markdown, num)) {
        t.test(num.toString(), () {
          var generatedMarkdown = writer.write(parser.parse(md));
          t.expect(
              generatedMarkdown, new ExampleDescription(t.equals(destMd), md));
        });
      }
    };

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
