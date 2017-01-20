library mdown.test.blns;

import 'package:test/test.dart' as t;

import 'data/test_data.dart';

import 'package:mdown/mdown.dart';

/// [Big list of naughty strings](https://github.com/minimaxir/big-list-of-naughty-strings).
void blnsTests() {
  t.group('Big list of naughty strings', () {
    int num = 0;
    blns.forEach((String string) {
      ++num;
      t.test(num.toString(), () {
        final String result = "<p>$string</p>\n";
        t.expect(markdownToHtml(result), t.equals(result));
      });
    });
  });
}
