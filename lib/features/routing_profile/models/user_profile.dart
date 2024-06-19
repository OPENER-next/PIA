
import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';

import '/shared/models/per_pedes_routing/ppr.dart';
import 'accessibility_grades.dart';
import 'user_profile_presets.dart';

/// Holds any routing relevant preferences.
///
/// All properties are observable.

class UserProfile {
  final Observable<double> _speed;
  final Observable<double> _minRequiredWidth;
  final Observable<int> _maxDecline;
  final Observable<int> _maxIncline;

  final Observable<AccessibilityGradeStairsUp> _stairsUp;
  final Observable<AccessibilityGradeStairsDown> _stairsDown;
  final Observable<AccessibilityGradeEscalator> _escalator;
  final Observable<AccessibilityGradeMovingWalkway> _movingWalkway;
  final Observable<AccessibilityGradeElevator> _elevator;

  final Observable<AccessibilityGradeManualDoor> _manualDoor;
  final Observable<AccessibilityGradeAutomaticRevolvingDoor> _automaticRevolvingDoor;
  final Observable<AccessibilityGradeButtonDoor> _buttonDoor;
  final Observable<AccessibilityGradeSensorDoor> _sensorDoor;

  final Observable<AccessibilityGradeUnmarkedCrossing> _unmarkedCrossing;
  final Observable<AccessibilityGradeMarkedCrossing> _markedCrossing;
  final Observable<AccessibilityGradeIslandCrossing> _islandCrossing;
  final Observable<AccessibilityGradeSignalsCrossing> _signalsCrossing;
  final Observable<AccessibilityGradeBlindSignalsCrossing> _blindSignalsCrossing;

  double get speed => _speed.value;
  set speed (double value) => _speed.value = value;
  double get minRequiredWidth => _minRequiredWidth.value;
  set minRequiredWidth (double value) => _minRequiredWidth.value = value;
  int get maxDecline => _maxDecline.value;
  set maxDecline (int value) => _maxDecline.value = value;
  int get maxIncline => _maxIncline.value;
  set maxIncline (int value) => _maxIncline.value = value;

  AccessibilityGradeStairsUp get stairsUp => _stairsUp.value;
  set stairsUp (AccessibilityGradeStairsUp value) => _stairsUp.value = value;
  AccessibilityGradeStairsDown get stairsDown => _stairsDown.value;
  set stairsDown (AccessibilityGradeStairsDown value) => _stairsDown.value = value;
  AccessibilityGradeEscalator get escalator => _escalator.value;
  set escalator (AccessibilityGradeEscalator value) => _escalator.value = value;
  AccessibilityGradeMovingWalkway get movingWalkway => _movingWalkway.value;
  set movingWalkway (AccessibilityGradeMovingWalkway value) => _movingWalkway.value = value;
  AccessibilityGradeElevator get elevator => _elevator.value;
  set elevator (AccessibilityGradeElevator value) => _elevator.value = value;

  AccessibilityGradeManualDoor get manualDoor => _manualDoor.value;
  set manualDoor (AccessibilityGradeManualDoor value) => _manualDoor.value = value;
  AccessibilityGradeAutomaticRevolvingDoor get automaticRevolvingDoor => _automaticRevolvingDoor.value;
  set automaticRevolvingDoor (AccessibilityGradeAutomaticRevolvingDoor value) => _automaticRevolvingDoor.value = value;
  AccessibilityGradeButtonDoor get buttonDoor => _buttonDoor.value;
  set buttonDoor (AccessibilityGradeButtonDoor value) => _buttonDoor.value = value;
  AccessibilityGradeSensorDoor get sensorDoor => _sensorDoor.value;
  set sensorDoor (AccessibilityGradeSensorDoor value) => _sensorDoor.value = value;

  AccessibilityGradeUnmarkedCrossing get unmarkedCrossing => _unmarkedCrossing.value;
  set unmarkedCrossing (AccessibilityGradeUnmarkedCrossing value) => _unmarkedCrossing.value = value;
  AccessibilityGradeMarkedCrossing get markedCrossing => _markedCrossing.value;
  set markedCrossing (AccessibilityGradeMarkedCrossing value) => _markedCrossing.value = value;
  AccessibilityGradeIslandCrossing get islandCrossing => _islandCrossing.value;
  set islandCrossing (AccessibilityGradeIslandCrossing value) => _islandCrossing.value = value;
  AccessibilityGradeSignalsCrossing get signalsCrossing => _signalsCrossing.value;
  set signalsCrossing (AccessibilityGradeSignalsCrossing value) => _signalsCrossing.value = value;
  AccessibilityGradeBlindSignalsCrossing get blindSignalsCrossing => _blindSignalsCrossing.value;
  set blindSignalsCrossing (AccessibilityGradeBlindSignalsCrossing value) => _blindSignalsCrossing.value = value;

  /// Create a new user profile and populate the preferences with the properties defined the the preset.

  UserProfile.fromPreset(UserProfilePreset preset) :
    _speed = Observable(preset.speed),
    _minRequiredWidth = Observable(preset.minRequiredWidth),
    _maxDecline = Observable(preset.maxDecline),
    _maxIncline = Observable(preset.maxIncline),

    _stairsUp = Observable(preset.stairsUp),
    _stairsDown = Observable(preset.stairsDown),
    _escalator = Observable(preset.escalator),
    _movingWalkway = Observable(preset.movingWalkway),
    _elevator = Observable(preset.elevator),

    _manualDoor = Observable(preset.manualDoor),
    _automaticRevolvingDoor = Observable(preset.automaticRevolvingDoor),
    _buttonDoor = Observable(preset.buttonDoor),
    _sensorDoor = Observable(preset.sensorDoor),

    _unmarkedCrossing = Observable(preset.unmarkedCrossing),
    _markedCrossing = Observable(preset.markedCrossing),
    _islandCrossing = Observable(preset.islandCrossing),
    _signalsCrossing = Observable(preset.signalsCrossing),
    _blindSignalsCrossing = Observable(preset.blindSignalsCrossing);

  /// Overrides the current preferences with the one defined in the given preset.

  void applyPreset(UserProfilePreset preset) {
    speed = preset.speed;
    minRequiredWidth = preset.minRequiredWidth;
    maxDecline = preset.maxDecline;
    maxIncline = preset.maxIncline;

    stairsUp = preset.stairsUp;
    stairsDown = preset.stairsDown;
    escalator = preset.escalator;
    movingWalkway = preset.movingWalkway;
    elevator = preset.elevator;

    manualDoor = preset.manualDoor;
    automaticRevolvingDoor = preset.automaticRevolvingDoor;
    buttonDoor = preset.buttonDoor;
    sensorDoor = preset.sensorDoor;

    unmarkedCrossing = preset.unmarkedCrossing;
    markedCrossing = preset.markedCrossing;
    islandCrossing = preset.islandCrossing;
    signalsCrossing = preset.signalsCrossing;
    blindSignalsCrossing = preset.blindSignalsCrossing;
  }

  RoutingProfile toRoutingProfile() {
    final costs = FeatureCostMapping({
      'crossing_rail': const FeatureCost.allowed(
        duration: [Duration(seconds: 50)]
      ),
      'crossing_tram': const FeatureCost.allowed(
        duration: [Duration(seconds: 20)]
      ),
      'cycle_barrier_cost': const FeatureCost.allowed(
        duration: [Duration(seconds: 8)]
      ),
      'elevation_up_cost': const FeatureCost.allowed(),
      'elevation_down_cost': const FeatureCost.allowed(),
    })
      ..apply(stairsUp)
      ..apply(stairsDown)
      ..apply(escalator)
      ..apply(movingWalkway)
      ..apply(elevator)
      ..apply(manualDoor)
      ..apply(automaticRevolvingDoor)
      ..apply(buttonDoor)
      ..apply(sensorDoor)
      ..apply(unmarkedCrossing)
      ..apply(markedCrossing)
      ..apply(islandCrossing)
      ..apply(signalsCrossing)
      ..apply(blindSignalsCrossing);

    return RoutingProfile(
      // convert to meters per second
      walkingSpeed: speed * (5/18),
      minRequiredWidth: minRequiredWidth,
      minAllowedIncline: maxDecline,
      maxAllowedIncline: maxIncline,
      featureCosts: costs,
      roundAccessibility: 10,
    );
  }
}

class FeatureCostMapping extends DelegatingMap<String, FeatureCostBase> {
  FeatureCostMapping([Map<String, FeatureCostBase>? map]) : super(map ?? {});

  void apply(AccessibilityGrade grade) {
    final featureCostEntries = grade.toFeatureCostEntries();
    for (final featureCostEntry in featureCostEntries) {
      final existingGroup = this[featureCostEntry.key];
      final newFeatureCost = featureCostEntry.value;
      // merge new groups into existing groups
      if (existingGroup is FeatureCostGroup && newFeatureCost is FeatureCostGroup) {
        existingGroup.features.addEntries(newFeatureCost.features.entries);
      }
      else {
        this[featureCostEntry.key] = newFeatureCost;
      }
    }
  }
}
