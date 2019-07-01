library mdown.tool.builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:mdown/generators/embed_tests_generator.dart';
import 'package:mdown/generators/embed_blns_tests_generator.dart';
import 'package:mdown/generators/entities_generator.dart';

Builder embedTestsBuilder(BuilderOptions options) =>
    SharedPartBuilder(<Generator>[const EmbedTestsGenerator()], 'tests');

Builder embedBlnsTestsBuilder(BuilderOptions options) => SharedPartBuilder(
    <Generator>[const EmbedBlnsTestsGenerator()], 'blns_tests');

Builder entitiesBuilder(BuilderOptions options) =>
    SharedPartBuilder(<Generator>[const EntitiesGenerator()], 'entities');
