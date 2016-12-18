library md_proc.test.parser;

import 'package:test/test.dart' as t;
import 'package:mdown/mdown.dart';

/// Filter function
typedef bool FilterFunc(int num);

/// Default filter function, that accepts everything
bool emptyFilter(int num) => true;

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
    final t.Description d = inner.describeMismatch(
        item, mismatchDescription, matchState, verbose)
      ..add("\n  Source: \n" + example);
    return d;
  }
}

RegExp _leadingSpacesRegExp = new RegExp(r'^ *');
RegExp _trailingSpacesRegExp = new RegExp(r' *$');
RegExp _consecutiveSpacesRegExp = new RegExp(r' +');
RegExp _spaceBeforeTagCloseRegExp = new RegExp(r' */>');

String _tidy(String html) {
  final List<String> lines = html.split('\n');
  bool inPre = false;
  final List<String> result = <String>[];
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
TestFunc generateTestFunc(Options options, [FilterFunc filter = emptyFilter]) {
  final CommonMarkParser parser = new CommonMarkParser(options);
  final HtmlWriter writer = new HtmlWriter(options);

  return (int num, String mdOrig, String html) {
    if (filter(num)) {
      t.test('html $num', () {
        final String md = mdOrig.replaceAll("→", "\t").replaceAll("␣", " ");
        html = html.replaceAll("→", "\t").replaceAll("␣", " ");

        final Document doc = parser.parse(md);
        t.expect(_tidy(writer.write(doc)),
            new _ExampleDescription(t.equals(_tidy(html)), mdOrig));
      });
    }
  };
}
