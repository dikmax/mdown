import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:mdown/mdown.dart';
import 'package:markdown/markdown.dart' as markdown;

class MapEmitter implements ScoreEmitter {
  String name;
  Map<String, double> scores = new HashMap<String, double>();

  MapEmitter(this.name);

  @override
  void emit(String testName, double value) {
    scores[testName] = value;
  }

  double report() {
    print("$name: ");
    final double sum = scores.values.reduce((double v1, double v2) => v1 + v2);
    print(" - sum: $sum");
    final double avg = sum / scores.length;
    print(" - avg: $avg");
    return avg;
  }
}

class MdProcBenchmark extends BenchmarkBase {
  String data;

  /// Constructor.
  MdProcBenchmark(String name, this.data, ScoreEmitter emitter)
      : super(name, emitter: emitter);

  static void main(String name, String data, ScoreEmitter emitter) {
    new MdProcBenchmark(name, data, emitter).report();
  }

  // The benchmark code.
  @override
  void run() {
    markdownToHtml(data);
  }
}

class MarkdownBenchmark extends BenchmarkBase {
  String data;

  /// Constructor.
  MarkdownBenchmark(String name, this.data, ScoreEmitter emitter)
      : super(name, emitter: emitter);

  static void main(String name, String data, ScoreEmitter emitter) {
    new MarkdownBenchmark(name, data, emitter).report();
  }

  // The benchmark code.
  @override
  void run() {
    markdown.markdownToHtml(data,
        extensionSet: markdown.ExtensionSet.commonMark);
  }
}

Future<dynamic> main() async {
  final Directory dir = new Directory('benchmark/progit');

  final MapEmitter mdProcResults = new MapEmitter("md_proc");
  final MapEmitter markdownResults = new MapEmitter("markdown");

  double sum = 0.0;

  await for (FileSystemEntity entity in dir.list()) {
    if (entity is File) {
      String name = entity.uri.pathSegments.last;
      if (name.endsWith('.md') || name.endsWith('.markdown')) {
        name = name.replaceAll(new RegExp(r'\.(md|markdown)$'), '');
        print('Benchmarking: $name...');
        final String data = await entity.readAsString();
        MdProcBenchmark.main(name, data, mdProcResults);
        print('md_proc: ${mdProcResults.scores[name]}');
        sum += mdProcResults.scores[name];
        MarkdownBenchmark.main(name, data, markdownResults);
        print('markdown: ${markdownResults.scores[name]}');
      }
    }
  }

  double mdProcAvg = mdProcResults.report();
  double markdownAvg = markdownResults.report();

  if (mdProcAvg < markdownAvg) {
    print('md_proc is ${markdownAvg / mdProcAvg} times faster');
  } else {
    print('md_proc is ${mdProcAvg / markdownAvg} times slover');
  }

  print('Total: $sum');

  exit(0);
}
