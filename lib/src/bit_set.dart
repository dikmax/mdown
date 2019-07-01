library mdown.src.bit_set;

import 'dart:collection';
import 'dart:typed_data';

/// Fast bit-set implementation.
class BitSet extends SetMixin<int> {
  /// Constructs new instance of BitSet with specified size.
  BitSet(this._size) : _list = Uint32List(_size >> 5);

  final int _size;
  final Uint32List _list;

  @override
  bool add(int value) {
    if (value > _size || value < 0) {
      throw ArgumentError();
    }

    final int idx = value >> 5;
    final int bit = 1 << (value & 0x1f);
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
      throw ArgumentError();
    }
    final int value = element;
    if (value > _size || value < 0) {
      return false;
    }

    final int idx = value >> 5;
    final int bit = 1 << (value & 0x1f);
    return _list[idx] & bit != 0;
  }

  // TODO(dikmax): implement iterator
  @override
  Iterator<int> get iterator => null;

  // TODO(dikmax): implement length
  @override
  int get length => null;

  @override
  int lookup(Object element) {
    if (element is! int) {
      throw ArgumentError();
    }
    return contains(element) ? element : null;
  }

  @override
  // ignore: avoid_renaming_method_parameters
  bool remove(Object element) {
    if (element is! int) {
      throw ArgumentError();
    }
    final int value = element;
    if (value > _size || value < 0) {
      throw ArgumentError();
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
    // TODO(dikmax): implement toSet
  }
}
