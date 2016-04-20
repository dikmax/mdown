library md_proc.generators.embed_tests_generator;

import 'dart:async';
import 'dart:io';

import 'package:analyzer/src/generated/element.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'embed_tests.dart';
import 'package:md_proc/md_proc.dart';

/// Embed test into file
class EmbedTestsGenerator extends GeneratorForAnnotation<EmbedTests> {
  /// Constructor
  const EmbedTestsGenerator();

  Map<String, String> _readFile(String fileName) {
    Map<String, String> result = <String, String>{};

    File file = new File(fileName);
    String md = file.readAsStringSync();

    Document doc = CommonMarkParser.strict.parse(md);
    doc.contents.forEach((Block block) {
      if (block is FencedCodeBlock) {
        if (block.attributes is InfoString) {
          InfoString attr = block.attributes;
          if (attr.language == 'example') {
            List<String> example = block.contents.split('\n.\n');
            result[example[0] + '\n'] = example[1];
          }
        }
      }
    });

    return result;
  }

  @override
  Future<String> generateForAnnotatedElement(
      Element element, EmbedTests annotation, BuildStep buildStep) async {
    if (path.isAbsolute(annotation.path)) {
      throw 'must be relative path to the source file';
    }

    String sourcePathDir = path.dirname(buildStep.input.id.path);

    String filePath = path.join(sourcePathDir, annotation.path);

    if (!await FileSystemEntity.isFile(filePath)) {
      throw 'Not a file! - $filePath';
    }

    Map<String, String> content = _readFile(filePath);

    String result =
        'final Map<String, String> _\$${element.displayName}Tests = {\n';
    content.forEach((String k, String v) {
      result += "r'''" + k + "''': r'''" + v + "''',\n";
    });
    result += '};\n';

    return result;
  }
}
