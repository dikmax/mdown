library md_proc.options;

import 'definitions.dart';

/// Link resolver accepts two references and should return [Target] with correspondent link.
/// If link doesn't exists link resolver should return `null`.
///
/// CommonMark defines reference as case insensitive. Use [normalizedReference] when you need reference
/// normalized according to CommonMark rules, or just [reference] if you want to get reference as it
/// written in document.
typedef Target LinkResolver(String normalizedReference, String reference);

/// Default resolver doesn't return any link, so parser parses only explicitly written references.
Target defaultLinkResolver(String normalizedReference, String reference) => null;

/// Parser or writer options. Mostly contains list of enabled extensions.
class Options {

  /// Enables smart punctuation extension. It's automatic replacement of `...`, `---`, `--`, `"` and `'` to `…`, `—`,
  /// `–` and curly versions of quote marks accordingly. It's only official extension to date.
  final bool smartPunctuation;

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

  /// Custom reference resolver may be required when parsing document without implicit defined references, for example
  /// Dartdoc.
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
  /// String library = "md_proc";
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
  /// CommonMarkParser parser = new CommonMarkParser(new Options(linkResolver: linkResolver));
  /// Document doc = parser.parse('Hello world!\n===');
  /// String res = HtmlWriter.defaults.write(doc);
  /// ```
  final LinkResolver linkResolver;

  /// Constant constructor with required options.
  const Options({
          this.smartPunctuation: false,
          this.strikeout: false,
          this.subscript: false,
          this.superscript: false,
          this.linkResolver: defaultLinkResolver
          });

  /// Predefined version of Options. Alongside with strict also supports smart puctuation, which is declared separately
  /// in [CommonMark](http://commonmark.org).
  static const Options commonmark = const Options(
      smartPunctuation: true
  );

  /// Predefined version of Options. Enables lot of useful extensions.
  static const Options defaults = const Options(
      smartPunctuation: true,
      strikeout: true,
      subscript: true,
      superscript: true);

  /// Predefined strict version of Options. Only support [CommonMark specification](http://commonmark.org).
  static const Options strict = const Options();
}
