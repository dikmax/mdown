library mdown;

import 'package:mdown/markdown_parser.dart';
import 'package:mdown/html_writer.dart';
import 'package:mdown/options.dart';

export 'package:mdown/ast/ast.dart';
export 'package:mdown/markdown_parser.dart';
export 'package:mdown/html_writer.dart';
export 'package:mdown/options.dart';

/// Converts markdown string to html string.
String markdownToHtml(String markdown, [Options options]) {
  String result;
  if (options == null) {
    result = HtmlWriter.defaults.write(MarkdownParser.defaults.parse(markdown));
  } else {
    result = HtmlWriter(options).write(MarkdownParser(options).parse(markdown));
  }

  return result;
}
