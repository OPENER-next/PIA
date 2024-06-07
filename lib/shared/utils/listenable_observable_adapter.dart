import 'package:mobx/mobx.dart' hide Listenable;
import 'package:flutter/foundation.dart';

/// Converts a flutter [Listenable] like [ChangeNotifier] to a mobx trackable/reactive component.

class ListenableObservableAdapter<T extends Listenable> {
  late final Atom _atom;
  final T _listenable;
  final void Function(T listenable, VoidCallback reportChanged) onObserved;
  final void Function(T listenable, VoidCallback reportChanged) onUnobserved;

  ListenableObservableAdapter(this._listenable, {
    this.onObserved = defaultOnObservedCallback,
    this.onUnobserved = defaultOnUnobservedCallback,
  }) {
    _atom = Atom(
      onObserved: _track,
      onUnobserved: _untrack,
    );
  }

  static void defaultOnObservedCallback(Listenable listenable, VoidCallback reportChanged) {
    listenable.addListener(reportChanged);
  }

  static void defaultOnUnobservedCallback(Listenable listenable, VoidCallback reportChanged) {
    listenable.removeListener(reportChanged);
  }

  void _track() => onObserved(_listenable, _atom.reportChanged);

  void _untrack() => onUnobserved(_listenable, _atom.reportChanged);

  T get listenable {
    _atom.reportRead();
    return _listenable;
  }
}
