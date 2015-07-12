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
  tests("CommonMark", specification, mdToHtmlTest(Options.strict));
  // Additional tests
  //fileTest("Additional", additionalMarkdownToHtml, mdToHtmlTest(Options.STRICT, (t, num) => t == TestType.HTML && num == 19));
  tests("Additional", additionalMarkdownToHtml, mdToHtmlTest(Options.strict));
  // Additional tests
  tests("SmartPunct", smartPunctuation, mdToHtmlTest(Options.defaults));
  tests("Strikeout", strikeout, mdToHtmlTest(Options.defaults));
  // Markdown to markdown tests
  tests("md2md", markdownToMarkdown, mdToMdTest(Options.strict));
  // Custom resolver
  referenceResolverTests();
}
