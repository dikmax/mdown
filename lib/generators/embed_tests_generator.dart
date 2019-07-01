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

    final File file = File(fileName);
    final String md = file.readAsStringSync();

    final Document doc = MarkdownParser.strict.parse(md);
    for (final BlockNode block in doc.contents) {
      // TODO(dikmax): use visitors
      if (block is CodeBlock) {
        if (block.attributes is InfoString) {
          final InfoString attr = block.attributes;
          if (attr.language == 'example') {
            final StringBuffer testBuffer = StringBuffer();
            final StringBuffer resBuffer = StringBuffer();
            bool writeTest = true;
            for (final String line in block.contents) {
              if (line == '.') {
                writeTest = false;
              } else {
                (writeTest ? testBuffer : resBuffer).writeln(line);
              }
            }

            final String test = testBuffer.toString();
            if (result.containsKey(test)) {
              print('Duplicate test: $test');
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
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final String annotationPath = annotation.read('path').stringValue;
    if (path.isAbsolute(annotationPath)) {
      throw Exception('must be relative path to the source file');
    }

    final String sourcePathDir = path.dirname(buildStep.inputId.path);

    final String filePath = path.join(sourcePathDir, annotationPath);

    if (!FileSystemEntity.isFileSync(filePath)) {
      throw Exception('Not a file! - $filePath');
    }

    final Map<String, String> content = _readFile(filePath);

    String result =
        'final Map<String, String> _\$${element.displayName}Tests = '
        '<String, String>{\n';
    content.forEach((String k, String v) {
      result += "r'''$k''': r'''$v''',\n";
    });

    return '$result};\n';
  }
}
