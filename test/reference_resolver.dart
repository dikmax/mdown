library md_proc.test.reference_resolver;

import 'package:test/test.dart' as t;

import 'package:md_proc/md_proc.dart';

Target linkResolver(String normalizedReference, String reference) {
  if (reference == "reference") {
    return new Target(reference, null);
  } else {
    return null;
  }
}


String md1Test = r'''
This is a [reference].

[reference]: reference2
''';

String md1Pattern = r'''
This is a [reference].

[reference]: reference2
''';

String md2Test = r'''
This is a [reference].
''';

String md2Pattern = r'''
This is a [reference].

[reference]: reference
''';

String md3Test = r'''
This is a [link].
''';

String md3Pattern = r'''
This is a [link].
''';

void referenceResolverTests() {
  CommonMarkParser parser = new CommonMarkParser(new Options(linkResolver: linkResolver));
  CommonMarkParser defaultParser = CommonMarkParser.defaults;

  t.group("Custom reference resolver test", () {
    t.test("Should leave defined links as is", () {
      Document d1 = parser.parse(md1Test);
      Document d2 = defaultParser.parse(md1Pattern);
      t.expect(d1, t.equals(d2));
    });
    t.test("May resolve undefined links", () {
      Document d1 = parser.parse(md2Test);
      Document d2 = defaultParser.parse(md2Pattern);
      t.expect(d1, t.equals(d2));
    });
    t.test("May not resolve undefined links", () {
      Document d1 = parser.parse(md3Test);
      Document d2 = defaultParser.parse(md3Pattern);
      t.expect(d1, t.equals(d2));
    });
  });
}
