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
  int testNo = 0;
  for (String line in lines) {
    if (line == ".") {
      state++;
      if (state == 3) {
        ++testNo;
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
    Map<String, String> tests = readFile(fileName);

    int num = 0;
    tests.forEach((String source, String destination) {
      ++num;
      testFunc(num, source, destination);
    });
  });
}

void main() {
  // CommonMark tests
  fileTest("CommonMark", "spec.txt", mdToHtmlTest);
  // Additional tests
  fileTest("Additional", "additionalMarkdownToHtml.txt", mdToHtmlTest);
  // Markdown to markdown tests
  fileTest("md2md", "markdownToMarkdown.txt", mdToMdTest);

  //t.filterTests(" markdown ");
  //t.filterTests(r"^CommonMark html 3$");
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


final commonMarkParser = CommonMarkParser.DEFAULT;
final htmlWriter = HtmlWriter.DEFAULT;
final markdownWriter = MarkdownWriter.DEFAULT;
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

void mdToHtmlTest(int num, String mdOrig, String html) {
  String md = mdOrig.replaceAll("→", "\t").replaceAll("␣", " ");
  html = html.replaceAll("→", "\t").replaceAll("␣", " ");


  t.test('html $num', () {
    Document doc = commonMarkParser.parse(md);
    String result = htmlWriter.write(doc);
    t.expect(tidy(htmlWriter.write(doc)), new ExampleDescription(t.equals(tidy(html)), mdOrig));
  });
  t.test('markdown $num', () {
    var generatedMarkdown = markdownWriter.write(commonMarkParser.parse(md));
    Document doc = commonMarkParser.parse(generatedMarkdown);
    String result = htmlWriter.write(doc);
    t.expect(tidy(htmlWriter.write(doc)), new Example2Description(t.equals(tidy(html)), mdOrig, generatedMarkdown));
  });
}

void mdToMdTest(int num, String md, String destMd) {
  t.test(num.toString(), () {
    var generatedMarkdown = markdownWriter.write(commonMarkParser.parse(md));
    t.expect(generatedMarkdown, new ExampleDescription(t.equals(destMd), md));
  });
}
