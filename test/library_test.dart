import 'package:md_proc/options.dart';

import 'custom_classes.dart';
import 'individual_parsers.dart';
import 'parser.dart';
import 'reference_resolver.dart';
import 'service.dart';
import 'data/test_data.dart';

/// Main tests runner
void main() {
  // serviceTests();

  // individualParsersTests();

  // CommonMark tests
  tests("CommonMark", specification, mdToHtmlTest(Options.strict, (t, num) => t == TestType.html && (num == 5)));
  //tests("CommonMark", specification, mdToHtmlTest(Options.strict, (t, num) => t == TestType.html && (num >= 103 && num < 144)));
  //tests("CommonMark", specification, mdToHtmlTest(Options.strict, (t, num) => t == TestType.html));
  //tests("CommonMark [strict]", specification, mdToHtmlTest(Options.strict));

  return;
  // Additional tests
  //tests("Additional", additionalMarkdownToHtml, mdToHtmlTest(Options.strict, (t, num) => t == TestType.html && num == 19));
  tests("Additional [strict]", additionalMarkdownToHtml,
      mdToHtmlTest(Options.strict));

  // SmartPunct
  tests("SmartPunct [commonmark]", smartPunctuation,
      mdToHtmlTest(Options.commonmark));

  // Strikeout
  tests("Strikeout", strikeout, mdToHtmlTest(new Options(strikeout: true)));
  tests("Strikeout spec", specification,
      mdToHtmlTest(new Options(strikeout: true)));

  // Subscript
  tests("Subscript", subscript, mdToHtmlTest(new Options(subscript: true)));
  tests("Subscript spec", specification,
      mdToHtmlTest(new Options(subscript: true)));

  // Superscript
  tests(
      "Superscript", superscript, mdToHtmlTest(new Options(superscript: true)));
  tests("Superscript spec", specification,
      mdToHtmlTest(new Options(superscript: true)));

  // Strikeout
  tests("Strikeout and subscript", strikeoutAndSubscript,
      mdToHtmlTest(new Options(strikeout: true, subscript: true)));
  tests("Strikeout and subscript spec", specification,
      mdToHtmlTest(new Options(strikeout: true, subscript: true)));

  // TeX Math between dollars
  tests("TeX math dollars", texMathDollars,
      mdToHtmlTest(new Options(texMathDollars: true)));
  tests("TeX math dollars spec", specification,
      mdToHtmlTest(new Options(texMathDollars: true)));

  // TeX Math between backslashed `()` or `[]`
  Set<int> texMathSingleBackslashContradictions =
      new Set<int>.from([282, 475, 491]);
  tests("TeX math single backslash", texMathSingleBackslash,
      mdToHtmlTest(new Options(texMathSingleBackslash: true)));
  tests(
      "TeX math single backslash spec",
      specification,
      mdToHtmlTest(new Options(texMathSingleBackslash: true),
          (_, int num) => !texMathSingleBackslashContradictions.contains(num)));

  // TeX Math between double backslashed `()` or `[]`
  Set<int> texMathDoubleBackslashContradictions = new Set<int>.from([]);
  tests("TeX math double backslash", texMathDoubleBackslash,
      mdToHtmlTest(new Options(texMathDoubleBackslash: true)));
  tests(
      "TeX math double backslash spec",
      specification,
      mdToHtmlTest(new Options(texMathDoubleBackslash: true),
          (_, int num) => !texMathDoubleBackslashContradictions.contains(num)));

  // Raw TeX
  Set<int> rawTexContradictions = new Set<int>.from([]);
  tests("Raw TeX", rawTex, mdToHtmlTest(new Options(rawTex: true)));
  tests(
      "Raw TeX spec",
      specification,
      mdToHtmlTest(new Options(rawTex: true),
          (_, int num) => !rawTexContradictions.contains(num)));

  // Markdown to markdown tests
  tests("md2md [strict]", markdownToMarkdown, mdToMdTest(Options.strict));

  // Custom classes
  customClassesTests();

  // Custom resolver
  referenceResolverTests();
}
