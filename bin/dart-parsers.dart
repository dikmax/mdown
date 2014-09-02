import 'package:markdowntypography/markdown.dart';

void main() {
  var document = MarkdownParser.PANDOC;
  print(document.parse('Header 1\n=======\nHeader 2 {#id2}\n------\n\n# Header [header]###\n\nParagraph\n'));
  print(document.parse('# Header ### {#header}\n\nParagraph\n'));
  //print(document.parse("aaaaa\n\n~~~~~~javascript\nasdfasdfa\n~~~~~~\n\n\nasdfasdfasd\n"));
}
