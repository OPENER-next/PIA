
import 'package:mobx/mobx.dart';

/// This acts like an [Observable] that will clear its value whenever it is consumed.
///
/// The last supplied value is stored till it is consumed or overridden.

class Consumable<T> {
  T? _value;

  final Atom _atom;

  Consumable([this._value]) : _atom = Atom();

  /// Sets or updates the consumable value.

  void stock(T newValue) {
    _atom.reportWrite(newValue, _value, () => _value = newValue);
  }

  /// Deletes the consumable value.

  void empty() {
    _atom.reportWrite(null, _value, () => _value = null);
  }

  bool get isStocked {
    _atom.reportRead();
    return _value != null;
  }

  /// Returns the currently stocked value.
  ///
  /// Returns [null] when no value is stocked.

  T? watch() {
    _atom.reportRead();
    return _value;
  }

  /// Returns the currently stocked value and deletes it.
  ///
  /// Returns [null] when no value is stocked.

  T? consume() {
    _atom.reportRead();
    final returnValue = _value;
    // delete value on consumption
    _value = null;
    return returnValue;
  }
}
