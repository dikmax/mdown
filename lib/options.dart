library md_proc.options;

import 'definitions.dart';

/// Link resolver accepts two references and should return [Target] with correspondent link.
/// If link doesn't exists link resolver should return `null`.
///
/// CommonMark defines reference as case insensitive. Use [normalizedReference] when you need reference
/// normalized according to CommonMark rules, or just [reference] if you want to get reference as it
/// written in document.
typedef Target LinkResolver(String normalizedReference, String reference);

/// Default resolver doesn't return any link, so be default parser parses only explicitly written references.
Target defaultLinkResolver(String normalizedReference, String reference) => null;

class Options {
  final bool smartPunctuation;
  final LinkResolver linkResolver;

  const Options({
          this.smartPunctuation: false,
          this.linkResolver: defaultLinkResolver
          });

  static const Options defaults = const Options(smartPunctuation: true);
  static const Options strict = const Options();
}
