library mdown.tool.build;

import 'dart:async';
import 'package:source_gen/source_gen.dart';
import 'package:build_runner/build_runner.dart';
import 'package:build/build.dart';
import 'package:build_config/build_config.dart';
import 'package:mdown/generators/embed_tests_generator.dart';
import 'package:mdown/generators/embed_blns_tests_generator.dart';

/// Main method for generated code builder.
Future<void> main(List<String> args) async {
  await build([
    new BuilderApplication.forBuilder(
        'tests',
        [
          (BuilderOptions options) => new PartBuilder(const <Generator>[
                const EmbedTestsGenerator(),
                const EmbedBlnsTestsGenerator(),
              ])
        ],
        (PackageNode node) => node.name == 'mdown',
        defaultGenerateFor:
            const InputSet(include: const <String>['test/data/test_data.dart']))
  ], deleteFilesByDefault: true, outputDir: '.');
}
