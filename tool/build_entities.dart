library mdown.tool.build_entities;

import 'dart:async';
import 'package:build/build.dart';
import 'package:build_config/src/build_config.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build_runner/build_runner.dart';
import 'package:mdown/generators/entities_generator.dart';

/// Main method for generated code builder.
Future<void> main(List<String> args) async {
  await build([
    new BuilderApplication.forBuilder(
        'entities',
        [
          (BuilderOptions options) =>
              new PartBuilder(const <Generator>[const EntitiesGenerator()])
        ],
        (PackageNode node) => node.name == 'mdown',
        defaultGenerateFor:
            const InputSet(include: const <String>['lib/entities.dart']))
  ], deleteFilesByDefault: true, outputDir: '.');
}
