md_proc
=======

[![Build Status](https://travis-ci.org/dikmax/md_proc.svg?branch=master)](https://travis-ci.org/dikmax/md_proc)
[![Coverage Status](https://coveralls.io/repos/dikmax/md_proc/badge.svg?branch=master)](https://coveralls.io/r/dikmax/md_proc?branch=master)
[![Pub](https://img.shields.io/pub/v/md_proc.svg)](https://pub.dartlang.org/packages/md_proc)

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
  Document doc = CommonMarkParser.defaults.parse('Hello world!\n===');
  print(doc); // Document [SetextHeader 1 [Str "Hello", Space, Str "world", Str "!"]]
}
```

Writing html
------------

```dart
import "package:md_proc/md_proc.dart";

void main() {
  Document doc = CommonMarkParser.defaults.parse('Hello world!\n===');
  String res = HtmlWriter.defaults.write(doc);
  print(res); // <h1>Hello world!</h1>
}
```

Writing markdown
----------------

```dart
import "package:md_proc/md_proc.dart";

void main() {
  Document doc = CommonMarkParser.defaults.parse('Hello world!\n===');
  String res = MarkdownWriter.defaults.write(doc);
  print(res); // Hello world!
              // ============
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
  Document doc = CommonMarkParser.strict.parse('...'); // STRICT here
  String res = HtmlWriter.strict.write(doc);           // and here
  print(res); // <p>...</p>
}
```

Custom reference resolver
-------------------------

Custom reference resolver may be required when parsing document without implicit defined references, for example 
Dartdoc.

```dart
/**
 * Throws a [StateError] if ...
 * similar to [anotherMethod], but ...
 */
```

In that case you could supply parser with resolver, which should provide all missing links.
  
```dart
String library = "md_proc";
String version = "0.4.0";
Target linkResolver(String normalizedReference, String reference) {
  if (reference.startsWith("new ")) {
    String className = reference.substring(4);
    return new Target("http://www.dartdocs.org/documentation/$library/$version/index.html#$library/$library.$className@id_$className-", null);
  } else {
    return null;
  }
}

CommonMarkParser parser = new CommonMarkParser(new Options(linkResolver: linkResolver));
Document doc = parser.parse('Hello world!\n===');
String res = HtmlWriter.defaults.write(doc);
```

High-level plan for development
===============================

1. Follow CommonMark specification changes.
2. Add MarkDown-extensions from [pandoc], then change them to CommonMark extensions when they will be finally developed
and accepted. (inline math, footnotes, etc.)
3. AST-processing classes. Don't have much time to think about this. But this is definitely required.

[CommonMark]: http://commonmark.org/
[pandoc]: http://johnmacfarlane.net/pandoc/
