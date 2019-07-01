library mdown.src.ast.unparsed_inlies;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';

/// Unparsed inlines. Used in parsing process.
abstract class UnparsedInlines implements BaseInline {
  /// Unparsed inlines contents.
  String get contents;

  set contents(String contents);
}

/// Default UnparsedInline implementation.
class UnparsedInlinesImpl extends InlineNodeImpl implements UnparsedInlines {
  /// Constructs UnparsedInlines implementation.
  UnparsedInlinesImpl(this._contents);

  String _contents;

  @override
  // ignore: unnecessary_getters_setters
  String get contents => _contents;

  @override
  // ignore: unnecessary_getters_setters
  set contents(String contents) {
    _contents = contents;
  }

  @override
  R accept<R>(AstVisitor<R> visitor) {
    if (visitor is UnparsedInlinesVisitor) {
      final UnparsedInlinesVisitor<R> v = visitor;
      return v.visitUnparsedInlines(this);
    }

    return null;
  }

  @override
  Iterable<AstNode> get childEntities => null;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {}
}

/// Extended visitor for UnparsedInlines.
abstract class UnparsedInlinesVisitor<R> extends AstVisitor<R> {
  /// Visits all unparsed inlines.
  R visitUnparsedInlines(UnparsedInlines node);
}
