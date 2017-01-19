library mdown.src.bit_set;

import 'dart:collection';
import 'dart:typed_data';

/// Fast bit-set implementation.
class BitSet extends SetMixin<int> {
  final int _size;
  final Uint32List _list;

  /// Constructs new instance of BitSet with specified size.
  BitSet(this._size) : _list = new Uint32List(_size >> 5);

  @override
  bool add(int element) {
    if (element > _size || element < 0) {
      throw new ArgumentError();
    }

    final int idx = element >> 5;
    final int bit = 1 << (element & 0x1f);
    if (_list[idx] & bit == 0) {
      _list[idx] |= bit;
      return true;
    } else {
      return false;
    }
  }

  @override
  bool contains(Object element) {
    if (element is! int) {
      throw new ArgumentError();
    }
    final int value = element;
    if (value > _size || value < 0) {
      return false;
    }

    final int idx = value >> 5;
    final int bit = 1 << (value & 0x1f);
    return _list[idx] & bit != 0;
  }

  // TODO: implement iterator
  @override
  Iterator<int> get iterator => null;

  // TODO: implement length
  @override
  int get length => null;

  @override
  int lookup(Object element) => contains(element) ? element as int : null;

  @override
  bool remove(Object element) {
    if (element is! int) {
      throw new ArgumentError();
    }
    final int value = element;
    if (value > _size || value < 0) {
      throw new ArgumentError();
    }

    final int idx = value >> 5;
    final int bit = 1 << (value & 0x1f);
    if ((_list[idx] & bit) != 0) {
      _list[idx] &= ~bit;
      return true;
    } else {
      return false;
    }
  }

  @override
  Set<int> toSet() {
    // TODO: implement toSet
  }
}
