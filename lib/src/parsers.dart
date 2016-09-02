library md_proc.src.parsers;

import 'dart:collection';
import 'dart:math';
import 'parse_result.dart';
import 'package:md_proc/definitions.dart';
import 'package:md_proc/entities.dart';
import 'package:md_proc/options.dart';

part 'parsers/container.dart';
part 'parsers/abstract.dart';
part 'parsers/common.dart';
part 'parsers/blankline.dart';
part 'parsers/line.dart';
part 'parsers/thematic_break.dart';
part 'parsers/atx_heading.dart';
part 'parsers/indented_code.dart';
part 'parsers/fenced_code.dart';
part 'parsers/html_block.dart';
part 'parsers/html_block_7.dart';
part 'parsers/para_setext_heading.dart';
part 'parsers/blockquote_list.dart';
part 'parsers/link_reference.dart';

part 'parsers/hard_line_break.dart';
part 'parsers/escapes.dart';
part 'parsers/entity.dart';
part 'parsers/inline_code.dart';
part 'parsers/inline_html.dart';
part 'parsers/inline_structure.dart';
part 'parsers/link_image.dart';
part 'parsers/autolink.dart';
part 'parsers/ellipsis.dart';
part 'parsers/mn_dash.dart';
part 'parsers/tex_math_dollars.dart';
part 'parsers/tex_math_single_backslash.dart';
part 'parsers/tex_math_double_backslash.dart';
part 'parsers/str.dart';

part 'parsers/document.dart';

class _UnparsedInlines extends Inlines {
  String raw;

  _UnparsedInlines(this.raw);

  @override
  String toString() => raw;

  @override
  bool operator ==(dynamic obj) => obj is _UnparsedInlines && raw == obj.raw;

  @override
  int get hashCode => raw.hashCode;
}
