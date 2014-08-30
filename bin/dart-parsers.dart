import 'package:markdowntypography/markdown.dart';

void main() {

  var source = MarkdownParser.DEFAULT.source;
  print(source.parse('(<http://google.com/>)'));
  var quotedTitle = MarkdownParser.DEFAULT.quotedTitle('"');
  print(quotedTitle.parse('"Google"'));
  var link = MarkdownParser.DEFAULT.link();
  print(link.parse('[link](http://google.com/ "Google")'));
  var document = MarkdownParser.DEFAULT;
  print(document.parse('This is a [link](http://google.com "Google") to Google.'));
}
