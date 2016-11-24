import 'package:md_proc/options.dart';

import 'custom_classes.dart';
import 'parser.dart';
import 'reference_resolver.dart';
import 'service.dart';
import 'data/test_data.dart';

/// Main tests runner
void main() {
  serviceTests();

  final TestFunc strictMHTestFunc = mhTest(Options.strict);
  final TestFunc strictMHMHTestFunc = mhmhTest(Options.strict);

  // CommonMark tests
  tests("CommonMark [strict]", specification, strictMHTestFunc);
  tests("CommonMark [strict]", specification, strictMHMHTestFunc);

  final TestFunc defaultsMHTestFunc = mhTest(Options.defaults);
  final TestFunc defaultsMHMHTestFunc = mhmhTest(Options.defaults);

  // Additional tests
  //tests("Additional", additionalMarkdownToHtml, mdToHtmlTest(Options.strict, (t, num) => t == TestType.html && num == 19));
  tests("Additional [strict]", additionalMarkdownToHtml, defaultsMHTestFunc);
  tests("Additional [strict]", additionalMarkdownToHtml, defaultsMHMHTestFunc);

  // commonmark.js regression tests
  tests("Regressions [strict]", regression, strictMHTestFunc);
  tests("Regressions [strict]", regression, strictMHMHTestFunc);

  // SmartPunct
  final TestFunc commonmarkMHTestFunc = mhTest(Options.commonmark);
  final TestFunc commonmarkMHMHTestFunc = mhmhTest(Options.commonmark);
  tests("SmartPunct [commonmark]", smartPunctuation, commonmarkMHTestFunc);
  tests("SmartPunct [commonmark]", smartPunctuation, commonmarkMHMHTestFunc);

  // Fenced code attributes
  final TestFunc fencedCodeAttributesMHTestFunc =
      mhTest(const Options(fencedCodeAttributes: true));
  final TestFunc fencedCodeAttributesMHMHTestFunc =
      mhmhTest(const Options(fencedCodeAttributes: true));
  tests("Fenced code attributes", fencedCodeAttributes,
      fencedCodeAttributesMHTestFunc);
  tests("Fenced code attributes", fencedCodeAttributes,
      fencedCodeAttributesMHMHTestFunc);
  tests("Fenced code attributes spec", specification,
      fencedCodeAttributesMHTestFunc);
  tests("Fenced code attributes spec", specification,
      fencedCodeAttributesMHMHTestFunc);

  // Inline code attributes
  final TestFunc inlineCodeAttributesMHTestFunc =
      mhTest(const Options(inlineCodeAttributes: true));
  final TestFunc inlineCodeAttributesMHMHTestFunc =
      mhmhTest(const Options(inlineCodeAttributes: true));
  tests("Inline code attributes", inlineCodeAttributes,
      inlineCodeAttributesMHTestFunc);
  tests("Inline code attributes", inlineCodeAttributes,
      inlineCodeAttributesMHMHTestFunc);
  tests("Inline code attributes spec", specification,
      inlineCodeAttributesMHTestFunc);
  tests("Inline code attributes spec", specification,
      inlineCodeAttributesMHMHTestFunc);

  // Heading attributes
  final TestFunc headingAttributesMHTestFunc =
      mhTest(const Options(headingAttributes: true));
  final TestFunc headingAttributesMHMHTestFunc =
      mhmhTest(const Options(headingAttributes: true));
  tests("Heading attributes", headingAttributes, headingAttributesMHTestFunc);
  tests("Heading attributes", headingAttributes, headingAttributesMHMHTestFunc);
  tests("Heading attributes spec", specification, headingAttributesMHTestFunc);
  tests(
      "Heading attributes spec", specification, headingAttributesMHMHTestFunc);

  // Link attributes
  final TestFunc linkAttributesMHTestFunc =
      mhTest(const Options(linkAttributes: true));
  final TestFunc linkAttributesMHMHTestFunc =
      mhmhTest(const Options(linkAttributes: true));
  tests("Link attributes", linkAttributes, linkAttributesMHTestFunc);
  tests("Link attributes", linkAttributes, linkAttributesMHMHTestFunc);
  tests("Link attributes spec", specification, linkAttributesMHTestFunc);
  tests("Link attributes spec", specification, linkAttributesMHMHTestFunc);

  // Strikeout
  final TestFunc strikeoutMHTestFunc = mhTest(const Options(strikeout: true));
  final TestFunc strikeoutMHMHTestFunc =
      mhmhTest(const Options(strikeout: true));
  tests("Strikeout", strikeout, strikeoutMHTestFunc);
  tests("Strikeout", strikeout, strikeoutMHMHTestFunc);
  tests("Strikeout spec", specification, strikeoutMHTestFunc);
  tests("Strikeout spec", specification, strikeoutMHMHTestFunc);

  // Subscript
  final TestFunc subscriptMHTestFunc = mhTest(const Options(subscript: true));
  final TestFunc subscriptMHMHTestFunc =
      mhmhTest(const Options(subscript: true));
  tests("Subscript", subscript, subscriptMHTestFunc);
  tests("Subscript", subscript, subscriptMHMHTestFunc);
  tests("Subscript spec", specification, subscriptMHTestFunc);
  tests("Subscript spec", specification, subscriptMHMHTestFunc);

  // Superscript
  final TestFunc superscriptMHTestFunc =
      mhTest(const Options(superscript: true));
  final TestFunc superscriptMHMHTestFunc =
      mhmhTest(const Options(superscript: true));
  tests("Superscript", superscript, superscriptMHTestFunc);
  tests("Superscript", superscript, superscriptMHMHTestFunc);
  tests("Superscript spec", specification, superscriptMHTestFunc);
  tests("Superscript spec", specification, superscriptMHMHTestFunc);

  // Strikeout and subscript
  final TestFunc strikeoutSubscriptMHTestFunc =
      mhTest(const Options(strikeout: true, subscript: true));
  final TestFunc strikeoutSubscriptMHMHTestFunc =
      mhmhTest(const Options(strikeout: true, subscript: true));
  tests("Strikeout and subscript", strikeoutAndSubscript,
      strikeoutSubscriptMHTestFunc);
  tests("Strikeout and subscript", strikeoutAndSubscript,
      strikeoutSubscriptMHMHTestFunc);
  tests("Strikeout and subscript spec", specification,
      strikeoutSubscriptMHTestFunc);
  tests("Strikeout and subscript spec", specification,
      strikeoutSubscriptMHMHTestFunc);

  // TeX Math between dollars
  final TestFunc texDollarsMHTestFunc =
      mhTest(const Options(texMathDollars: true));
  final TestFunc texDollarsMHMHTestFunc =
      mhmhTest(const Options(texMathDollars: true));
  tests("TeX math dollars", texMathDollars, texDollarsMHTestFunc);
  tests("TeX math dollars", texMathDollars, texDollarsMHMHTestFunc);
  tests("TeX math dollars spec", specification, texDollarsMHTestFunc);
  tests("TeX math dollars spec", specification, texDollarsMHMHTestFunc);

  // TeX Math between backslashed `()` or `[]`
  final TestFunc texSingleMHTestFunc =
      mhTest(const Options(texMathSingleBackslash: true));
  final TestFunc texSingleMHMHTestFunc =
      mhmhTest(const Options(texMathSingleBackslash: true));
  tests(
      "TeX math single backslash", texMathSingleBackslash, texSingleMHTestFunc);
  tests("TeX math single backslash", texMathSingleBackslash,
      texSingleMHMHTestFunc);

  final Set<int> texMathSingleBackslashContradictions =
      new Set<int>.from(<int>[287, 481, 497]);
  final TestFunc texSingleSpecMHTestFunc = mhTest(
      const Options(texMathSingleBackslash: true),
      (_, int num) => !texMathSingleBackslashContradictions.contains(num));
  final TestFunc texSingleSpecMHMHTestFunc = mhmhTest(
      const Options(texMathSingleBackslash: true),
      (_, int num) => !texMathSingleBackslashContradictions.contains(num));
  tests(
      "TeX math single backslash spec", specification, texSingleSpecMHTestFunc);
  tests("TeX math single backslash spec", specification,
      texSingleSpecMHMHTestFunc);

  // TeX Math between double backslashed `()` or `[]`
  final TestFunc texDoubleMHTestFunc =
      mhTest(const Options(texMathDoubleBackslash: true));
  final TestFunc texDoubleMHMHTestFunc =
      mhmhTest(const Options(texMathDoubleBackslash: true));
  tests(
      "TeX math double backslash", texMathDoubleBackslash, texDoubleMHTestFunc);
  tests("TeX math double backslash", texMathDoubleBackslash,
      texDoubleMHMHTestFunc);
  tests("TeX math double backslash spec", specification, texDoubleMHTestFunc);
  tests("TeX math double backslash spec", specification, texDoubleMHMHTestFunc);

  // Raw TeX
  final TestFunc rawTexMHTestFunc = mhTest(const Options(rawTex: true));
  final TestFunc rawTexMHMHTestFunc = mhmhTest(const Options(rawTex: true));
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
