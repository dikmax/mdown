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
      int id = res['test']['id'];
      tests[id] = res['test'];
      if (id % 1000 == 999) {
        print('Running test ${id + 1}');
      }
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
