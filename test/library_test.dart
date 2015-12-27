import 'package:md_proc/options.dart';

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
    50,
    54,
    151,
    161,
    162,
    275,
    307,
    315,
    321,
    325,
    342,
    347,
    357,
    461,
    539,
    565,
    566,
    568,
    570,
    572,
    573,
    579,
    597
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

  // Tex Math
  tests("Tex math dollars", texMathDollars,
      mdToHtmlTest(new Options(texMathDollars: true)));
  tests("Tex math dollars spec", specification,
      mdToHtmlTest(new Options(texMathDollars: true)));

  // Tex Math
  Set<int> texMathSingleBackslashContradictions = new Set.from([
    273, 465, 481
  ]);
  tests("Tex math single backslash", texMathSingleBackslash,
      mdToHtmlTest(new Options(texMathSingleBackslash: true)));
  tests("Tex math single backslash spec", specification,
      mdToHtmlTest(new Options(texMathSingleBackslash: true),
          (_, int num) => !texMathSingleBackslashContradictions.contains(num)));

  // Markdown to markdown tests
  tests("md2md [strict]", markdownToMarkdown, mdToMdTest(Options.strict));

  // Custom resolver
  referenceResolverTests();
}
