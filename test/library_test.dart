import 'package:md_proc/options.dart';

import 'custom_classes.dart';
import 'individual_parsers.dart';
import 'parser.dart';
import 'reference_resolver.dart';
import 'service.dart';
import 'data/test_data.dart';

void main() {
  serviceTests();

  individualParsersTests();

  // CommonMark tests
  //tests("CommonMark", specification, mdToHtmlTest(Options.strict, (t, num) => t == TestType.html && (num == 129)));
  //tests("CommonMark", specification, mdToHtmlTest(Options.strict, (t, num) => t == TestType.html && (num >= 103 && num < 144)));
  //tests("CommonMark", specification, mdToHtmlTest(Options.strict, (t, num) => t == TestType.html));
  tests("CommonMark [strict]", specification, mdToHtmlTest(Options.strict));

  // Additional tests
  //tests("Additional", additionalMarkdownToHtml, mdToHtmlTest(Options.strict, (t, num) => t == TestType.html && num == 19));
  tests("Additional [strict]", additionalMarkdownToHtml,
      mdToHtmlTest(Options.strict));

  // SmartPunct
  Set<int> smartPunctuationContradictions = new Set.from([
    11,
    20,
    51,
    55,
    152,
    162,
    163,
    278,
    311,
    319,
    325,
    329,
    346,
    351,
    361,
    465,
    544,
    570,
    571,
    573,
    575,
    577,
    578,
    584,
    602
  ]);
  tests("SmartPunct [commonmark]", smartPunctuation,
      mdToHtmlTest(Options.commonmark));
  tests(
      "CommonMark [commonmark]",
      specification,
      mdToHtmlTest(Options.commonmark,
          (_, int num) => !smartPunctuationContradictions.contains(num)));

  // Strikeout
  tests("Strikeout", strikeout, mdToHtmlTest(new Options(strikeout: true)));
  /*tests("Strikeout spec", specification,
      mdToHtmlTest(new Options(strikeout: true)));*/

  // Subscript
  tests("Subscript", subscript, mdToHtmlTest(new Options(subscript: true)));
  /*tests("Subscript spec", specification,
      mdToHtmlTest(new Options(subscript: true)));*/

  // Superscript
  tests(
      "Superscript", superscript, mdToHtmlTest(new Options(superscript: true)));
  /*tests("Superscript spec", specification,
      mdToHtmlTest(new Options(superscript: true)));*/

  // Strikeout
  tests("Strikeout and subscript", strikeoutAndSubscript,
      mdToHtmlTest(new Options(strikeout: true, subscript: true)));
  /*tests("Strikeout and subscript spec", specification,
      mdToHtmlTest(new Options(strikeout: true, subscript: true)));*/

  // TeX Math between dollars
  tests("Tex math dollars", texMathDollars,
      mdToHtmlTest(new Options(texMathDollars: true)));
  tests("Tex math dollars spec", specification,
      mdToHtmlTest(new Options(texMathDollars: true)));

  // TeX Math between backslashed `()` or `[]`
  Set<int> texMathSingleBackslashContradictions = new Set.from([276, 469, 485]);
  tests("Tex math single backslash", texMathSingleBackslash,
      mdToHtmlTest(new Options(texMathSingleBackslash: true)));
  tests(
      "Tex math single backslash spec",
      specification,
      mdToHtmlTest(new Options(texMathSingleBackslash: true),
          (_, int num) => !texMathSingleBackslashContradictions.contains(num)));

  // TeX Math between double backslashed `()` or `[]`
  Set<int> texMathDoubleBackslashContradictions = new Set.from([]);
  tests("Tex math double backslash", texMathDoubleBackslash,
      mdToHtmlTest(new Options(texMathDoubleBackslash: true)));
  tests(
      "Tex math double backslash spec",
      specification,
      mdToHtmlTest(new Options(texMathDoubleBackslash: true),
          (_, int num) => !texMathDoubleBackslashContradictions.contains(num)));

  // Markdown to markdown tests
  tests("md2md [strict]", markdownToMarkdown, mdToMdTest(Options.strict));

  // Custom classes
  customClassesTests();

  // Custom resolver
  referenceResolverTests();
}
