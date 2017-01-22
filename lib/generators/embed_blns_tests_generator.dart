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

  List<String> _readFile(dynamic json) {
    if (json is Iterable) {
      return json.map((dynamic el) => el.toString());
    }

    return <String>[];
  }

  @override
  Future<String> generateForAnnotatedElement(
      Element element, EmbedBlnsTests annotation, BuildStep buildStep) async {
    if (path.isAbsolute(annotation.path)) {
      throw new Exception('must be relative path to the source file');
    }

    // Downloading source.
    final HttpClient client = new HttpClient();
    final HttpClientRequest request =
        await client.getUrl(Uri.parse(annotation.url));
    final List<int> response = await (await request.close()).fold(<int>[],
        (List<int> list, List<int> el) {
      list.addAll(el);
      return list;
    });

    final String sourcePathDir = path.dirname(buildStep.input.id.path);
    final String filePath = path.join(sourcePathDir, annotation.path);
    final File file = new File(filePath);

    file.writeAsBytesSync(response, mode: FileMode.WRITE);

    final dynamic json =
        JSON.decode(UTF8.decode(response, allowMalformed: true));

    final List<String> content = _readFile(json);

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
