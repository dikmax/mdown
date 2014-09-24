import 'dart:io';
import 'dart:convert';

void main() {
  var r = new RegExp(r"^&(.*);$");
  new HttpClient().getUrl(Uri.parse('https://html.spec.whatwg.org/multipage/entities.json'))
    .then((HttpClientRequest request) => request.close())
    .then((HttpClientResponse response) {
      response.transform(UTF8.decoder).transform(JSON.decoder).first.then((json) {
        print("part of markdown;\n");
        print("Map<String, String> htmlEntities = <String, String>{");
        json.forEach((String k, v) {
          Match match = r.firstMatch(k);
          if (match != null) {
            String entity = match.group(1);
            if (entity == "dollar") {
              print('  "$entity": "\\\$",');
            } else {
              print('  "$entity": ${JSON.encode(v['characters'])},');
            }
          }
        });
        print("};");
      });
    });
}