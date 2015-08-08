library md_proc;

import 'html_writer.dart';
import 'markdown_parser.dart';

export 'definitions.dart';
export 'html_writer.dart';
export 'markdown_parser.dart';
export 'markdown_writer.dart';
export 'options.dart';

/// Converts markdown string to html string.
String markdownToHtml(String markdown) {
  return HtmlWriter.defaults.write(CommonMarkParser.defaults.parse(markdown));
}
