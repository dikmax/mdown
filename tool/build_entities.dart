library mdown.tool.build_entities;

import 'dart:async';
import 'package:source_gen/source_gen.dart';
import 'package:build_runner/build_runner.dart';
import 'package:mdown/generators/entities_generator.dart';

final PhaseGroup _phases = new PhaseGroup.singleAction(
    new GeneratorBuilder(const <Generator>[const EntitiesGenerator()]),
    new InputSet('mdown', const <String>['lib/entities.dart']));

/// Main method for generated code builder.
Future<dynamic> main(List<String> args) async {
  await build(_phases, deleteFilesByDefault: true);
}
