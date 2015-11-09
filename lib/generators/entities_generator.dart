library md_proc.generators.entities_generator;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/src/generated/element.dart';
import 'package:source_gen/source_gen.dart';

import 'entities.dart';

class EntitiesGenerator extends GeneratorForAnnotation<Entities> {
  @override
  final AssociatedFileSet associatedFileSet;

  /// If [associatedFileSet] is not set, the default value of
  /// [AssociatedFileSet.sameDirectory] is used.
  const EntitiesGenerator(
      {AssociatedFileSet associatedFileSet: AssociatedFileSet.sameDirectory})
      : this.associatedFileSet = associatedFileSet;

  @override
  Future<String> generateForAnnotatedElement(
      Element element, Entities annotation) async {
    RegExp r = new RegExp(r"^&(.*);$");
    HttpClient client = new HttpClient();
    HttpClientRequest request = await client.getUrl(
        Uri.parse('https://html.spec.whatwg.org/multipage/entities.json'));
    HttpClientResponse response = await request.close();
    dynamic json =
        await response.transform(UTF8.decoder).transform(JSON.decoder).first;
    String result = 'final Map<String, String> _\$${element.displayName} = {\n';
    json.forEach((String k, dynamic v) {
      Match match = r.firstMatch(k);
      if (match != null) {
        String entity = match.group(1);
        if (entity == "dollar") {
          result += '  "$entity": "\\\$",';
        } else {
          result += '  "$entity": ${JSON.encode(v['characters'])},';
        }
      }
    });
    result += '};';

    return result;
  }
}
