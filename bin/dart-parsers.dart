import 'package:markdowntypography/markdown.dart';
import 'package:markdowntypography/htmlWriter.dart';

void main() {
  var document = MarkdownParser.PANDOC;
  print(write(document.parse('\tfoo\tbaz\t\tbim')));
  //print(document.parse('    code\n    code2\n    code3\n\n'));
  //print(document.parse('# Header ### {#header}\n\nParagraph\n'));
  //print(document.parse("aaaaa\n\n~~~~~~javascript\nasdfasdfa\n~~~~~~\n\n\nasdfasdfasd\n"));
}
