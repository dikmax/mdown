import 'package:markdowntypography/markdown.dart';
import 'package:markdowntypography/htmlWriter.dart';

void main() {
  var document = CommonMarkParser.DEFAULT;
  print(write(document.parse('-----\n')));
  //print(write(document.parse('`Foo\n----\n`')));
  //print(write(document.parse('`Foo\n----\n`\n\n<a title="a lot\n---\nof dashes"/>')));
  //print(write(document.parse('* * *')));
  //print(write(document.parse('- Item 1\nItem 2\n- Item 3')));
  //print(write(document.parse('\tfoo\tbaz\t\tbim')));
  //print(document.parse('    code\n    code2\n    code3\n\n'));
  //print(document.parse('# Header ### {#header}\n\nParagraph\n'));
  //print(document.parse("aaaaa\n\n~~~~~~javascript\nasdfasdfa\n~~~~~~\n\n\nasdfasdfasd\n"));
}
