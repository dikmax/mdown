library md_proc.test.reference_resolver;

import 'package:test/test.dart' as t;

import 'package:md_proc/md_proc.dart';

Target _linkResolver(String normalizedReference, String reference) {
  if (reference == "reference") {
    return new Target(reference, null);
  } else {
    return null;
  }
}

String _md1Test = r'''
This is a [reference].

[reference]: reference2
''';

String _md1Pattern = r'''
This is a [reference].

[reference]: reference2
''';

String _md2Test = r'''
This is a [reference].
''';

String _md2Pattern = r'''
This is a [reference].

[reference]: reference
''';

String _md3Test = r'''
This is a [link].
''';

String _md3Pattern = r'''
This is a [link].
''';

/// Link resolver tests
void referenceResolverTests() {
  CommonMarkParser parser =
      new CommonMarkParser(new Options(linkResolver: _linkResolver));
  CommonMarkParser defaultParser = CommonMarkParser.defaults;

  t.group("Custom reference resolver test", () {
    t.test("Should leave defined links as is", () {
      Document d1 = parser.parse(_md1Test);
      Document d2 = defaultParser.parse(_md1Pattern);
      t.expect(d1, t.equals(d2));
    });
    t.test("May resolve undefined links", () {
      Document d1 = parser.parse(_md2Test);
      Document d2 = defaultParser.parse(_md2Pattern);
      t.expect(d1, t.equals(d2));
    });
    t.test("May not resolve undefined links", () {
      Document d1 = parser.parse(_md3Test);
      Document d2 = defaultParser.parse(_md3Pattern);
      t.expect(d1, t.equals(d2));
    });
  });
}
