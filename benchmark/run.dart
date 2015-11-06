import 'dart:convert';
import 'dart:io';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:md_proc/md_proc.dart';
import 'package:markdown/markdown.dart' as markdown;

class MdProcBenchmark extends BenchmarkBase {
  String data;

  MdProcBenchmark(this.data) : super("md_proc");

  static void main(String data) {
    new MdProcBenchmark(data).report();
  }

  // The benchmark code.
  void run() {
    markdownToHtml(data);
  }
}

class MarkdownBenchmark extends BenchmarkBase {
  String data;

  MarkdownBenchmark(this.data) : super("markdown");

  static void main(String data) {
    new MarkdownBenchmark(data).report();
  }

  // The benchmark code.
  void run() {
    markdown.markdownToHtml(data);
  }
}

main() async {
  // Using Pandoc documentation for benchmark
  HttpClient client = new HttpClient();
  HttpClientRequest request = await client.getUrl(Uri.parse('https://raw.githubusercontent.com/0xAX/linux-insides/master/mm/linux-mm-2.md'));
  //HttpClientRequest request = await client.getUrl(Uri.parse('https://raw.githubusercontent.com/dikmax/dikmax.name/master/post/2014-04-13-vilnius.md'));
  //HttpClientRequest request = await client.getUrl(Uri.parse('https://raw.githubusercontent.com/dikmax/md_proc/master/README.md'));
  //HttpClientRequest request = await client.getUrl(Uri.parse('https://raw.githubusercontent.com/jgm/pandoc/master/README'));
  HttpClientResponse response = await request.close();
  String data = await response.transform(UTF8.decoder).join();
  print("File length: ${data.length}");
  MdProcBenchmark.main(data);
  //MarkdownBenchmark.main(data);
}
