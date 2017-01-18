mdown
=====

[![Build Status](https://travis-ci.org/dikmax/mdown.svg?branch=master)](https://travis-ci.org/dikmax/md_proc)
[![codecov](https://codecov.io/gh/dikmax/mdown/branch/master/graph/badge.svg)](https://codecov.io/gh/dikmax/md_proc)
[![Pub](https://img.shields.io/pub/v/mdown.svg)](https://pub.dartlang.org/packages/mdown)
[![CommonMark spec](https://img.shields.io/badge/commonmark-0.27-green.svg)](http://spec.commonmark.org/)

***mdown*** is fast and [CommonMark][]-compliant Markdown parser.

Basic usage:

```dart
print(markdownToHtml('# Hello world!'));
```

Project main goal is create processing library for Markdown.


Parsing
-------

```dart
import "package:mdown/mdown.dart";

void main() {
  Document doc = CommonMarkParser.defaults.parse('Hello world!\n===');
  print(doc); // Document [SetextHeader 1 [Str "Hello", Space, Str "world", Str "!"]]
}
```


Writing html
------------

```dart
import "package:mdown/mdown.dart";

void main() {
  Document doc = CommonMarkParser.defaults.parse('Hello world!\n===');
  String res = HtmlWriter.defaults.write(doc);
  print(res); // <h1>Hello world!</h1>
}
```


Extensions
==========

mdown supports some language extensions. You can specify enabled extensions using options parameter in parser and
renderer.

```dart
Options options = const Options(superscript: true);
CommonMarkParser parser = new CommonMarkParser(options);
Document doc = parser.parse('Hello world!\n===');
HtmlWriter writer = new HtmlWriter(options);
String res = writer.write(doc);
```

There three predefined versions of parsers/writers:

- `strict`: all extensions are disabled
- `commonmark`: only `smartPunctuation` extension is enabled.
- `defaults`: `smartPunctuation`, `strikeout`, `subscript`,
  `superscript`, `texMathDollars`, `rawTex` are enabled.

To get correspondent parser/writer instance use static getter on class:

```dart
CommonMarkParser defaultParser = CommonMarkParser.defaults;
HtmlWriter strictWriter = HtmlWriter.strict;
```


Smart punctuation (`Options.smartPunctuation`)
----------------------------------------------

Smart punctuation is automatic replacement of `...`, `---`, `--`, `"`
and `'` to "…", "—", "–" and curly versions of quote marks accordingly.
It's only official extension to date.

**NOTE:** This extension uses Unicode chars. Make sure that your code
supports it.


Extended attributes for fenced code (`Options.fencedCodeAttributes`)
--------------------------------------------------------------------

Allows fenced code block to have arbitrary extended attributes.

``````md
``` {#someId .class1 .class2 key=value}
code
```
``````

This will be rendered in HTML as

```html
<pre id="someId" class="class1 class2" key="value"><code>code
</code></pre>
```


Extended attributes for headings (`Options.headingAttributes`)
--------------------------------------------------------------

Allows headings to have arbitrary extended attributes.

``````md
# Heading 1 {#someId}

Heading 2 {.someClass}
-------------------
``````

This will be rendered in html as

```html
<h1 id="someId">Heading 1</h1>
<h2 class="someClass">Heading 2</h2>
```


Extended attributes for inline code (`Options.inlineCodeAttributes`)
--------------------------------------------------------------------

Adds extended attributes support to inline code.

``````md
`code`{#id .class key='value'}
``````

Extended attributes for links and images (`Options.linkAttributes`)
-------------------------------------------------------------------

Extended attributes for links and images. Both inline and reference
links are supported.

``````md
![](image.jpg){width="800" height="600"}

[test][ref]
``````

This will be transformed into:

``````html
<p><img src="image.jpg" width="800" height="600"/></p>
<p><a href="http://test.com/" id="id">test</a></p>
``````

Strikeout (`Options.strikeout`)
-------------------------------

Strikeouts text (~~like this~~). Just wrap text with double tildes (`~~`).

```md
Strikeouts text (~~like this~~).
```


Subscript (`Options.subscript`)
-------------------------------

Support for subscript (H<sub>2</sub>O). Wrap text with tildes (`~`).

```md
H~2~O
```

Subscript couldn't contain spaces. If you need to insert space into the
subscript, escape space (`\ `).

```md
subscript~with\ spaces~
```


Superscript (`Options.superscript`)
-----------------------------------

Support for superscript (2<sup>2</sup>=4). Wrap text with carets (`^`).

```md
2^2^=4
```

Superscript couldn't contain spaces. If you need to insert space into
superscript, escape space (`\ `).

```md
superscript^with\ spaces^
```


TeX Math between dollars (`Options.texMathDollars`)
---------------------------------------------------

Anything between two `$` characters will be treated as inline TeX math.
The opening `$` must have a non-space character immediately to its
right, while the closing `$` must have a non-space character immediately
to its left, and must not be followed immediately by a digit. Thus,
`$20,000 and $30,000` won’t parse as math. If for some reason you need
to enclose text in literal `$` characters, backslash-escape them and
they won’t be treated as math delimiters.

Anything between two `$$` will be treated as display TeX math.

HTML writer generates markup for [MathJax][] library. I.e. wraps content
with `\(...\)` or `\[...\]` and additionally wraps it with
`<span class="math inline">` or `<span class="math display">`. If you
need custom classes for `span` you can override them with
`Options.inlineTexMathClasses` and `Options.displayTexMathClasses`.


TeX Math between backslashed `()` or `[]` (`Options.texMathSingleBackslash`)
----------------------------------------------------------------------------

Causes anything between `\(` and `\)` to be interpreted as inline TeX
math and anything between `\[` and `\]` to be interpreted as display
TeX math.

**NOTE 1:** This extension breaks escaping of `(` and `[]`.

**NOTE 2:** This extension is disabled by default.


TeX Math between double backslashed `()` or `[]` (`Options.texMathDoubleBackslash`)
-----------------------------------------------------------------------------------

Causes anything between `\\(` and `\\)` to be interpreted as inline TeX
math and anything between `\\[` and `\\]` to be interpreted as display
TeX math.

**NOTE:** This extension is disabled by default.


Raw TeX (`Options.rawTex`)
--------------------------

Allows to include raw TeX blocks into documents. Right now only
environment blocks are supported. Everything between `\begin{...}` and
`\end{...}` is treated as TeX and passed into resulting HTML as is.


Custom reference resolver
-------------------------

Custom reference resolver may be required when parsing document without
implicitly defined references, for example, Dartdoc.

```dart
/**
 * Throws a [StateError] if ...
 * similar to [anotherMethod], but ...
 */
```

In that case, you could supply parser with the resolver, which should
provide all missing links.

```dart
String library = "mdown";
String version = "0.4.0";
Target linkResolver(String normalizedReference, String reference) {
  if (reference.startsWith("new ")) {
    String className = reference.substring(4);
    return new Target("http://www.dartdocs.org/documentation/$library/$version/index.html#$library/$library.$className@id_$className-", null);
  } else {
    return null;
  }
}

CommonMarkParser parser = new CommonMarkParser(const Options(linkResolver: linkResolver));
Document doc = parser.parse('Hello world!\n===');
String res = HtmlWriter.defaults.write(doc);
```

[CommonMark]: http://commonmark.org/
[MathJax]: https://www.mathjax.org/
