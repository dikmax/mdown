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

Smart punctuation
-----------------

Smart punctuation is automatic replacement of `...`, `---`, `--`, `"` and `'` to `…`, `—`, `–` and curly versions of
quote marks accordingly.

By default smart punctuation is enabled. To disable it use STRICT version of parsers/writers.

```dart
import "package:md_proc/md_proc.dart";

void main() {
  Document doc = CommonMarkParser.STRICT.parse('...'); // STRICT here
  String res = HtmlWriter.STRICT.write(doc);           // and here
  print(res); // <h1>...</h1>
}
```

High-level plan for development
===============================

1. Follow CommonMark specification changes.
2. Add MarkDown-extensions from [pandoc], then change them to CommonMark extensions when they will be finally developed
and accepted. (inline math, footnotes, etc.)
3. AST-processing classes. Don't have much time to think about this. But this is definitely required.

[CommonMark]: http://commonmark.org/
[pandoc]: http://johnmacfarlane.net/pandoc/
