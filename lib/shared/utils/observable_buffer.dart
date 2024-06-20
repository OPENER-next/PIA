import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';

/// A cyclic buffer that is observable.

class ObservableBuffer<T> with IterableBase<T> {
  int _limit;

  final QueueList<T> _buffer;

  final Atom _atom;

  ObservableBuffer({
    required int limit,
    Iterable<T> initialElements = const Iterable.empty(),
  }) :
    _limit = limit,
    _buffer = QueueList.from(initialElements),
    _atom = Atom();

  int get limit {
    _atom.reportRead();
    return _limit;
  }

  set limit(int value) {
    _atom.reportWrite(_limit, value, () {
      _limit = value;
      _handleLimit();
    });
  }

  @override
  T get first {
    _atom.reportRead();
    return _buffer.first;
  }

  @override
  T get last {
    _atom.reportRead();
    return _buffer.last;
  }

  @override
  int get length {
    _atom.reportRead();
    return _buffer.length;
  }

  void push(T value) {
    _buffer.addLast(value);
    _handleLimit();
    _atom.reportChanged();
  }

  T removeFirst() {
    final item = _buffer.removeFirst();
    _atom.reportChanged();
    return item;
  }

  T removeLast() {
    final item = _buffer.removeLast();
    _atom.reportChanged();
    return item;
  }

  @override
  T elementAt(int index) {
    _atom.reportRead();
    return _buffer[index];
  }

  @override
  Iterator<T> get iterator {
    _atom.reportRead();
    return _buffer.iterator;
  }

  /// Removes any old item that esceeds the buffer limit.

  void _handleLimit() {
    while (_buffer.length > _limit) {
      _buffer.removeFirst();
    }
  }
}
