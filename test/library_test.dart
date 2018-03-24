import 'package:mdown/options.dart';

import 'blns.dart';
import 'custom_classes.dart';
import 'data/test_data.dart';
import 'parser.dart';
import 'reference_resolver.dart';
import 'service.dart';

/// Main tests runner
void main() {
  blnsTests();
  serviceTests();

  final TestFunc strictTestFunc = generateTestFunc(Options.strict);
  final TestFunc defaultsTestFunc = generateTestFunc(Options.defaults);
  final TestFunc commonmarkTestFunc = generateTestFunc(Options.commonmark);
  final TestFunc gfmTestFunc = generateTestFunc(Options.gfm);

  // CommonMark tests
  tests('CommonMark [strict]', specification, strictTestFunc);

  // commonmark.js regression tests
  tests('Regressions [strict]', regression, strictTestFunc);

  // Additional tests
  tests('Additional [defauls]', additionalMarkdownToHtml, defaultsTestFunc);

  // SmartPunct
  tests('SmartPunct [commonmark]', smartPunctuation, commonmarkTestFunc);

  // GFM
  // tests('GFM [gfm]', gfmSpecification, gfmTestFunc);

  // Fenced code attributes
  final TestFunc fencedCodeAttributesTestFunc =
      generateTestFunc(const Options(fencedCodeAttributes: true));
  tests('Fenced code attributes', fencedCodeAttributes,
      fencedCodeAttributesTestFunc);
  tests('Fenced code attributes spec', specification,
      fencedCodeAttributesTestFunc);

  // Inline code attributes
  final TestFunc inlineCodeAttributesTestFunc =
      generateTestFunc(const Options(inlineCodeAttributes: true));
  tests('Inline code attributes', inlineCodeAttributes,
      inlineCodeAttributesTestFunc);
  tests('Inline code attributes spec', specification,
      inlineCodeAttributesTestFunc);

  // Heading attributes
  final TestFunc headingAttributesTestFunc =
      generateTestFunc(const Options(headingAttributes: true));
  tests('Heading attributes', headingAttributes, headingAttributesTestFunc);
  tests('Heading attributes spec', specification, headingAttributesTestFunc);

  // Link attributes
  final TestFunc linkAttributesTestFunc =
      generateTestFunc(const Options(linkAttributes: true));
  tests('Link attributes', linkAttributes, linkAttributesTestFunc);
  tests('Link attributes spec', specification, linkAttributesTestFunc);

  // Strikeout
  final TestFunc strikeoutTestFunc =
      generateTestFunc(const Options(strikeout: true));
  tests('Strikeout', strikeout, strikeoutTestFunc);
  tests('Strikeout spec', specification, strikeoutTestFunc);

  // Subscript
  final TestFunc subscriptTestFunc =
      generateTestFunc(const Options(subscript: true));
  tests('Subscript', subscript, subscriptTestFunc);
  tests('Subscript spec', specification, subscriptTestFunc);

  // Superscript
  final TestFunc superscriptTestFunc =
      generateTestFunc(const Options(superscript: true));
  tests('Superscript', superscript, superscriptTestFunc);
  tests('Superscript spec', specification, superscriptTestFunc);

  // Strikeout and subscript
  final TestFunc strikeoutSubscriptTestFunc =
      generateTestFunc(const Options(strikeout: true, subscript: true));
  tests('Strikeout and subscript', strikeoutAndSubscript,
      strikeoutSubscriptTestFunc);
  tests('Strikeout and subscript spec', specification,
      strikeoutSubscriptTestFunc);

  // TeX Math between dollars
  final TestFunc texDollarsTestFunc =
      generateTestFunc(const Options(texMathDollars: true));
  tests('TeX math dollars', texMathDollars, texDollarsTestFunc);
  tests('TeX math dollars spec', specification, texDollarsTestFunc);

  // TeX Math between backslashed `()` or `[]`
  final TestFunc texSingleTestFunc =
      generateTestFunc(const Options(texMathSingleBackslash: true));
  tests('TeX math single backslash', texMathSingleBackslash, texSingleTestFunc);

  final Set<int> texMathSingleBackslashContradictions =
      new Set<int>.from(<int>[289]);
  final TestFunc texSingleSpecTestFunc = generateTestFunc(
      const Options(texMathSingleBackslash: true),
      (int num) => !texMathSingleBackslashContradictions.contains(num));
  tests('TeX math single backslash spec', specification, texSingleSpecTestFunc);

  // TeX Math between double backslashed `()` or `[]`
  final TestFunc texDoubleTestFunc =
      generateTestFunc(const Options(texMathDoubleBackslash: true));
  tests('TeX math double backslash', texMathDoubleBackslash, texDoubleTestFunc);
  tests('TeX math double backslash spec', specification, texDoubleTestFunc);

  // Raw TeX
  final TestFunc rawTexTestFunc = generateTestFunc(const Options(rawTex: true));
  tests('Raw TeX', rawTex, rawTexTestFunc);
  tests('Raw TeX spec', specification, rawTexTestFunc);

  // Pipe tables
  final TestFunc pipeTablesTestFunc =
      generateTestFunc(const Options(pipeTables: true));
  tests('Pipe tables', pipeTables, pipeTablesTestFunc);
  tests('Pipe tables spec', specification, pipeTablesTestFunc);

  // Custom classes
  customClassesTests();

  // Custom resolver
  referenceResolverTests();
}
