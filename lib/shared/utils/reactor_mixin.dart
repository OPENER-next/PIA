import 'package:flutter_mvvm_architecture/base.dart';
import 'package:mobx/mobx.dart';

/// Easy way to use reactions in view models with auto cleanup.

mixin Reactor on ViewModel {
  final _reactionDisposers = <ReactionDisposer>[];

  void react<T>(
    T Function(Reaction) fn,
    void Function(T) effect, {
    int? delay,
    bool? fireImmediately,
    bool Function(T?, T?)? equals,
    void Function(Object, Reaction)? onError,
  }) {
    _reactionDisposers.add(reaction(
      fn, effect,
      fireImmediately: fireImmediately,
      delay: delay,
      equals: equals,
      onError: onError,
    ));
  }

  @override
  void dispose() {
    _reactionDisposers.forEach((disposer) => disposer());
    _reactionDisposers.clear();
    super.dispose();
  }
}
