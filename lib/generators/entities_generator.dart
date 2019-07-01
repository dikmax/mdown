library mdown.generators.entities_generator;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'entities.dart';

/// Generator for entities file
class EntitiesGenerator extends GeneratorForAnnotation<Entities> {
  /// Constructor
  const EntitiesGenerator();

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final RegExp r = RegExp(r'^&(.*);$');
    final HttpClient client = HttpClient();
    final String annotationUrl = annotation.read('url').stringValue;
    final HttpClientRequest request =
        await client.getUrl(Uri.parse(annotationUrl));
    final HttpClientResponse response = await request.close();
    final dynamic data =
        await response.transform(utf8.decoder).transform(json.decoder).first;
    final StringBuffer result = StringBuffer(
        'final Map<String, String> _\$${element.displayName} = new HashMap<String, String>.from(<String, String>{\n');

    data.forEach((String k, dynamic v) {
      final Match match = r.firstMatch(k);
      if (match != null) {
        final String entity = match.group(1);
        result.write("'$entity': '");
        switch (entity) {
          case 'dollar':
            result.write(r'\$');
            break;

          case 'apos':
            result.write(r"\'");
            break;

          case 'bsol':
            result.write(r'\\');
            break;

          case 'NewLine':
            result.write(r'\n');
            break;

          default:
            result.write(v['characters']);
        }

        result.write("',");
      }
    });

    result.write('});');
    return result.toString();
  }
}
