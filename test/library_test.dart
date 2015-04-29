import 'package:md_proc/src/options.dart';

import 'parser.dart';
import 'service.dart';

void main() {
  serviceTests();

  // CommonMark tests
  fileTest("CommonMark", "spec.txt", mdToHtmlTest(Options.STRICT));
  // Additional tests
  fileTest("Additional", "additionalMarkdownToHtml.txt", mdToHtmlTest(Options.STRICT));
  // Additional tests
  fileTest("SmartPunct", "smart_punct.txt", mdToHtmlTest(Options.DEFAULT));
  // Markdown to markdown tests
  fileTest("md2md", "markdownToMarkdown.txt", mdToMdTest(Options.STRICT));

  //t.filterTests("(md2md | markdown )");
  //t.filterTests(r"^md2md 5$");
}
