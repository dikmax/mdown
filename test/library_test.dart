import 'package:md_proc/src/options.dart';

import 'parser.dart';
import 'service.dart';
import 'package:test/test.dart' as t;


void main() {
  serviceTests();

  // CommonMark tests
  //fileTest("CommonMark", "spec.txt", mdToHtmlTest(Options.STRICT, (t, num) => t == TestType.HTML && num == 229));
  fileTest("CommonMark", "spec.txt", mdToHtmlTest(Options.STRICT));
  // Additional tests
  fileTest("Additional", "additionalMarkdownToHtml.txt", mdToHtmlTest(Options.STRICT));
  // Additional tests
  fileTest("SmartPunct", "smart_punct.txt", mdToHtmlTest(Options.DEFAULT));
  // Markdown to markdown tests
  fileTest("md2md", "markdownToMarkdown.txt", mdToMdTest(Options.STRICT));
}
