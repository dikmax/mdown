import 'dart:io';
import 'dart:convert';

void main() {
  stdin.lineMode = true;
  String line;

  Map<int, dynamic> tests = {};
  while ((line = stdin.readLineSync()) != null) {
    dynamic res = JSON.decode(line);
    String type = res['type'];
    if (type == 'done') {
      break;
    }
    if (type == 'testStart') {
      tests[res['test']['id']] = res['test'];
    }
    if (type == 'testDone') {
      tests.remove(res['testID']);
    }
    if (type == 'error') {
      dynamic test = tests[res['testID']];
      print('Test ${test['id']} failed: ${test['name']}');
      print(res['error']);
    }
  }
}
