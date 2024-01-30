import 'accessibility_grades.dart';

class UserProfilePreset {
  final double speed;
  final double minRequiredWidth;
  final int maxDecline;
  final int maxIncline;

  final AccessibilityGradeStairsUp stairsUp;
  final AccessibilityGradeStairsDown stairsDown;
  final AccessibilityGradeEscalator escalator;
  final AccessibilityGradeMovingWalkway movingWalkway;
  final AccessibilityGradeElevator elevator;

  final AccessibilityGradeManualDoor manualDoor;
  final AccessibilityGradeAutomaticRevolvingDoor automaticRevolvingDoor;
  final AccessibilityGradeButtonDoor buttonDoor;
  final AccessibilityGradeSensorDoor sensorDoor;

  final AccessibilityGradeUnmarkedCrossing unmarkedCrossing;
  final AccessibilityGradeMarkedCrossing markedCrossing;
  final AccessibilityGradeIslandCrossing islandCrossing;
  final AccessibilityGradeSignalsCrossing signalsCrossing;
  final AccessibilityGradeBlindSignalsCrossing blindSignalsCrossing;

  const UserProfilePreset({
    required this.speed,
    required this.minRequiredWidth,
    required this.maxDecline,
    required this.maxIncline,
    required this.stairsUp,
    required this.stairsDown,
    required this.escalator,
    required this.movingWalkway,
    required this.elevator,
    required this.manualDoor,
    required this.automaticRevolvingDoor,
    required this.buttonDoor,
    required this.sensorDoor,
    required this.unmarkedCrossing,
    required this.markedCrossing,
    required this.islandCrossing,
    required this.signalsCrossing,
    required this.blindSignalsCrossing,
  });
}

abstract class UserProfilePresets {
  static const unrestricted = UserProfilePreset(
    speed: 5,
    minRequiredWidth: 0.5,
    maxDecline: -15,
    maxIncline: 15,
    stairsUp: AccessibilityGradeStairsUp(1),
    stairsDown: AccessibilityGradeStairsDown(1),
    escalator: AccessibilityGradeEscalator(1),
    movingWalkway: AccessibilityGradeMovingWalkway(1),
    elevator: AccessibilityGradeElevator(1),
    manualDoor: AccessibilityGradeManualDoor(1),
    automaticRevolvingDoor: AccessibilityGradeAutomaticRevolvingDoor(1),
    buttonDoor: AccessibilityGradeButtonDoor(1),
    sensorDoor: AccessibilityGradeSensorDoor(1),
    unmarkedCrossing: AccessibilityGradeUnmarkedCrossing(1),
    markedCrossing: AccessibilityGradeMarkedCrossing(1),
    islandCrossing: AccessibilityGradeIslandCrossing(1),
    signalsCrossing: AccessibilityGradeSignalsCrossing(1),
    blindSignalsCrossing: AccessibilityGradeBlindSignalsCrossing(1),
  );

  static const wheelchair = UserProfilePreset(
    speed: 5,
    minRequiredWidth: 1,
    maxDecline: -10,
    maxIncline: 8,
    stairsUp: AccessibilityGradeStairsUp(0),
    stairsDown: AccessibilityGradeStairsDown(0),
    escalator: AccessibilityGradeEscalator(0),
    movingWalkway: AccessibilityGradeMovingWalkway(1),
    elevator: AccessibilityGradeElevator(1),
    manualDoor: AccessibilityGradeManualDoor(0.2),
    automaticRevolvingDoor: AccessibilityGradeAutomaticRevolvingDoor(0.2),
    buttonDoor: AccessibilityGradeButtonDoor(1),
    sensorDoor: AccessibilityGradeSensorDoor(1),
    unmarkedCrossing: AccessibilityGradeUnmarkedCrossing(0.2),
    markedCrossing: AccessibilityGradeMarkedCrossing(1),
    islandCrossing: AccessibilityGradeIslandCrossing(1),
    signalsCrossing: AccessibilityGradeSignalsCrossing(1),
    blindSignalsCrossing: AccessibilityGradeBlindSignalsCrossing(1),
  );

  static const blind = UserProfilePreset(
    speed: 5,
    minRequiredWidth: 0.5,
    maxDecline: -15,
    maxIncline: 15,
    stairsUp: AccessibilityGradeStairsUp(1),
    stairsDown: AccessibilityGradeStairsDown(0.8),
    escalator: AccessibilityGradeEscalator(1),
    movingWalkway: AccessibilityGradeMovingWalkway(1),
    elevator: AccessibilityGradeElevator(1),
    manualDoor: AccessibilityGradeManualDoor(1),
    automaticRevolvingDoor: AccessibilityGradeAutomaticRevolvingDoor(1),
    buttonDoor: AccessibilityGradeButtonDoor(1),
    sensorDoor: AccessibilityGradeSensorDoor(1),
    unmarkedCrossing: AccessibilityGradeUnmarkedCrossing(0),
    markedCrossing: AccessibilityGradeMarkedCrossing(0),
    islandCrossing: AccessibilityGradeIslandCrossing(0),
    signalsCrossing: AccessibilityGradeSignalsCrossing(0),
    blindSignalsCrossing: AccessibilityGradeBlindSignalsCrossing(1),
  );

  static const guideDog = UserProfilePreset(
    speed: 5,
    minRequiredWidth: 0.5,
    maxDecline: -15,
    maxIncline: 15,
    stairsUp: AccessibilityGradeStairsUp(1),
    stairsDown: AccessibilityGradeStairsDown(1),
    escalator: AccessibilityGradeEscalator(0.2),
    movingWalkway: AccessibilityGradeMovingWalkway(1),
    elevator: AccessibilityGradeElevator(1),
    manualDoor: AccessibilityGradeManualDoor(1),
    automaticRevolvingDoor: AccessibilityGradeAutomaticRevolvingDoor(1),
    buttonDoor: AccessibilityGradeButtonDoor(1),
    sensorDoor: AccessibilityGradeSensorDoor(1),
    unmarkedCrossing: AccessibilityGradeUnmarkedCrossing(0),
    markedCrossing: AccessibilityGradeMarkedCrossing(0.5),
    islandCrossing: AccessibilityGradeIslandCrossing(0.5),
    signalsCrossing: AccessibilityGradeSignalsCrossing(0.8),
    blindSignalsCrossing: AccessibilityGradeBlindSignalsCrossing(1),
  );

  static const assistWalker = UserProfilePreset(
    speed: 4,
    minRequiredWidth: 0.6,
    maxDecline: -8,
    maxIncline: 8,
    stairsUp: AccessibilityGradeStairsUp(0),
    stairsDown: AccessibilityGradeStairsDown(0),
    escalator: AccessibilityGradeEscalator(0.8),
    movingWalkway: AccessibilityGradeMovingWalkway(1),
    elevator: AccessibilityGradeElevator(1),
    manualDoor: AccessibilityGradeManualDoor(0.5),
    automaticRevolvingDoor: AccessibilityGradeAutomaticRevolvingDoor(0.8),
    buttonDoor: AccessibilityGradeButtonDoor(1),
    sensorDoor: AccessibilityGradeSensorDoor(1),
    unmarkedCrossing: AccessibilityGradeUnmarkedCrossing(1),
    markedCrossing: AccessibilityGradeMarkedCrossing(1),
    islandCrossing: AccessibilityGradeIslandCrossing(1),
    signalsCrossing: AccessibilityGradeSignalsCrossing(1),
    blindSignalsCrossing: AccessibilityGradeBlindSignalsCrossing(1),
  );

  static const buggy = UserProfilePreset(
    speed: 4.5,
    minRequiredWidth: 0.75,
    maxDecline: -10,
    maxIncline: 10,
    stairsUp: AccessibilityGradeStairsUp(0),
    stairsDown: AccessibilityGradeStairsDown(0.2),
    escalator: AccessibilityGradeEscalator(0.8),
    movingWalkway: AccessibilityGradeMovingWalkway(1),
    elevator: AccessibilityGradeElevator(1),
    manualDoor: AccessibilityGradeManualDoor(0.8),
    automaticRevolvingDoor: AccessibilityGradeAutomaticRevolvingDoor(0.2),
    buttonDoor: AccessibilityGradeButtonDoor(1),
    sensorDoor: AccessibilityGradeSensorDoor(1),
    unmarkedCrossing: AccessibilityGradeUnmarkedCrossing(1),
    markedCrossing: AccessibilityGradeMarkedCrossing(1),
    islandCrossing: AccessibilityGradeIslandCrossing(1),
    signalsCrossing: AccessibilityGradeSignalsCrossing(1),
    blindSignalsCrossing: AccessibilityGradeBlindSignalsCrossing(1),
  );

  static const bicycle = UserProfilePreset(
    speed: 5,
    minRequiredWidth: 0.75,
    maxDecline: -15,
    maxIncline: 15,
    stairsUp: AccessibilityGradeStairsUp(0.2),
    stairsDown: AccessibilityGradeStairsDown(0.8),
    escalator: AccessibilityGradeEscalator(0.8),
    movingWalkway: AccessibilityGradeMovingWalkway(1),
    elevator: AccessibilityGradeElevator(1),
    manualDoor: AccessibilityGradeManualDoor(0.2),
    automaticRevolvingDoor: AccessibilityGradeAutomaticRevolvingDoor(0),
    buttonDoor: AccessibilityGradeButtonDoor(1),
    sensorDoor: AccessibilityGradeSensorDoor(1),
    unmarkedCrossing: AccessibilityGradeUnmarkedCrossing(1),
    markedCrossing: AccessibilityGradeMarkedCrossing(1),
    islandCrossing: AccessibilityGradeIslandCrossing(1),
    signalsCrossing: AccessibilityGradeSignalsCrossing(1),
    blindSignalsCrossing: AccessibilityGradeBlindSignalsCrossing(1),
  );

  static const luggage = UserProfilePreset(
    speed: 4.5,
    minRequiredWidth: 0.6,
    maxDecline: -15,
    maxIncline: 15,
    stairsUp: AccessibilityGradeStairsUp(0.5),
    stairsDown: AccessibilityGradeStairsDown(0.8),
    escalator: AccessibilityGradeEscalator(1),
    movingWalkway: AccessibilityGradeMovingWalkway(1),
    elevator: AccessibilityGradeElevator(1),
    manualDoor: AccessibilityGradeManualDoor(0.5),
    automaticRevolvingDoor: AccessibilityGradeAutomaticRevolvingDoor(1),
    buttonDoor: AccessibilityGradeButtonDoor(1),
    sensorDoor: AccessibilityGradeSensorDoor(1),
    unmarkedCrossing: AccessibilityGradeUnmarkedCrossing(1),
    markedCrossing: AccessibilityGradeMarkedCrossing(1),
    islandCrossing: AccessibilityGradeIslandCrossing(1),
    signalsCrossing: AccessibilityGradeSignalsCrossing(1),
    blindSignalsCrossing: AccessibilityGradeBlindSignalsCrossing(1),
  );
}
