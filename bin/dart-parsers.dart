import 'package:markdowntypography/markdown.dart';

void main() {

  var source = MarkdownParser.DEFAULT.source;
  print(source.parse('(<http://google.com/>)'));
  var link = MarkdownParser.DEFAULT.link();
  print(link.parse('[link](http://google.com/)'));
  var document = MarkdownParser.DEFAULT;
  print(document.parse('This is a [link](http://google.com) to Google.'));
}
