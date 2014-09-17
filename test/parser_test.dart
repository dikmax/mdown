import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:unittest/unittest.dart' as t;
import 'package:markdowntypography/markdown.dart';
import 'package:parsers/parsers.dart';
import 'package:markdowntypography/builder.dart' as B;
import 'package:markdowntypography/htmlWriter.dart' as HW;

const int STATE_WAIT = 0;
const int STATE_MARKDOWN = 1;
const int STATE_HTML = 2;

// TODO add own tests specially for fenced code block in list

void fileTest(name, fileName) {
  t.group(name, () {
    File file = new File(fileName);
    int state = STATE_WAIT;
    List<String> html = [];
    List<String> markdown = [];
    List<String> lines = file.readAsLinesSync();
    int testNo = 0;
    for (String line in lines) {
      if (line == ".") {
        state++;
        if (state == 3) {
          ++testNo;
          testCommonMarkdown(testNo, markdown.join('\n') + "\n", html.join('\n') + "\n");
          state = STATE_WAIT;
          html = [];
          markdown = [];
        }
      } else if (state == STATE_MARKDOWN) {
        markdown.add(line);
      } else if (state == STATE_HTML) {
        html.add(line);
      }
    }
  });
}

void main() {
  // My tests
  fileTest("My", "tests.txt");
  // CommonMark tests
  fileTest("stmd", "stmd/spec.txt");
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


final commonMarkParser = CommonMarkParser.DEFAULT;
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
void testCommonMarkdown(int num, String mdOrig, String html) {
  String md = mdOrig.replaceAll("→", "\t").replaceAll("␣", " ");
  html = html.replaceAll("→", "\t").replaceAll("␣", " ");

  t.test(num.toString(), () {
    Document doc = commonMarkParser.parse(md);
    String result = HW.write(doc);
    t.expect(tidy(HW.write(doc)), new ExampleDescription(t.equals(tidy(html)), mdOrig));
  });
}