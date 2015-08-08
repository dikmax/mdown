import 'package:md_proc/options.dart';

import 'individual_parsers.dart';
import 'parser.dart';
import 'reference_resolver.dart';
import 'service.dart';


void main() {
  serviceTests();

  individualParsersTests();

  // CommonMark tests
  //fileTest("CommonMark", "spec.txt", mdToHtmlTest(Options.STRICT, (t, num) => t == TestType.HTML && (num == 129)));
  //fileTest("CommonMark", "spec.txt", mdToHtmlTest(Options.STRICT, (t, num) => t == TestType.HTML && (num >= 103 && num < 144)));
  //fileTest("CommonMark", "spec.txt", mdToHtmlTest(Options.STRICT, (t, num) => t == TestType.HTML));
  fileTest("CommonMark", "spec.txt", mdToHtmlTest(Options.strict));
  // Additional tests
  //fileTest("Additional", "additionalMarkdownToHtml.txt", mdToHtmlTest(Options.STRICT, (t, num) => t == TestType.HTML && num == 19));
  fileTest("Additional", "additionalMarkdownToHtml.txt", mdToHtmlTest(Options.strict));
  // Additional tests
  fileTest("SmartPunct", "smart_punct.txt", mdToHtmlTest(Options.defaults));
  // Markdown to markdown tests
  fileTest("md2md", "markdownToMarkdown.txt", mdToMdTest(Options.strict));
  // Custom resolver
  referenceResolverTests();
}
