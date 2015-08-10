library md_proc.generators.embed_tests_generator;

import 'dart:async';
import 'dart:io';

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'embed_tests.dart';


class EmbedTestsGenerator extends GeneratorForAnnotation<EmbedTests> {
  static const int stateWait = 0;
  static const int stateSource = 1;
  static const int stateDestination = 2;

  @override
  final AssociatedFileSet associatedFileSet;

  /// If [associatedFileSet] is not set, the default value of
  /// [AssociatedFileSet.sameDirectory] is used.
  const EmbedTestsGenerator(
      {AssociatedFileSet associatedFileSet: AssociatedFileSet.sameDirectory})
      : this.associatedFileSet = associatedFileSet;

  Map<String, String> readFile(fileName) {
    Map<String, String> result = <String, String>{};

    File file = new File(fileName);
    int state = stateWait;
    List<String> destination = [];
    List<String> source = [];
    List<String> lines = file.readAsLinesSync();
    for (String line in lines) {
      if (line == ".") {
        state++;
        if (state == 3) {
          result[source.map((line) => line + "\n").join()] = destination.map((line) => line + "\n").join();
          state = stateWait;
          destination = [];
          source = [];
        }
      } else if (state == stateSource) {
        source.add(line);
      } else if (state == stateDestination) {
        destination.add(line);
      }
    }

    return result;
  }

  @override
  Future<String> generateForAnnotatedElement(
      Element element, EmbedTests annotation) async {
    if (path.isAbsolute(annotation.path)) {
      throw 'must be relative path to the source file';
    }

    var source = element.source as FileBasedSource;
    var sourcePath = source.file.getAbsolutePath();

    var sourcePathDir = path.dirname(sourcePath);

    var filePath = path.join(sourcePathDir, annotation.path);

    if (!await FileSystemEntity.isFile(filePath)) {
      throw 'Not a file! - $filePath';
    }

    var content = readFile(filePath);

    var result = 'final Map<String, String> _\$${element.displayName}Tests = {\n';
    content.forEach((k, v) {
      result += "r'''" + k + "''': r'''" + v + "''',\n";
    });
    result += '};\n';

    return result;
  }
}
