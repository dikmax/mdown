library mdown;

import 'package:mdown/markdown_parser.dart';
import 'package:mdown/html_writer.dart';

export 'package:mdown/ast/ast.dart';
export 'package:mdown/markdown_parser.dart';
export 'package:mdown/html_writer.dart';
export 'package:mdown/options.dart';

/// Converts markdown string to html string.
String markdownToHtml(String markdown) {
  final String result =
      HtmlWriter.defaults.write(CommonMarkParser.defaults.parse(markdown));

  return result;
}
