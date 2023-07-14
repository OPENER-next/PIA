
/// Represents an indoor level which can also be a decimal number.
///
/// Solves precision and number conversion problems, because a double (1.0) and
/// int (1) have different String representations.

class Level {
  final String _level;

  const Level._(this._level);

  Level.fromString(String level) :
    assert(num.tryParse(level) != null),
    _level = _removeTrailingZeros(level);

  Level.fromNumber(num level) :
    _level = _removeTrailingZeros(level.toString());

  /// The default ground level.

  static const zero = Level._('0');

  static String _removeTrailingZeros(String s)
    => s.replaceFirst(RegExp(r'\.?0+$'), '');

  String toLowerInteger() => asNumber.floor().toString();

  String toUpperInteger() => asNumber.ceil().toString();

  num get asNumber => num.parse(_level);

  @override
  String toString() => _level;

  bool operator >(Level other) => asNumber > other.asNumber;

  bool operator <(Level other) => asNumber < other.asNumber;

  bool operator >=(Level other) => asNumber >= other.asNumber;

  bool operator <=(Level other) => asNumber <= other.asNumber;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Level && other._level == _level;
  }

  @override
  int get hashCode => _level.hashCode;
}
