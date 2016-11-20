library md_proc;

import 'package:md_proc/commonmark_parser.dart';
import 'package:md_proc/html_writer.dart';

export 'package:md_proc/definitions.dart';
export 'package:md_proc/html_writer.dart';
export 'package:md_proc/commonmark_parser.dart';
// export 'package:md_proc/markdown_writer.dart';
export 'package:md_proc/options.dart';

/// Converts markdown string to html string.
String markdownToHtml(String markdown) {
  final String result =
      HtmlWriter.defaults.write(CommonMarkParser.defaults.parse(markdown));

  return result;
  //return HtmlWriter.defaults.write(CommonMarkParser.defaults.parse(markdown));
}
