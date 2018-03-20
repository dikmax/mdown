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
    final RegExp r = new RegExp(r"^&(.*);$");
    final HttpClient client = new HttpClient();
    final String annotationUrl = annotation.read('url').stringValue;
    final HttpClientRequest request =
        await client.getUrl(Uri.parse(annotationUrl));
    final HttpClientResponse response = await request.close();
    final dynamic data =
        await response.transform(utf8.decoder).transform(json.decoder).first;
    String result =
        'final Map<String, String> _\$${element.displayName} = new HashMap<String, String>.from(<String, String>{\n';
    data.forEach((String k, dynamic v) {
      final Match match = r.firstMatch(k);
      if (match != null) {
        final String entity = match.group(1);
        if (entity == 'dollar') {
          result += '  "$entity": "\\\$",';
        } else {
          result += '  "$entity": ${json.encode(v['characters'])},';
        }
      }
    });

    return '$result});';
  }
}
