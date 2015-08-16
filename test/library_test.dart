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
  //fileTest("CommonMark", specification, mdToHtmlTest(Options.STRICT, (t, num) => t == TestType.HTML && (num == 129)));
  //fileTest("CommonMark", specification, mdToHtmlTest(Options.STRICT, (t, num) => t == TestType.HTML && (num >= 103 && num < 144)));
  //fileTest("CommonMark", specification, mdToHtmlTest(Options.STRICT, (t, num) => t == TestType.HTML));
  tests("CommonMark [strict]", specification, mdToHtmlTest(Options.strict));

  // Additional tests
  //fileTest("Additional", additionalMarkdownToHtml, mdToHtmlTest(Options.STRICT, (t, num) => t == TestType.HTML && num == 19));
  tests("Additional [strict]", additionalMarkdownToHtml, mdToHtmlTest(Options.strict));

  // SmartPunct
  tests("SmartPunct [commonmark]", smartPunctuation, mdToHtmlTest(Options.commonmark));

  // Strikeout
  tests("Strikeout", strikeout, mdToHtmlTest(new Options(strikeout: true)));

  // Subscript
  tests("Subscript [defaults]", subscript, mdToHtmlTest(new Options(subscript: true)));

  // Superscript
  tests("Superscript [defaults]", superscript, mdToHtmlTest(new Options(superscript: true)));

  // Markdown to markdown tests
  tests("md2md [strict]", markdownToMarkdown, mdToMdTest(Options.strict));

  // Custom resolver
  referenceResolverTests();
}
