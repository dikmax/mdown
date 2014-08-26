import 'package:markdowntypography/markdown.dart';

void main() {
  var document = getParser();
  print(document.parse('***a**b **c**d*'));
  print(document.parse('*test**'));
  print(document.parse('_foot_ball_'));
  print(document.parse('**a**'));
  print(document.parse('123412345\n\n123434563457\n1234678     456\n\n'));
}
