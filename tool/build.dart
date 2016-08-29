library md_proc.tool.build_file;

import 'dart:async';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:md_proc/generators/embed_tests_generator.dart';
import 'package:md_proc/generators/entities_generator.dart';

final PhaseGroup _phases = new PhaseGroup.singleAction(
    new GeneratorBuilder(
        const <Generator>[const EmbedTestsGenerator(), const EntitiesGenerator()]),
    new InputSet(
        'md_proc', const <String>['lib/entities.dart', 'test/data/test_data.dart']));

/// Main method for generated code builder.
Future<dynamic> main(List<String> args) async {
  await build(_phases, deleteFilesByDefault: true);
}
