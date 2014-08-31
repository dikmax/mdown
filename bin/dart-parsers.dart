import 'package:markdowntypography/markdown.dart';

void main() {
  var document = MarkdownParser.DEFAULT;
  print(document.parse("This ~~is strikeout~~ test."));
  var image = MarkdownParser.DEFAULT.image;
  print(image.parse("![hi](/there))"));
  //print(document.parse('This is a [link](http://google.com "Google") to Google.'));
}
