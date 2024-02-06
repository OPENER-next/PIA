import 'package:mobx/mobx.dart' hide Listenable;
import 'package:flutter/foundation.dart';

/// Converts a flutter [Listenable] like [ChangeNotifier] to a mobx trackable/reactive component.

class ListenableObservableAdapter<T extends Listenable> {
  late final Atom _atom;
  final T _listenable;

  ListenableObservableAdapter(this._listenable) {
    _atom = Atom(
      onObserved: _track,
      onUnobserved: _untrack,
    );
  }

  void _track() =>_listenable.addListener(_atom.reportChanged);

  void _untrack() => _listenable.removeListener(_atom.reportChanged);

  T get listenable {
    _atom.reportRead();
    return _listenable;
  }
}
