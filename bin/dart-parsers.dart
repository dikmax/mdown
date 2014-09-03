import 'package:markdowntypography/markdown.dart';

void main() {
  var document = MarkdownParser.PANDOC;
  print(document.parse('asdf\n\n\n   * * *\n\nzxcv'));
  print(document.parse('    code\n    code2\n    code3\n\n'));
  print(document.parse('# Header ### {#header}\n\nParagraph\n'));
  //print(document.parse("aaaaa\n\n~~~~~~javascript\nasdfasdfa\n~~~~~~\n\n\nasdfasdfasd\n"));
}
