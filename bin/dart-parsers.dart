import 'package:markdowntypography/markdown.dart';

void main() {
  var document = MarkdownParser.MMD;
  print(document.parse('# Header [header]###\n\nParagraph\n'));
  //print(document.parse("aaaaa\n\n~~~~~~javascript\nasdfasdfa\n~~~~~~\n\n\nasdfasdfasd\n"));
}
