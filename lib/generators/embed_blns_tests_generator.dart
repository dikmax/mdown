library mdown.generators.embed_blns_tests_generator;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'embed_blns_tests.dart';

/// Embed test into file
class EmbedBlnsTestsGenerator extends GeneratorForAnnotation<EmbedBlnsTests> {
  /// Constructor
  const EmbedBlnsTestsGenerator();

  Iterable<String> _readFile(dynamic json) {
    if (json is Iterable) {
      return json.map((dynamic el) => el.toString());
    }

    return <String>[];
  }

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final String annotationPath = annotation.read('path').stringValue;

    if (path.isAbsolute(annotationPath)) {
      throw new Exception('must be relative path to the source file');
    }

    final String annotationUrl = annotation.read('url').stringValue;

    // Downloading source.
    final HttpClient client = new HttpClient();
    final HttpClientRequest request =
        await client.getUrl(Uri.parse(annotationUrl));
    final List<int> response = await (await request.close()).fold(<int>[],
        (List<int> list, List<int> el) {
      list.addAll(el);
      return list;
    });

    final String sourcePathDir = path.dirname(buildStep.inputId.path);
    final String filePath = path.join(sourcePathDir, annotationPath);
    new File(filePath)..writeAsBytesSync(response, mode: FileMode.WRITE);

    final dynamic data =
        json.decode(utf8.decode(response, allowMalformed: true));

    final Iterable<String> content = _readFile(data);

    final StringBuffer result = new StringBuffer()
      ..writeln('final List<String> _\$${element.displayName}Tests = '
          '<String>[');
    for (String string in content) {
      result.writeln("r'''$string''',");
    }
    result.writeln('];');

    return result.toString();
  }
}
