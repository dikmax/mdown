import 'package:markdowntypography/markdown.dart';

void main() {
  var document = MarkdownParser.DEFAULT;
  var c = document.escapedChar();
  print(document.parse("a\\ b"));
}
