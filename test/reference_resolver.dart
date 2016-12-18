library md_proc.test.reference_resolver;

@t.Skip("Not implemented")
import 'package:test/test.dart' as t;

import 'package:mdown/mdown.dart';
import 'package:mdown/ast/standard_ast_factory.dart';

Target _linkResolver(String normalizedReference, String reference) {
  if (reference == "reference") {
    return astFactory.target(astFactory.targetLink(reference), null);
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
  final CommonMarkParser parser =
      new CommonMarkParser(const Options(linkResolver: _linkResolver));
  final CommonMarkParser defaultParser = CommonMarkParser.defaults;

  t.group("Custom reference resolver test", () {
    t.test("Should leave defined links as is", () {
      final Document d1 = parser.parse(_md1Test);
      final Document d2 = defaultParser.parse(_md1Pattern);
      t.expect(d1, t.equals(d2));
    });
    t.test("May resolve undefined links", () {
      final Document d1 = parser.parse(_md2Test);
      final Document d2 = defaultParser.parse(_md2Pattern);
      t.expect(d1, t.equals(d2));
    });
    t.test("May not resolve undefined links", () {
      final Document d1 = parser.parse(_md3Test);
      final Document d2 = defaultParser.parse(_md3Pattern);
      t.expect(d1, t.equals(d2));
    });
  });
}
