library mdown.test.reference_resolver;

@t.Skip("Not implemented")
import 'package:test/test.dart' as t;

import 'package:mdown/mdown.dart';
import 'package:mdown/ast/standard_ast_factory.dart';

Target _linkResolver(String normalizedReference, String reference) {
  if (reference == "reference") {
    return astFactory.target(reference, null);
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
  const Options options = const Options(linkResolver: _linkResolver);

  t.group("Custom reference resolver test", () {
    t.test("Should leave defined links as is", () {
      final String d1 = markdownToHtml(_md1Test, options);
      final String d2 = markdownToHtml(_md1Pattern);
      t.expect(d1, t.equals(d2));
    });
    t.test("May resolve undefined links", () {
      final String d1 = markdownToHtml(_md2Test, options);
      final String d2 = markdownToHtml(_md2Pattern);
      t.expect(d1, t.equals(d2));
    });
    t.test("May not resolve undefined links", () {
      final String d1 = markdownToHtml(_md3Test, options);
      final String d2 = markdownToHtml(_md3Pattern);
      t.expect(d1, t.equals(d2));
    });
  });
}
