md_proc
=======

[CommonMark]-compliant Markdown parser.

Basic usage:

```dart
print(markdownToHtml('# Hello world!'));
```

Main difference from other parsers is Markdown-based AST. You can parse Markdown, process resulting AST and write
results back to markdown.

Project main goal is create processing library for Markdown.

Parsing
-------

```dart
import "package:md_proc/md_proc.dart";

void main() {
  Document doc = CommonMarkParser.DEFAULT.parse('Hello world!\n===');
  print(doc); // Document [SetextHeader 1 [Str "Hello", Space, Str "world", Str "!"]]
}
```

Writing html
------------

```dart
import "package:md_proc/md_proc.dart";

void main() {
  Document doc = CommonMarkParser.DEFAULT.parse('Hello world!\n===');
  String res = HtmlWriter.DEFAULT.write(doc);
  print(res); // <h1>Hello world!</h1>
}
```

Writing markdown
----------------

```dart
import "package:md_proc/md_proc.dart";

void main() {
  Document doc = CommonMarkParser.DEFAULT.parse('Hello world!\n===');
  String res = MarkdownWriter.DEFAULT.write(doc);
  print(res); // Hello world\!
              // =============
}
```


[CommonMark]: http://commonmark.org/
