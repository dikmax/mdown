library md_proc.src.inlines;

import 'dart:collection';

import 'package:md_proc/definitions.dart';

/// Inlines list
class Inlines extends ListBase<Inline> {
  List<Inline> _inlines = new List<Inline>();
  bool _cachedContainsLink;

  /// Constructor
  Inlines();

  /// Constructor from
  Inlines.from(Iterable<Inline> inlines)
      : _inlines = new List<Inline>.from(inlines);

  Inlines.single(Inline inline) : _inlines = <Inline>[] {
    _inlines.add(inline);
  }

  @override
  int get length => _inlines.length;

  @override
  set length(int length) {
    _inlines.length = length;
  }

  @override
  void operator []=(int index, Inline value) {
    _inlines[index] = value;
  }

  @override
  Inline operator [](int index) => _inlines[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  @override
  void add(Inline value) => _inlines.add(value);

  @override
  void addAll(Iterable<Inline> all) => _inlines.addAll(all);

  // Used in parsing.
  bool get containsLink {
    _cachedContainsLink = _cachedContainsLink ??
        any(_isContainsLink);

    return _cachedContainsLink;
  }

  static bool _isContainsLink(Inline inline) {
    if (inline is Emph) {
      assert(inline.contents is Inlines);
      final Inlines contents = inline.contents;
      return contents.containsLink;
    } else if (inline is Strong) {
      assert(inline.contents is Inlines);
      final Inlines contents = inline.contents;
      return contents.containsLink;
    } else if (inline is Strikeout) {
      assert(inline.contents is Inlines);
      final Inlines contents = inline.contents;
      return contents.containsLink;
    } else if (inline is Subscript) {
      assert(inline.contents is Inlines);
      final Inlines contents = inline.contents;
      return contents.containsLink;
    } else if (inline is Superscript) {
      assert(inline.contents is Inlines);
      final Inlines contents = inline.contents;
      return contents.containsLink;
    } else if (inline is Image) {
      assert(inline.label is Inlines);
      final Inlines label = inline.label;
      return label.containsLink;
    } else if (inline is Link) {
      return true;
    }

    return false;
  }
}

class UnparsedInlines extends Inlines {
  String raw;

  UnparsedInlines(this.raw);

  @override
  String toString() => raw;

  @override
  bool operator ==(dynamic obj) => obj is UnparsedInlines && raw == obj.raw;

  @override
  int get hashCode => raw.hashCode;
}
