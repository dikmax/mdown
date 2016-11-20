import 'dart:collection';
import 'dart:io';
import 'dart:convert';

/// Main method for custom tests reporter
void main() {
  stdin.lineMode = true;
  String line;

  final Map<int, dynamic> tests = new HashMap<int, dynamic>();
  while ((line = stdin.readLineSync()) != null) {
    final dynamic res = JSON.decode(line);
    final String type = res['type'];
    if (type == 'done') {
      break;
    }
    if (type == 'testStart') {
      final int id = res['test']['id'];
      tests[id] = res['test'];
      if (id % 1000 == 999) {
        print('Running test ${id + 1}');
      }
    }
    if (type == 'testDone') {
      tests.remove(res['testID']);
    }
    if (type == 'error') {
      final dynamic test = tests[res['testID']];
      print('Test ${test['id']} failed: ${test['name']}');
      print(res['error']);
    }
  }
}
