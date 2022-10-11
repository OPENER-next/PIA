import 'dart:collection';

import 'package:flutter/foundation.dart';


class IndoorLevelController extends ChangeNotifier {

  final SplayTreeMap<num, String> _levels;

  num _level;

  IndoorLevelController({
    Map<num, String> levels = const {},
    num initialLevel = 0,
  }) :
    _levels = SplayTreeMap.of(levels),
    _level = initialLevel;


  num get level => _level;

  /// Changes the level to the given level.
  ///
  /// This will return false if the level is not present in the [levels] map.
  /// Otherwise returns true.

  bool changeLevel(num level) {
    if (!_levels.containsKey(level)) {
      return false;
    }
    if (level != _level) {
      _level = level;
      notifyListeners();
    }
    return true;
  }

  /// Changes the level to the next level above the current one if any.
  ///
  /// Returns the new level which might be unchanged if there isn't any level above.

  num levelUp() {
    final newLevel = _levels.firstKeyAfter(_level);
    if (newLevel != null) {
      changeLevel(newLevel);
    }
    return _level;
  }

  /// Changes the level to the next level below the current one if any.
  ///
  /// Returns the new level which might be unchanged if there isn't any level below.

  num levelDown() {
    final newLevel = _levels.lastKeyBefore(_level);
    if (newLevel != null) {
      changeLevel(newLevel);
    }
    return _level;
  }


  /// Levels are automatically sorted by their key.

  UnmodifiableMapView<num, String> get levels => UnmodifiableMapView(_levels);

  set levels(Map<num, String> levels) {
    _levels..clear()..addAll(levels);
    _adjustLevel();
    notifyListeners();
  }

  void addLevel(num level, String label) {
    _levels[level] = label;
    notifyListeners();
  }

  /// Removes a given level.
  ///
  /// Returns true if the level was present and removed.

  bool removeLevel(num level) {
    final isRemoved = _levels.remove(level) != null;
    if (isRemoved) {
      _adjustLevel();
      notifyListeners();
    }
    return isRemoved;
  }

  /// Adjust the level value to match a value in the level map when possible.
  /// Defaults to 0 when the level map is empty.

  void _adjustLevel() {
    if (!levels.containsKey(_level)) {
      if (levels.containsKey(0)) {
        _level = 0;
      }
      else {
        _level = _levels.lastKeyBefore(_level)
          ?? _levels.firstKeyAfter(_level)
          ?? _levels.lastKey()
          ?? 0;
      }
    }
  }
}
