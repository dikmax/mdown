import 'package:md_proc/options.dart';

import 'custom_classes.dart';
import 'parser.dart';
import 'reference_resolver.dart';
import 'service.dart';
import 'data/test_data.dart';

/// Main tests runner
void main() {
  serviceTests();

  TestFunc strictMHTestFunc = mhTest(Options.strict);
  TestFunc strictMHMHTestFunc = mhmhTest(Options.strict);

  // CommonMark tests
  tests("CommonMark [strict]", specification, strictMHTestFunc);
  tests("CommonMark [strict]", specification, strictMHMHTestFunc);

  // Additional tests
  //tests("Additional", additionalMarkdownToHtml, mdToHtmlTest(Options.strict, (t, num) => t == TestType.html && num == 19));
  tests("Additional [strict]", additionalMarkdownToHtml, strictMHTestFunc);
  tests("Additional [strict]", additionalMarkdownToHtml, strictMHMHTestFunc);

  // commonmark.js regression tests
  tests("Regressions [strict]", regression, strictMHTestFunc);
  tests("Regressions [strict]", regression, strictMHMHTestFunc);

  // SmartPunct
  TestFunc commonmarkMHTestFunc = mhTest(Options.commonmark);
  TestFunc commonmarkMHMHTestFunc = mhmhTest(Options.commonmark);
  tests("SmartPunct [commonmark]", smartPunctuation, commonmarkMHTestFunc);
  tests("SmartPunct [commonmark]", smartPunctuation, commonmarkMHMHTestFunc);

  // Fenced code attributes
  TestFunc fencedCodeAttributesMHTestFunc =
      mhTest(new Options(fencedCodeAttributes: true));
  TestFunc fencedCodeAttributesMHMHTestFunc =
      mhmhTest(new Options(fencedCodeAttributes: true));
  tests("Fenced code attributes", fencedCodeAttributes,
      fencedCodeAttributesMHTestFunc);
  tests("Fenced code attributes", fencedCodeAttributes,
      fencedCodeAttributesMHMHTestFunc);
  tests("Fenced code attributes spec", specification,
      fencedCodeAttributesMHTestFunc);
  tests("Fenced code attributes spec", specification,
      fencedCodeAttributesMHMHTestFunc);

  // Heading attributes
  TestFunc headingAttributesMHTestFunc =
      mhTest(new Options(headingAttributes: true));
  TestFunc headingAttributesMHMHTestFunc =
      mhmhTest(new Options(headingAttributes: true));
  tests("Heading attributes", headingAttributes,
      headingAttributesMHTestFunc);
  tests("Heading attributes", headingAttributes,
      headingAttributesMHMHTestFunc);
  tests("Heading attributes spec", specification,
      headingAttributesMHTestFunc);
  tests("Heading attributes spec", specification,
      headingAttributesMHMHTestFunc);

  // Strikeout
  TestFunc strikeoutMHTestFunc = mhTest(new Options(strikeout: true));
  TestFunc strikeoutMHMHTestFunc = mhmhTest(new Options(strikeout: true));
  tests("Strikeout", strikeout, strikeoutMHTestFunc);
  tests("Strikeout", strikeout, strikeoutMHMHTestFunc);
  tests("Strikeout spec", specification, strikeoutMHTestFunc);
  tests("Strikeout spec", specification, strikeoutMHMHTestFunc);

  // Subscript
  TestFunc subscriptMHTestFunc = mhTest(new Options(subscript: true));
  TestFunc subscriptMHMHTestFunc = mhmhTest(new Options(subscript: true));
  tests("Subscript", subscript, subscriptMHTestFunc);
  tests("Subscript", subscript, subscriptMHMHTestFunc);
  tests("Subscript spec", specification, subscriptMHTestFunc);
  tests("Subscript spec", specification, subscriptMHMHTestFunc);

  // Superscript
  TestFunc superscriptMHTestFunc = mhTest(new Options(superscript: true));
  TestFunc superscriptMHMHTestFunc = mhmhTest(new Options(superscript: true));
  tests("Superscript", superscript, superscriptMHTestFunc);
  tests("Superscript", superscript, superscriptMHMHTestFunc);
  tests("Superscript spec", specification, superscriptMHTestFunc);
  tests("Superscript spec", specification, superscriptMHMHTestFunc);

  // Strikeout and subscript
  TestFunc strikeoutSubscriptMHTestFunc =
      mhTest(new Options(strikeout: true, subscript: true));
  TestFunc strikeoutSubscriptMHMHTestFunc =
      mhmhTest(new Options(strikeout: true, subscript: true));
  tests("Strikeout and subscript", strikeoutAndSubscript,
      strikeoutSubscriptMHTestFunc);
  tests("Strikeout and subscript", strikeoutAndSubscript,
      strikeoutSubscriptMHMHTestFunc);
  tests("Strikeout and subscript spec", specification,
      strikeoutSubscriptMHTestFunc);
  tests("Strikeout and subscript spec", specification,
      strikeoutSubscriptMHMHTestFunc);

  // TeX Math between dollars
  TestFunc texDollarsMHTestFunc = mhTest(new Options(texMathDollars: true));
  TestFunc texDollarsMHMHTestFunc = mhmhTest(new Options(texMathDollars: true));
  tests("TeX math dollars", texMathDollars, texDollarsMHTestFunc);
  tests("TeX math dollars", texMathDollars, texDollarsMHMHTestFunc);
  tests("TeX math dollars spec", specification, texDollarsMHTestFunc);
  tests("TeX math dollars spec", specification, texDollarsMHMHTestFunc);

  // TeX Math between backslashed `()` or `[]`
  TestFunc texSingleMHTestFunc =
      mhTest(new Options(texMathSingleBackslash: true));
  TestFunc texSingleMHMHTestFunc =
      mhmhTest(new Options(texMathSingleBackslash: true));
  tests(
      "TeX math single backslash", texMathSingleBackslash, texSingleMHTestFunc);
  tests("TeX math single backslash", texMathSingleBackslash,
      texSingleMHMHTestFunc);

  Set<int> texMathSingleBackslashContradictions =
      new Set<int>.from(<int>[287, 479, 495]);
  TestFunc texSingleSpecMHTestFunc = mhTest(
      new Options(texMathSingleBackslash: true),
      (_, int num) => !texMathSingleBackslashContradictions.contains(num));
  TestFunc texSingleSpecMHMHTestFunc = mhmhTest(
      new Options(texMathSingleBackslash: true),
      (_, int num) => !texMathSingleBackslashContradictions.contains(num));
  tests(
      "TeX math single backslash spec", specification, texSingleSpecMHTestFunc);
  tests("TeX math single backslash spec", specification,
      texSingleSpecMHMHTestFunc);

  // TeX Math between double backslashed `()` or `[]`
  TestFunc texDoubleMHTestFunc =
      mhTest(new Options(texMathDoubleBackslash: true));
  TestFunc texDoubleMHMHTestFunc =
      mhmhTest(new Options(texMathDoubleBackslash: true));
  tests(
      "TeX math double backslash", texMathDoubleBackslash, texDoubleMHTestFunc);
  tests("TeX math double backslash", texMathDoubleBackslash,
      texDoubleMHMHTestFunc);
  tests("TeX math double backslash spec", specification, texDoubleMHTestFunc);
  tests("TeX math double backslash spec", specification, texDoubleMHMHTestFunc);

  // Raw TeX
  TestFunc rawTexMHTestFunc = mhTest(new Options(rawTex: true));
  TestFunc rawTexMHMHTestFunc = mhmhTest(new Options(rawTex: true));
  tests("Raw TeX", rawTex, rawTexMHTestFunc);
  tests("Raw TeX", rawTex, rawTexMHMHTestFunc);
  tests("Raw TeX spec", specification, rawTexMHTestFunc);
  tests("Raw TeX spec", specification, rawTexMHMHTestFunc);

  // Markdown to markdown tests
  tests("md2md [strict]", markdownToMarkdown, mhmTest(Options.strict));

  // Custom classes
  customClassesTests();

  // Custom resolver
  referenceResolverTests();
}
