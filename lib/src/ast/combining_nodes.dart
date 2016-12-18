library mdown.src.ast.combining_nodes;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/ast/ast.dart';

// Inlines

/// Combining InlineNode. Used instead of list on parsing time.
class CombiningInlineNodeImpl extends InlineNodeImpl {
  final List<InlineNodeImpl> _list;

  CombiningInlineNodeImpl(this._list);

  List<InlineNodeImpl> get list => _list;

  @override
  R accept<R>(AstVisitor<R> visitor) => null;

  @override
  Iterable<AstNode> get childEntities => _list;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    // _list.accept(visitor);
  }
}

// Blocks

/// Combining BlockNode. Used instead of list on parsing time.
class CombiningBlockNodeImpl extends BlockNodeImpl {
  final List<BlockNodeImpl> _list;

  CombiningBlockNodeImpl(this._list);

  List<BlockNodeImpl> get list => _list;

  @override
  R accept<R>(AstVisitor<R> visitor) => null;

  @override
  Iterable<AstNode> get childEntities => _list;

  @override
  void visitChildren<R>(AstVisitor<R> visitor) {
    // _list.accept(visitor);
  }
}
