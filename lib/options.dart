library mdown.options;

import 'ast/ast.dart';

/// Link resolver accepts two references and should return [Target] with correspondent link.
/// If link doesn't exists link resolver should return `null`.
///
/// CommonMark defines reference as case insensitive. Use [normalizedReference] when you need reference
/// normalized according to CommonMark rules, or just [reference] if you want to get reference as it
/// written in document.
typedef Target LinkResolver(String normalizedReference, String reference);

/// Default resolver doesn't return any link, so parser parses only explicitly written references.
Target defaultLinkResolver(String normalizedReference, String reference) =>
    null;

/// Parser or writer options. Mostly contains list of enabled extensions.
class Options {
  /// Enables raw html blocks and inlines. This officially supported extension
  /// from Commonmart and thus requires explicit disabling.
  final bool rawHtml;

  /// Enables smart punctuation extension. It's automatic replacement of `...`, `---`, `--`, `"` and `'` to `…`, `—`,
  /// `–` and curly versions of quote marks accordingly. It's only official extension to date.
  final bool smartPunctuation;

  /// Allows fenced code block to have arbitrary extended attributes.
  ///
  /// ``````md
  /// ``` {#someId .class1 .class2 key=value}
  /// code
  /// ```
  /// ``````
  ///
  /// This will be rendered in HTML as
  ///
  /// ```html
  /// <pre id="someId" class="class1 class2" key="value"><code>code
  /// </code></pre>
  /// ```
  final bool fencedCodeAttributes;

  /// Allows headings to have arbitrary extended attributes.
  ///
  /// ``````md
  /// # Heading 1 {#someId}
  ///
  /// Heading 2 {.someClass}
  /// -------------------
  /// ``````
  ///
  /// This will be rendered in html as
  ///
  /// ```html
  /// <h1 id="someId">Heading 1</h1>
  /// <h2 class="someClass">Heading 2</h2>
  /// ```
  final bool headingAttributes;

  /// Adds extended attributes support to inline code.
  ///
  /// ``````md
  /// `code`{#id .class key='value'}
  /// ``````
  final bool inlineCodeAttributes;

  /// Extended attributes for links and images. Both inline and reference links are
  /// supported.
  ///
  /// ``````md
  /// ![](image.jpg){width="800" height="600"}
  ///
  /// [test][ref]
  /// ``````
  ///
  /// This will be transformed into:
  ///
  /// ``````html
  /// <p><img src="image.jpg" width="800" height="600"/></p>
  /// <p><a href="http://test.com/" id="id">test</a></p>
  /// ``````
  final bool linkAttributes;

  /// Enables strikeout extension. Strikeout is a text wrapped with double tilde (`~~`). Example:
  ///
  /// ```md
  /// Strikeouts text (~~like this~~).
  /// ```
  final bool strikeout;

  /// Enables subscript extension. Subscript is a text wrapped with tilde (`~`). Example:
  ///
  /// ```md
  /// H~2~O
  /// ```
  ///
  /// Subscript couldn't contain spaces. If you need to insert space into subscript, escape space (`\ `).
  ///
  /// ```md
  /// subscript~with\ spaces~
  /// ```
  final bool subscript;

  /// Enables superscript extension. Superscript is a text wrapped with caret (`^`). Example:
  ///
  /// ```md
  /// 2^2^=4
  /// ```
  ///
  /// Superscript couldn't contain spaces. If you need to insert space into superscript, escape space (`\ `).
  ///
  /// ```md
  /// superscript^with\ spaces^
  /// ```
  final bool superscript;

  /// Enables tex math inside `$` or `$$`.
  ///
  /// Anything between two `$` characters will be treated as TeX math. The
  /// opening `$` must have a non-space character immediately to its right,
  /// while the closing `$` must have a non-space character immediately to its
  /// left, and must not be followed immediately by a digit. Thus,
  /// `$20,000 and $30,000` won’t parse as math. If for some reason you need to
  /// enclose text in literal `$` characters, backslash-escape them and they
  /// won’t be treated as math delimiters.
  final bool texMathDollars;

  /// Causes anything between `\(` and `\)` to be interpreted as inline TeX
  /// math, and anything between `\[` and `\]` to be interpreted as display
  /// TeX math.
  ///
  /// Note: a drawback of this extension is that it precludes escaping `(` and
  /// `[`.
  final bool texMathSingleBackslash;

  /// Causes anything between `\\(` and `\\)` to be interpreted as inline TeX
  /// math, and anything between `\\[` and `\\]` to be interpreted as display
  /// TeX math.
  final bool texMathDoubleBackslash;

  /// Classes added to `span` on rendering inline math into html.
  /// Defaults to `['math', 'inline']`.
  final Iterable<String> inlineTexMathClasses;

  /// Classes added to `span` on rendering display math into html.
  /// Defaults to `['math', 'display']`.
  final Iterable<String> displayTexMathClasses;

  /// Enables raw TeX blocks.
  ///
  /// Everything between \begin{env} \end{env} is treated as TeX. Delimiters
  /// should be placed on separate lines and `env` identifiers should be same.
  final bool rawTex;

  /// Custom reference resolver may be required when parsing document without
  /// implicit defined references, for example Dartdoc.
  ///
  /// ```dart
  /// /**
  ///  * Throws a [StateError] if ...
  ///  * similar to [anotherMethod], but ...
  ///  */
  /// ```
  ///
  /// In that case you could supply parser with resolver, which should provide all missing links.
  ///
  /// ```dart
  /// String library = "mdown";
  /// String version = "0.4.0";
  /// Target linkResolver(String normalizedReference, String reference) {
  ///   if (reference.startsWith("new ")) {
  ///     String className = reference.substring(4);
  ///     return new Target("http://www.dartdocs.org/documentation/$library/$version/index.html#$library/$library.$className@id_$className-", null);
  ///   } else {
  ///     return null;
  ///   }
  /// }
  ///
  /// CommonMarkParser parser = new CommonMarkParser(const Options(linkResolver: linkResolver));
  /// Document doc = parser.parse('Hello world!\n===');
  /// String res = HtmlWriter.defaults.write(doc);
  /// ```
  final LinkResolver linkResolver;

  /// Constant constructor with required options.
  const Options(
      {this.rawHtml: true,
      this.smartPunctuation: false,
      this.fencedCodeAttributes: false,
      this.headingAttributes: false,
      this.inlineCodeAttributes: false,
      this.linkAttributes: false,
      this.strikeout: false,
      this.subscript: false,
      this.superscript: false,
      this.texMathDollars: false,
      this.texMathSingleBackslash: false,
      this.texMathDoubleBackslash: false,
      this.rawTex: false,
      this.inlineTexMathClasses: const <String>['math', 'inline'],
      this.displayTexMathClasses: const <String>['math', 'display'],
      this.linkResolver: defaultLinkResolver});

  /// Predefined version of Options. Alongside with strict also supports smart puctuation, which is declared separately
  /// in [CommonMark](http://commonmark.org).
  static const Options commonmark = const Options(smartPunctuation: true);

  /// Predefined version of Options. Enables lot of useful extensions.
  static const Options defaults = const Options(
      smartPunctuation: true,
      fencedCodeAttributes: true,
      headingAttributes: true,
      inlineCodeAttributes: true,
      linkAttributes: true,
      strikeout: true,
      subscript: true,
      superscript: true,
      texMathDollars: true,
      rawTex: true);

  /// Predefined strict version of Options. Only support [CommonMark specification](http://commonmark.org).
  static const Options strict = const Options();
}
