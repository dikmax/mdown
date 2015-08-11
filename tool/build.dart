library md_proc.build_file;

import 'package:source_gen/source_gen.dart';
import 'package:md_proc/generators/embed_tests_generator.dart';
import 'package:md_proc/generators/entities_generator.dart';

void main(List<String> args) {
  build(args, const [
    const EmbedTestsGenerator(),
    const EntitiesGenerator()
  ], librarySearchPaths: [
    'lib', 'test'
  ]).then((msg) {
    print(msg);
  });
}
