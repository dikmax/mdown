import 'package:markdowntypography/markdown.dart';

void main() {
  var document = MarkdownParser.DEFAULT;
  print(document.parse("aaaaa\n\n~~~~~~javascript\nasdfasdfa\n~~~~~~\n\n\nasdfasdfasd\n"));
}
