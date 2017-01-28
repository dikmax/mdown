library md_proc.src.char_codes_list.dart;

import 'dart:math';
import 'code_units.dart';

abstract class CodeUnitsList implements Iterable<int> {
  const CodeUnitsList();

  factory CodeUnitsList.concatenated(List<CodeUnitsList> lists) {
    if (lists.isEmpty) {
      return new _CodeUnitsEmpty();
    }
    if (lists.length == 1) {
      return lists.single;
    }
    List<CodeUnitsList> result = <CodeUnitsList>[];
    for (CodeUnitsList list in lists) {
      if (list.isNotEmpty) {
        result.add(list);
      }
    }
    if (result.isEmpty) {
      return new _CodeUnitsEmpty();
    }
    if (result.length == 1) {
      return result.single;
    }

    return new _CodeUnitsListConcat(result);
  }

  factory CodeUnitsList.string(String string, [int start, int end]) =>
      new _CodeUnitsSublist(string.codeUnits, start, end);

  factory CodeUnitsList.multiple(int codeUnit, int length) {
    if (length == 0) {
      return const _CodeUnitsEmpty();
    } else if (length == 1) {
      return new _CodeUnitsSingle(codeUnit);
    } else {
      return new _CodeUnitsMultiple(codeUnit, length);
    }
  }

  factory CodeUnitsList.single(int codeUnit) => new _CodeUnitsSingle(codeUnit);

  factory CodeUnitsList.empty() => const _CodeUnitsEmpty();

  int operator [](int index);

  CodeUnitsList concat(Iterable<CodeUnitsList> lists);

  @override
  CodeUnitsList skip(int count);

  @override
  CodeUnitsList skipWhile(bool test(int value));

  CodeUnitsList sublist(int start, [int end]);

  @override
  CodeUnitsList take(int count);

  @override
  CodeUnitsList takeWhile(bool test(int value));

  @override
  List<int> toList({bool growable: true}) =>
      new List<int>.from(this, growable: growable);

  @override
  Set<int> toSet() => new Set<int>.from(this);

  /**
   * Remove spaces and tabs from left and right.
   */
  CodeUnitsList trim();

  /**
   * Remove spaces and tabs from left.
   */
  CodeUnitsList trimLeft();

  /**
   * Remove spaces and tabs from right.
   */
  CodeUnitsList trimRight();
}

class _CodeUnitsEmpty extends CodeUnitsList {
  const _CodeUnitsEmpty();

  @override
  int operator [](int index) {
    throw new RangeError('Empty');
  }

  @override
  bool any(bool f(int element)) => false;

  @override
  CodeUnitsList concat(Iterable<CodeUnitsList> lists) =>
      new CodeUnitsList.concatenated(lists);

  @override
  bool contains(Object element) => false;

  @override
  int elementAt(int index) {
    throw new RangeError('Empty');
  }

  @override
  bool every(bool f(int element)) => true;

  @override
  Iterable<T> expand<T>(Iterable<T> f(int element)) => <T>[];

  @override
  int get first => throw new RangeError('Empty');

  @override
  int firstWhere(bool test(int element), {int orElse()}) {
    throw new RangeError('Empty');
  }

  @override
  T fold<T>(T initialValue, T combine(T previousValue, int element)) =>
      initialValue;

  @override
  void forEach(void f(int element)) {}

  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;

  @override
  Iterator<int> get iterator =>
      throw new UnimplementedError('CodeUnitList.iterator');

  @override
  String join([String separator = ""]) => '';

  @override
  int get last => throw new RangeError('Empty');

  @override
  int lastWhere(bool test(int element), {int orElse()}) =>
      throw new RangeError('Empty');

  @override
  int get length => 0;

  @override
  Iterable<T> map<T>(T f(int e)) => <T>[];

  @override
  int reduce(int combine(int value, int element)) {
    throw new RangeError('Empty');
  }

  @override
  int get single => throw new RangeError('Empty');

  @override
  int singleWhere(bool test(int element)) => throw new RangeError('Empty');

  @override
  CodeUnitsList skip(int count) => this;

  @override
  CodeUnitsList skipWhile(bool test(int value)) => this;

  @override
  CodeUnitsList sublist(int start, [int end]) {
    throw new RangeError('Empty');
  }

  @override
  CodeUnitsList take(int count) => this;

  @override
  CodeUnitsList takeWhile(bool test(int value)) => this;

  @override
  List<int> toList({bool growable: true}) =>
      new List<int>.from(<int>[], growable: growable);

  @override
  Set<int> toSet() => new Set<int>();

  @override
  String toString() => '';

  @override
  CodeUnitsList trim() => this;

  @override
  CodeUnitsList trimLeft() => this;

  @override
  CodeUnitsList trimRight() => this;

  @override
  Iterable<int> where(bool test(int element)) => const <int>[];
}

class _CodeUnitsSingle extends CodeUnitsList {
  final int codeUnit;

  const _CodeUnitsSingle(this.codeUnit);

  @override
  int operator [](int index) {
    if (index != 0) {
      throw new RangeError('index is out of bounds');
    }

    return codeUnit;
  }

  @override
  bool any(bool f(int element)) => f(codeUnit);

  @override
  CodeUnitsList concat(Iterable<CodeUnitsList> lists) =>
      new CodeUnitsList.concatenated(<CodeUnitsList>[this]..addAll(lists));

  @override
  bool contains(Object element) => codeUnit == element;

  @override
  int elementAt(int index) {
    if (index != 0) {
      throw new RangeError('index is out of bounds');
    }

    return codeUnit;
  }

  @override
  bool every(bool f(int element)) => f(codeUnit);

  @override
  Iterable<T> expand<T>(Iterable<T> f(int element)) => f(codeUnit);

  @override
  int get first => codeUnit;

  @override
  int firstWhere(bool test(int element), {int orElse()}) {
    throw new UnimplementedError('_CodeUnitsSingle.firstWhere');
  }

  @override
  T fold<T>(T initialValue, T combine(T previousValue, int element)) => combine(
      initialValue, codeUnit);

  @override
  void forEach(void f(int element)) {
    f(codeUnit);
  }

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => true;

  @override
  Iterator<int> get iterator =>
      throw new UnimplementedError('_CodeUnitsSingle.iterator');

  @override
  String join([String separator = ""]) =>
      throw new UnimplementedError('_CodeUnitsSingle.join');

  @override
  int get last => codeUnit;

  @override
  int lastWhere(bool test(int element), {int orElse()}) {
    throw new UnimplementedError('_CodeUnitsSingle.lastWhere');
  }

  @override
  int get length => 1;

  @override
  Iterable<T> map<T>(T f(int e)) => <T>[f(codeUnit)];

  @override
  int reduce(int combine(int value, int element)) => codeUnit;

  @override
  int get single => codeUnit;

  @override
  int singleWhere(bool test(int element)) {
    throw new UnimplementedError('_CodeUnitsSingle.iterator');
  }

  @override
  CodeUnitsList skip(int count) {
    throw new UnimplementedError('_CodeUnitsSingle.skip');
  }

  @override
  CodeUnitsList skipWhile(bool test(int value)) {
    throw new UnimplementedError('_CodeUnitsSingle.skipWhile');
  }

  @override
  CodeUnitsList sublist(int start, [int end]) {
    RangeError.checkValidRange(start, end, 1, 'start', 'end');
    if (start == end ?? 1) {
      return new CodeUnitsList.empty();
    }
    return this;
  }

  @override
  CodeUnitsList take(int count) {
    throw new UnimplementedError('_CodeUnitsSingle.take');
  }

  @override
  CodeUnitsList takeWhile(bool test(int value)) {
    throw new UnimplementedError('_CodeUnitsSingle.takeWhile');
  }

  @override
  String toString() => new String.fromCharCode(codeUnit);

  @override
  CodeUnitsList trim() => codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit
      ? const _CodeUnitsEmpty()
      : this;

  @override
  CodeUnitsList trimLeft() =>
      codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit
          ? const _CodeUnitsEmpty()
          : this;

  @override
  CodeUnitsList trimRight() =>
      codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit
          ? const _CodeUnitsEmpty()
          : this;

  @override
  Iterable<int> where(bool test(int element)) {
    throw new UnimplementedError('_CodeUnitsSingle.takeWhile');
  }
}

class _CodeUnitsMultiple extends CodeUnitsList {
  final int codeUnit;
  final int length;

  const _CodeUnitsMultiple(this.codeUnit, this.length);

  @override
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw new RangeError('index is out of bounds');
    }

    return codeUnit;
  }

  @override
  bool any(bool f(int element)) {
    throw new UnimplementedError('_CodeUnitsMultiple.any');
  }

  @override
  CodeUnitsList concat(Iterable<CodeUnitsList> lists) =>
      new CodeUnitsList.concatenated(<CodeUnitsList>[this]..addAll(lists));

  @override
  bool contains(Object element) => element == codeUnit;

  @override
  int elementAt(int index) {
    if (index < 0 || index >= length) {
      throw new RangeError('index is out of bounds');
    }

    return codeUnit;
  }

  @override
  bool every(bool f(int element)) {
    throw new UnimplementedError('_CodeUnitsMultiple.every');
  }

  @override
  Iterable<T> expand<T>(Iterable<T> f(int element)) =>
      throw new UnimplementedError('_CodeUnitsMultiple.expand');

  @override
  int get first => codeUnit;

  @override
  int firstWhere(bool test(int element), {int orElse()}) {
    throw new UnimplementedError('_CodeUnitsMultiple.firstWhere');
  }

  @override
  T fold<T>(T initialValue, T combine(T previousValue, int element)) {
    throw new UnimplementedError('_CodeUnitsMultiple.fold');
  }

  @override
  void forEach(void f(int element)) {
    throw new UnimplementedError('_CodeUnitsMultiple.forEach');
  }

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => true;

  @override
  Iterator<int> get iterator =>
      throw new UnimplementedError('_CodeUnitsMultiple.iterator');

  @override
  String join([String separator = ""]) {
    throw new UnimplementedError('_CodeUnitsMultiple.join');
  }

  @override
  int get last => codeUnit;

  @override
  int lastWhere(bool test(int element), {int orElse()}) {
    throw new UnimplementedError('_CodeUnitsMultiple.lastWhere');
  }

  @override
  Iterable<T> map<T>(T f(int e)) {
    throw new UnimplementedError('_CodeUnitsMultiple.map');
  }

  @override
  int reduce(int combine(int value, int element)) {
    throw new UnimplementedError('_CodeUnitsMultiple.reduce');
  }

  @override
  int get single => throw new UnimplementedError('_CodeUnitsMultiple.single');

  @override
  int singleWhere(bool test(int element)) {
    throw new UnimplementedError('_CodeUnitsMultiple.singleWhere');
  }

  @override
  CodeUnitsList skip(int count) {
    throw new UnimplementedError('_CodeUnitsMultiple.skip');
  }

  @override
  CodeUnitsList skipWhile(bool test(int value)) {
    throw new UnimplementedError('_CodeUnitsMultiple.skipWhile');
  }

  @override
  CodeUnitsList sublist(int start, [int end]) {
    throw new UnimplementedError('_CodeUnitsMultiple.sublist');
  }

  @override
  CodeUnitsList take(int count) {
    throw new UnimplementedError('_CodeUnitsMultiple.take');
  }

  @override
  CodeUnitsList takeWhile(bool test(int value)) {
    throw new UnimplementedError('_CodeUnitsMultiple.takeWhile');
  }

  @override
  String toString() => new String.fromCharCode(codeUnit) * length;

  @override
  CodeUnitsList trim() => codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit
      ? const _CodeUnitsEmpty()
      : this;

  @override
  CodeUnitsList trimLeft() =>
      codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit
          ? const _CodeUnitsEmpty()
          : this;

  @override
  CodeUnitsList trimRight() =>
      codeUnit == spaceCodeUnit || codeUnit == tabCodeUnit
          ? new _CodeUnitsEmpty()
          : this;

  @override
  Iterable<int> where(bool test(int element)) {
    throw new UnimplementedError('_CodeUnitsMultiple.where');
  }
}

class _CodeUnitsSublistIterator extends Iterator<int> {
  final List<int> _list;
  final int _start;
  final int _end;
  int _current;

  _CodeUnitsSublistIterator(this._list, this._start, this._end);

  @override
  int get current => _list[_current];

  @override
  bool moveNext() {
    _current = _current == null ? _start : _current + 1;
    return _current < _end;
  }
}

class _CodeUnitsSublist extends CodeUnitsList {
  final List<int> _list;
  final int _start;
  final int _end;
  final int _length;

  _CodeUnitsSublist(this._list, [int start, int end])
      : _start = start ?? 0,
        _end = min(_list.length, end ?? _list.length),
        _length = min(_list.length, end ?? _list.length) - (start ?? 0);

  int operator [](int index) {
    assert(index >= 0);
    assert(index < length);

    return _list[index + _start];
  }

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
  CodeUnitsList concat(Iterable<CodeUnitsList> lists) =>
      new CodeUnitsList.concatenated(<CodeUnitsList>[this]..addAll(lists));

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
  Iterable<T> expand<T>(Iterable<T> f(int element)) =>
      throw new UnimplementedError('_CodeUnitsSublist.expand');

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
    throw new UnimplementedError('_CodeUnitsSublist.firstWhere');
  }

  @override
  T fold<T>(T initialValue, T combine(T previousValue, int element)) {
    throw new UnimplementedError('_CodeUnitsSublist.fold');
  }

  @override
  void forEach(void f(int element)) {
    throw new UnimplementedError('_CodeUnitsSublist.forEach');
  }

  @override
  bool get isEmpty => _length == 0;

  @override
  bool get isNotEmpty => _length != 0;

  @override
  Iterator<int> get iterator => new _CodeUnitsSublistIterator(_list, _start, _end);

  @override
  String join([String separator = ""]) {
    throw new UnimplementedError('_CodeUnitsSublist.join');
  }

  @override
  int get last => throw new UnimplementedError('_CodeUnitsSublist.last');

  @override
  int lastWhere(bool test(int element), {int orElse()}) {
    throw new UnimplementedError('_CodeUnitsSublist.lastWhere');
  }

  @override
  int get length => _length;

  @override
  Iterable<T> map<T>(T f(int e)) =>
      throw new UnimplementedError('_CodeUnitsSublist.map');

  @override
  int reduce(int combine(int value, int element)) {
    throw new UnimplementedError('_CodeUnitsSublist.reduce');
  }

  @override
  int get single => throw new UnimplementedError('_CodeUnitsSublist.single');

  @override
  int singleWhere(bool test(int element)) {
    throw new UnimplementedError('_CodeUnitsSublist.singleWhere');
  }

  @override
  CodeUnitsList skip(int count) {
    throw new UnimplementedError('_CodeUnitsSublist.skip');
  }

  @override
  CodeUnitsList skipWhile(bool test(int value)) {
    throw new UnimplementedError('_CodeUnitsSublist.skipWhile');
  }

  CodeUnitsList sublist(int start, [int end]) {
    RangeError.checkValidRange(start, end, _length, 'start', 'end');

    final int newStart = _start + start;
    final int newEnd = _start + (end ?? _length);
    if (newStart == newEnd) {
      return new CodeUnitsList.empty();
    }
    if (newStart + 1 == newEnd) {
      return new CodeUnitsList.single(_list[newStart]);
    }
    return new _CodeUnitsSublist(_list, newStart, newEnd);
  }

  @override
  CodeUnitsList take(int count) {
    throw new UnimplementedError('_CodeUnitsSublist.take');
  }

  @override
  CodeUnitsList takeWhile(bool test(int value)) {
    throw new UnimplementedError('_CodeUnitsSublist.takeWhile');
  }

  @override
  List<int> toList({bool growable: true}) => _list.sublist(_start, _end);

  @override
  String toString() => new String.fromCharCodes(_list, _start, _end);

  @override
  CodeUnitsList trim() {
    int start = _start;
    int end = _end;

    while (start < end) {
      final int codeUnit = _list[start];
      if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
        break;
      }
      start += 1;
    }

    while (end > start) {
      final int codeUnit = _list[end - 1];
      if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
        break;
      }
      end -= 1;
    }

    if (start == _start && end == _end) {
      return this;
    }
    if (start == end) {
      return const _CodeUnitsEmpty();
    }
    if (start + 1 == end) {
      return new _CodeUnitsSingle(_list[start]);
    }
    return new _CodeUnitsSublist(_list, start, end);
  }

  @override
  CodeUnitsList trimLeft() {
    int start = _start;
    while (start < _end) {
      final int codeUnit = _list[start];
      if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
        break;
      }
      start += 1;
    }

    if (start == _start) {
      return this;
    }
    if (start == _end) {
      return const _CodeUnitsEmpty();
    }
    if (start + 1 == _end) {
      return new _CodeUnitsSingle(_list[start]);
    }
    return new _CodeUnitsSublist(_list, start, _end);
  }

  @override
  CodeUnitsList trimRight() {
    int end = _end;
    while (end > _start) {
      final int codeUnit = _list[end - 1];
      if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
        break;
      }
      end -= 1;
    }

    if (end == _end) {
      return this;
    }
    if (end == _start) {
      return const _CodeUnitsEmpty();
    }
    if (end == _start + 1) {
      return new _CodeUnitsSingle(_list[_start]);
    }
    return new _CodeUnitsSublist(_list, _start, end);
  }

  @override
  Iterable<int> where(bool test(int element)) {
    throw new UnimplementedError('_CodeUnitsSublist.where');
  }
}

class _CodeUnitsListConcat extends CodeUnitsList {
  List<CodeUnitsList> lists;
  List<int> starts;
  int length;

  _CodeUnitsListConcat(this.lists) {
    int start = 0;
    assert(lists.isNotEmpty);
    starts = <int>[];
    for (CodeUnitsList list in lists) {
      starts.add(start);
      assert(list.isNotEmpty);
      start += list.length;
    }
    length = start;
  }

  int _findList(int index) {
    RangeError.checkValueInInterval(index, 0, length - 1, 'index');
    int start = 0;
    int end = lists.length;
    while (end - start > 1) {
      int middle = (end - start) ~/ 2 + start;
      int middleIndex = starts[middle];
      if (middleIndex == index) {
        return middle;
      }
      if (middleIndex < index) {
        start = middle;
      } else {
        end = middle;
      }
    }

    return start;
  }

  @override
  int operator [](int index) {
    int list = _findList(index);
    return lists[list][index - starts[list]];
  }

  @override
  bool any(bool f(int element)) {
    throw new UnimplementedError('_CodeUnitsListConcat.any');
  }

  @override
  CodeUnitsList concat(Iterable<CodeUnitsList> lists) =>
      new CodeUnitsList.concatenated(
          <CodeUnitsList>[]..addAll(this.lists)..addAll(lists));

  @override
  bool contains(Object element) {
    throw new UnimplementedError('_CodeUnitsListConcat.contains');
  }

  @override
  int elementAt(int index) {
    int list = _findList(index);
    return lists[list][index - starts[list]];
  }

  @override
  bool every(bool f(int element)) {
    throw new UnimplementedError('_CodeUnitsListConcat.every');
  }

  @override
  Iterable<T> expand<T>(Iterable<T> f(int element)) {
    throw new UnimplementedError('_CodeUnitsListConcat.expand');
  }

  @override
  int get first => lists.first.first;

  @override
  int firstWhere(bool test(int element), {int orElse()}) {
    throw new UnimplementedError('_CodeUnitsListConcat.firstWhere');
  }

  @override
  T fold<T>(T initialValue, T combine(T previousValue, int element)) {
    throw new UnimplementedError('_CodeUnitsListConcat.fold');
  }

  @override
  void forEach(void f(int element)) {
    throw new UnimplementedError('_CodeUnitsListConcat.forEach');
  }

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => true;

  @override
  Iterator<int> get iterator =>
      throw new UnimplementedError('_CodeUnitsListConcat.iterator');

  @override
  String join([String separator = ""]) {
    throw new UnimplementedError('_CodeUnitsListConcat.join');
  }

  @override
  int get last => lists.last.last;

  @override
  int lastWhere(bool test(int element), {int orElse()}) {
    throw new UnimplementedError('_CodeUnitsListConcat.lastWhere');
  }

  @override
  Iterable<T> map<T>(T f(int e)) {
    throw new UnimplementedError('_CodeUnitsListConcat.map');
  }

  @override
  int reduce(int combine(int value, int element)) {
    throw new UnimplementedError('_CodeUnitsListConcat.reduce');
  }

  @override
  int get single => lists.single.single;

  @override
  int singleWhere(bool test(int element)) {
    throw new UnimplementedError('_CodeUnitsListConcat.singleWhere');
  }

  @override
  CodeUnitsList skip(int count) {
    throw new UnimplementedError('_CodeUnitsListConcat.skip');
  }

  @override
  CodeUnitsList skipWhile(bool test(int value)) {
    throw new UnimplementedError('_CodeUnitsListConcat.skipWhile');
  }

  @override
  CodeUnitsList sublist(int start, [int end]) {
    RangeError.checkValidRange(start, end, length, 'start', 'end');

    end ??= length;
    if (start == 0 && end == length) {
      return this;
    }

    final int startIndex = _findList(start);
    final int endIndex = _findList(end - 1);

    if (startIndex == endIndex) {
      return lists[startIndex]
          .sublist(start - starts[startIndex], end - starts[startIndex]);
    }

    List<CodeUnitsList> result = <CodeUnitsList>[];
    int copyStart = startIndex;
    if (starts[startIndex] != start) {
      copyStart += 1;
      result.add(lists[startIndex].sublist(start - starts[startIndex]));
    }
    int copyEnd = endIndex;
    if (end - starts[endIndex] == lists[endIndex].length) {
      copyEnd -= 1;
    }
    result.addAll(lists.sublist(copyStart, copyEnd + 1));
    if (copyEnd != endIndex) {
      result.add(lists[endIndex].sublist(0, end - starts[endIndex]));
    }

    return new _CodeUnitsListConcat(result);
  }

  @override
  CodeUnitsList take(int count) {
    throw new UnimplementedError('_CodeUnitsListConcat.take');
  }

  @override
  CodeUnitsList takeWhile(bool test(int value)) {
    throw new UnimplementedError('_CodeUnitsListConcat.takeWhile');
  }

  @override
  CodeUnitsList trim() {
    throw new UnimplementedError('_CodeUnitsListConcat.trim');
  }

  @override
  CodeUnitsList trimLeft() {
    throw new UnimplementedError('_CodeUnitsListConcat.trimLeft');
  }

  @override
  CodeUnitsList trimRight() {
    int end = lists.length;
    CodeUnitsList replaceLast;
    while (end > 0) {
      final CodeUnitsList list = lists[end - 1];
      final CodeUnitsList trimmedList = list.trimRight();
      if (list.length == trimmedList.length) {
        break;
      }
      if (trimmedList.length > 0) {
        replaceLast = trimmedList;
        break;
      }
      end -= 1;
    }

    if (end == lists.length && replaceLast == null) {
      return this;
    }
    if (end == 0) {
      return const _CodeUnitsEmpty();
    }
    if (end == 1 && replaceLast == null) {
      return lists.first;
    }

    List<CodeUnitsList> result =
        lists.sublist(0, replaceLast == null ? end : end - 1);
    if (replaceLast != null) {
      result.add(replaceLast);
    }
    return new _CodeUnitsListConcat(result);
  }

  @override
  Iterable<int> where(bool test(int element)) {
    throw new UnimplementedError('_CodeUnitsListConcat.where');
  }
}
