import 'package:md_proc/options.dart';

import 'custom_classes.dart';
import 'parser.dart';
import 'reference_resolver.dart';
import 'service.dart';
import 'data/test_data.dart';

/// Main tests runner
void main() {
  serviceTests();

  // CommonMark tests
  tests("CommonMark [strict]", specification, mdToHtmlTest(Options.strict));
  tests("CommonMark [strict]", specification, mdToHtml2Test(Options.strict));

  // Additional tests
  //tests("Additional", additionalMarkdownToHtml, mdToHtmlTest(Options.strict, (t, num) => t == TestType.html && num == 19));
  tests("Additional [strict]", additionalMarkdownToHtml,
      mdToHtmlTest(Options.strict));
  tests("Additional [strict]", additionalMarkdownToHtml,
      mdToHtml2Test(Options.strict));

  // commonmark.js regression tests
  tests("Regressions [strict]", regression, mdToHtmlTest(Options.strict));
  tests("Regressions [strict]", regression, mdToHtml2Test(Options.strict));

  // SmartPunct
  tests("SmartPunct [commonmark]", smartPunctuation,
      mdToHtmlTest(Options.commonmark));
  tests("SmartPunct [commonmark]", smartPunctuation,
      mdToHtml2Test(Options.commonmark));

  // Strikeout
  tests("Strikeout", strikeout, mdToHtmlTest(new Options(strikeout: true)));
  tests("Strikeout", strikeout, mdToHtml2Test(new Options(strikeout: true)));
  tests("Strikeout spec", specification,
      mdToHtmlTest(new Options(strikeout: true)));
  tests("Strikeout spec", specification,
      mdToHtml2Test(new Options(strikeout: true)));

  // Subscript
  tests("Subscript", subscript, mdToHtmlTest(new Options(subscript: true)));
  tests("Subscript", subscript, mdToHtml2Test(new Options(subscript: true)));
  tests("Subscript spec", specification,
      mdToHtmlTest(new Options(subscript: true)));
  tests("Subscript spec", specification,
      mdToHtml2Test(new Options(subscript: true)));

  // Superscript
  tests(
      "Superscript", superscript, mdToHtmlTest(new Options(superscript: true)));
  tests(
      "Superscript", superscript, mdToHtml2Test(new Options(superscript: true)));
  tests("Superscript spec", specification,
      mdToHtmlTest(new Options(superscript: true)));
  tests("Superscript spec", specification,
      mdToHtml2Test(new Options(superscript: true)));

  // Strikeout and subscript
  tests("Strikeout and subscript", strikeoutAndSubscript,
      mdToHtmlTest(new Options(strikeout: true, subscript: true)));
  tests("Strikeout and subscript", strikeoutAndSubscript,
      mdToHtml2Test(new Options(strikeout: true, subscript: true)));
  tests("Strikeout and subscript spec", specification,
      mdToHtmlTest(new Options(strikeout: true, subscript: true)));
  tests("Strikeout and subscript spec", specification,
      mdToHtml2Test(new Options(strikeout: true, subscript: true)));

  return;
  // TeX Math between dollars
  tests("TeX math dollars", texMathDollars,
      mdToHtmlTest(new Options(texMathDollars: true)));
  tests("TeX math dollars spec", specification,
      mdToHtmlTest(new Options(texMathDollars: true)));

  // TeX Math between backslashed `()` or `[]`
  Set<int> texMathSingleBackslashContradictions =
      new Set<int>.from(<int>[282, 475, 491]);
  tests("TeX math single backslash", texMathSingleBackslash,
      mdToHtmlTest(new Options(texMathSingleBackslash: true)));
  tests(
      "TeX math single backslash spec",
      specification,
      mdToHtmlTest(new Options(texMathSingleBackslash: true),
          (_, int num) => !texMathSingleBackslashContradictions.contains(num)));

  // TeX Math between double backslashed `()` or `[]`
  Set<int> texMathDoubleBackslashContradictions = new Set<int>.from(<int>[]);
  tests("TeX math double backslash", texMathDoubleBackslash,
      mdToHtmlTest(new Options(texMathDoubleBackslash: true)));
  tests(
      "TeX math double backslash spec",
      specification,
      mdToHtmlTest(new Options(texMathDoubleBackslash: true),
          (_, int num) => !texMathDoubleBackslashContradictions.contains(num)));

  // Raw TeX
  Set<int> rawTexContradictions = new Set<int>.from(<int>[]);
  tests("Raw TeX", rawTex, mdToHtmlTest(new Options(rawTex: true)));
  tests(
      "Raw TeX spec",
      specification,
      mdToHtmlTest(new Options(rawTex: true),
          (_, int num) => !rawTexContradictions.contains(num)));

  // Markdown to markdown tests
  // tests("md2md [strict]", markdownToMarkdown, mdToMdTest(Options.strict));

  // Custom classes
  customClassesTests();

  // Custom resolver
  referenceResolverTests();
}
