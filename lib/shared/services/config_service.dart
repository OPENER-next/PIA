import 'dart:async';

import 'package:flutter_mvvm_architecture/base.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobx/mobx.dart';

import '../../features/routing_profile/models/accessibility_grades.dart';
import '../../features/routing_profile/models/user_profile.dart';
import '../../features/routing_profile/models/user_profile_presets.dart';

/// Persistently stores user data whenever it changes and re-stores it on launch.

class ConfigService extends Service with Disposable {

  final userProfile = UserProfile.fromPreset(UserProfilePresets.unrestricted);

  ConfigService(this._storage) {
    _register('speed',
      (v) => userProfile.speed = v,
      (_) => userProfile.speed,
    );
    _register('min_required_width',
      (v) => userProfile.minRequiredWidth = v,
      (_) => userProfile.minRequiredWidth,
    );
    _register('max_decline',
      (v) => userProfile.maxIncline = v,
      (_) => userProfile.maxIncline,
    );
    _register('max_incline',
      (v) => userProfile.maxDecline = v,
      (_) => userProfile.maxDecline,
    );

    _register('stairs_up',
      (v) => userProfile.stairsUp = AccessibilityGradeStairsUp(v),
      (_) => userProfile.stairsUp.value,
    );
    _register('stairs_down',
      (v) => userProfile.stairsDown = AccessibilityGradeStairsDown(v),
      (_) => userProfile.stairsDown.value,
    );
    _register('escalator',
      (v) => userProfile.escalator = AccessibilityGradeEscalator(v),
      (_) => userProfile.escalator.value,
    );
    _register('movin_walkway',
      (v) => userProfile.movingWalkway = AccessibilityGradeMovingWalkway(v),
      (_) => userProfile.movingWalkway.value,
    );
    _register('elevator',
      (v) => userProfile.elevator = AccessibilityGradeElevator(v),
      (_) => userProfile.elevator.value,
    );

    _register('unmarked_crossing',
      (v) => userProfile.unmarkedCrossing = AccessibilityGradeUnmarkedCrossing(v),
      (_) => userProfile.unmarkedCrossing.value,
    );
    _register('marked_crossing',
      (v) => userProfile.markedCrossing = AccessibilityGradeMarkedCrossing(v),
      (_) => userProfile.markedCrossing.value,
    );
    _register('island_crossing',
      (v) => userProfile.islandCrossing = AccessibilityGradeIslandCrossing(v),
      (_) => userProfile.islandCrossing.value,
    );
    _register('signals_crossing',
      (v) => userProfile.signalsCrossing = AccessibilityGradeSignalsCrossing(v),
      (_) => userProfile.signalsCrossing.value,
    );
    _register('blind_signals_crossing',
      (v) => userProfile.blindSignalsCrossing = AccessibilityGradeBlindSignalsCrossing(v),
      (_) => userProfile.blindSignalsCrossing.value,
    );

    _register('manual_door',
      (v) => userProfile.manualDoor = AccessibilityGradeManualDoor(v),
      (_) => userProfile.manualDoor.value,
    );
    _register('automatic_revolving_door',
      (v) => userProfile.automaticRevolvingDoor = AccessibilityGradeAutomaticRevolvingDoor(v),
      (_) => userProfile.automaticRevolvingDoor.value,
    );
    _register('button_door',
      (v) => userProfile.buttonDoor = AccessibilityGradeButtonDoor(v),
      (_) => userProfile.buttonDoor.value,
    );
    _register('sensor_door',
      (v) => userProfile.sensorDoor = AccessibilityGradeSensorDoor(v),
      (_) => userProfile.sensorDoor.value,
    );
  }

  final Box _storage;
  final _reactionDisposer = <ReactionDisposer>[];

  /// Load initial data and auto store data on changes.

  void _register<T>(String key, void Function(T) cbInit, T Function(Reaction) cbTrack) {
    final initialValue = _storage.get(key);
    if (initialValue != null) {
      cbInit(initialValue);
    }
    _reactionDisposer.add(
      reaction<T>(cbTrack, (v) =>  _storage.put(key, v)),
    );
  }

  @override
  FutureOr onDispose() {
    _reactionDisposer.forEach((cb) => cb());
  }
}
