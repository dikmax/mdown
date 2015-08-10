library md_proc.build_file;

import 'package:source_gen/source_gen.dart';
import 'package:md_proc/generators/embed_tests_generator.dart';

void main(List<String> args) {
  build(args, const [
    const EmbedTestsGenerator()
  ], librarySearchPaths: [
    'test'
  ]).then((msg) {
    print(msg);
  });
}
