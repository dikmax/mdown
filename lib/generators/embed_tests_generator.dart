library mdown.generators.embed_tests_generator;

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:mdown/mdown.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'embed_tests.dart';

/// Embed test into file
class EmbedTestsGenerator extends GeneratorForAnnotation<EmbedTests> {
  /// Constructor
  const EmbedTestsGenerator();

  Map<String, String> _readFile(String fileName) {
    final Map<String, String> result = <String, String>{};

    final File file = new File(fileName);
    final String md = file.readAsStringSync();

    final Document doc = CommonMarkParser.strict.parse(md);
    for (BlockNode block in doc.contents) {
      if (block is FencedCodeBlock) {
        if (block.attributes is InfoString) {
          final InfoString attr = block.attributes;
          if (attr.language == 'example') {
            StringBuffer testBuffer = new StringBuffer();
            StringBuffer resBuffer = new StringBuffer();
            bool writeTest = true;
            for (String line in block.contents) {
              if (line == '.') {
                writeTest = false;
              } else {
                (writeTest ? testBuffer : resBuffer).writeln(line);
              }
            }

            final String test = testBuffer.toString();
            if (result.containsKey(test)) {
              print('Duplicate test: ${test}');
            } else {
              result[test] = resBuffer.toString();
            }
          }
        }
      }
    }

    return result;
  }

  @override
  Future<String> generateForAnnotatedElement(
      Element element, EmbedTests annotation, BuildStep buildStep) async {
    if (path.isAbsolute(annotation.path)) {
      throw new Exception('must be relative path to the source file');
    }

    final String sourcePathDir = path.dirname(buildStep.input.id.path);

    final String filePath = path.join(sourcePathDir, annotation.path);

    if (!await FileSystemEntity.isFile(filePath)) {
      throw new Exception('Not a file! - $filePath');
    }

    final Map<String, String> content = _readFile(filePath);

    String result =
        'final Map<String, String> _\$${element.displayName}Tests = '
        '<String, String>{\n';
    content.forEach((String k, String v) {
      result += "r'''$k''': r'''$v''',\n";
    });
    result += '};\n';

    return result;
  }
}
