library md_proc.tool.build_file;

import 'package:source_gen/source_gen.dart';
import 'package:md_proc/generators/embed_tests_generator.dart';
import 'package:md_proc/generators/entities_generator.dart';

/// Main method for generated code builder.
void main(List<String> args) {
  build(args, const [
    const EmbedTestsGenerator(),
    const EntitiesGenerator()
  ], librarySearchPaths: [
    //'lib',
    'test'
  ]).then((String msg) {
    print(msg);
  });
}
