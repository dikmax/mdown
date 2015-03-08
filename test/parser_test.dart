import 'dart:io';
import 'package:unittest/unittest.dart' as t;
import 'package:md_proc/md_proc.dart';
import 'package:md_proc/src/markdown_writer.dart';

const int STATE_WAIT = 0;
const int STATE_MARKDOWN = 1;
const int STATE_HTML = 2;

// TODO add own tests specially for fenced code block in list

typedef void TestFunc(int num, String source, String destination);

Map<String, String> readFile(fileName) {
  Map<String, String> result = <String, String>{};

  File file = new File(fileName);
  int state = STATE_WAIT;
  List<String> destination = [];
  List<String> source = [];
  List<String> lines = file.readAsLinesSync();
  for (String line in lines) {
    if (line == ".") {
      state++;
      if (state == 3) {
        result[source.map((line) => line + "\n").join()] = destination.map((line) => line + "\n").join();
        state = STATE_WAIT;
        destination = [];
        source = [];
      }
    } else if (state == STATE_MARKDOWN) {
      source.add(line);
    } else if (state == STATE_HTML) {
      destination.add(line);
    }
  }

  return result;
}

void fileTest(name, fileName, TestFunc testFunc) {
  t.group(name, () {
    var path = new List.from(Platform.script.pathSegments);
    var start = 1;
    if (path[path.length - 2] == '__test_runner') {
      start = 2;
    }
    path.replaceRange(path.length - start, path.length, [fileName]);
    var filePath = Platform.script.replace(pathSegments: path).toFilePath();
    Map<String, String> tests = readFile(filePath);

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

  t.Description describe(t.Description description) => inner.describe(description);

  t.Description describeMismatch(item, t.Description mismatchDescription,
                                 Map matchState, bool verbose) {
    t.Description d = inner.describeMismatch(item, mismatchDescription, matchState, verbose);
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

  t.Description describe(t.Description description) => inner.describe(description);

  t.Description describeMismatch(item, t.Description mismatchDescription,
                                 Map matchState, bool verbose) {
    t.Description d = inner.describeMismatch(item, mismatchDescription, matchState, verbose);
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

TestFunc mdToHtmlTest(Options options) => (int num, String mdOrig, String html) {
  CommonMarkParser parser = new CommonMarkParser(options);
  HtmlWriter writer = new HtmlWriter(options);
  MarkdownWriter mdWriter = new MarkdownWriter(options);

  String md = mdOrig.replaceAll("→", "\t").replaceAll("␣", " ");
  html = html.replaceAll("→", "\t").replaceAll("␣", " ");

  t.test('html $num', () {
    Document doc = parser.parse(md);
    t.expect(tidy(writer.write(doc)), new ExampleDescription(t.equals(tidy(html)), mdOrig));
  });
  t.test('markdown $num', () {
    var generatedMarkdown = mdWriter.write(parser.parse(md));
    Document doc = parser.parse(generatedMarkdown);
    t.expect(tidy(writer.write(doc)), new Example2Description(t.equals(tidy(html)), mdOrig, generatedMarkdown));
  });
};

TestFunc mdToMdTest(Options options) => (int num, String md, String destMd) {
  CommonMarkParser parser = new CommonMarkParser(options);
  MarkdownWriter writer = new MarkdownWriter(options);
  t.test(num.toString(), () {
    var generatedMarkdown = writer.write(parser.parse(md));
    t.expect(generatedMarkdown, new ExampleDescription(t.equals(destMd), md));
  });
};


void main() {
  // CommonMark tests
  fileTest("CommonMark", "spec.txt", mdToHtmlTest(Options.STRICT));
  // Additional tests
  fileTest("Additional", "additionalMarkdownToHtml.txt", mdToHtmlTest(Options.STRICT));
  // Additional tests
  fileTest("SmartPunct", "smart_punct.txt", mdToHtmlTest(Options.DEFAULT));
  // Markdown to markdown tests
  fileTest("md2md", "markdownToMarkdown.txt", mdToMdTest(Options.STRICT));

  //t.filterTests("(md2md | markdown )");
  //t.filterTests(r"^md2md 5$");
}

