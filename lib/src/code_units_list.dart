library md_proc.src.char_codes_list.dart;

import 'dart:typed_data';
import 'dart:math';

class CodeUnitsList implements Iterable<int> {
  final List<int> _list;
  final int _start;
  final int _end;
  final int _length;

  CodeUnitsList(this._list, [int start, int end]) :
    _start = start ?? 0,
    _end = min(_list.length, end ?? _list.length),
    _length = min(_list.length, end ?? _list.length) - (start ?? 0);

  CodeUnitsList.fromString(String string) : this(string.codeUnits);

  @override
  bool any(bool f(int element)) {
    for (int i = _start; i < _end; i += 1) {
      if (f(_list[i])) {
        return true;
      }
    }
    return false;
  }

  @override
  bool contains(Object element) {
    for (int i = _start; i < _end; i += 1) {
      if (_list[i] == element) {
        return true;
      }
    }
    return false;
  }

  @override
  int elementAt(int index) {
    index += _start;
    RangeError.checkValueInInterval(index, _start, _end - 1, 'index');

    return _list[index];
  }

  @override
  bool every(bool f(int element)) {
    for (int i = _start; i < _end; i += 1) {
      if (!f(_list[i])) {
        return false;
      }
    }
    return true;
  }

  @override
  Iterable expand(Iterable f(int element)) {
    // TODO: implement expand
  }

  @override
  int get first {
    Iterator<int> it = iterator;
    if (!it.moveNext()) {
      throw new StateError('No element');
    }
    return it.current;
  }

  @override
  int firstWhere(bool test(int element), {int orElse()}) {
    // TODO: implement firstWhere
  }

  @override
  dynamic fold(dynamic initialValue, dynamic combine(dynamic previousValue, int element)) {
    // TODO: implement fold
  }

  @override
  void forEach(void f(int element)) {
    // TODO: implement forEach
  }

  // TODO: implement isEmpty
  @override
  bool get isEmpty => null;

  // TODO: implement isNotEmpty
  @override
  bool get isNotEmpty => null;

  // TODO: implement iterator
  @override
  Iterator<int> get iterator => null;

  @override
  String join([String separator = ""]) {
    // TODO: implement join
  }

  // TODO: implement last
  @override
  int get last => null;

  @override
  int lastWhere(bool test(int element), {int orElse()}) {
    // TODO: implement lastWhere
  }

  // TODO: implement length
  @override
  int get length => null;

  @override
  Iterable map(dynamic f(int e)) {
    // TODO: implement map
  }

  @override
  int reduce(int combine(int value, int element)) {
    // TODO: implement reduce
  }

  // TODO: implement single
  @override
  int get single => null;

  @override
  int singleWhere(bool test(int element)) {
    // TODO: implement singleWhere
  }

  @override
  Iterable<int> skip(int count) {
    // TODO: implement skip
  }

  @override
  Iterable<int> skipWhile(bool test(int value)) {
    // TODO: implement skipWhile
  }

  @override
  Iterable<int> take(int count) {
    // TODO: implement take
  }

  @override
  Iterable<int> takeWhile(bool test(int value)) {
    // TODO: implement takeWhile
  }

  @override
  List<int> toList({bool growable: true}) {
    // TODO: implement toList
  }

  @override
  Set<int> toSet() {
    // TODO: implement toSet
  }

  @override
  Iterable<int> where(bool test(int element)) {
    // TODO: implement where
  }
}
