import "lib/md_proc.dart";

main() {
  var parser = CommonMarkParser.DEFAULT.linkLabel;
  var res = parser.run('[\n\n]\n');
  print(res);
}