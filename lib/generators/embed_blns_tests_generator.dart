library mdown.generators.embed_blns_tests_generator;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'embed_blns_tests.dart';

/// Embed test into file
class EmbedBlnsTestsGenerator extends GeneratorForAnnotation<EmbedBlnsTests> {
  /// Constructor
  const EmbedBlnsTestsGenerator();

  List<String> _readFile(String fileName) {
    final File file = new File(fileName);
    final String json = file.readAsStringSync();

    final dynamic decode = JSON.decode(json);
    if (decode is Iterable) {
      return decode.map((dynamic el) => el.toString());
    }

    return <String>[];
  }

  @override
  Future<String> generateForAnnotatedElement(
      Element element, EmbedBlnsTests annotation, BuildStep buildStep) async {
    if (path.isAbsolute(annotation.path)) {
      throw new Exception('must be relative path to the source file');
    }

    final String sourcePathDir = path.dirname(buildStep.input.id.path);

    final String filePath = path.join(sourcePathDir, annotation.path);

    if (!await FileSystemEntity.isFile(filePath)) {
      throw new Exception('Not a file! - $filePath');
    }

    final List<String> content = _readFile(filePath);

    final StringBuffer result = new StringBuffer();
    result.writeln('final List<String> _\$${element.displayName}Tests = '
        '<String>[');
    content.forEach((String string) {
      result.writeln("r'''$string''',");
    });
    result.writeln("];");

    return result.toString();
  }
}
