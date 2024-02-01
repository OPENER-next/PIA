import '/shared/models/per_pedes_routing/ppr.dart';


/// Base class to abstract [FeatureCost]s to a single value ranging from 0 to 1.
///
/// - 0 totally inaccessible
/// - (0, 1) translates to an accessibility cost value - the lower the value the higher the cost
/// - 1 totally accessible (no accessibility cost)

sealed class AccessibilityGrade {
  final double value;

  double get maxCost => 50;

  double get cost => (1 - value) * maxCost;

  const AccessibilityGrade(this.value);

  Iterable<MapEntry<String, FeatureCostBase>> toFeatureCostEntries();
}


class AccessibilityGradeStairsUp extends AccessibilityGrade {
  const AccessibilityGradeStairsUp(super.value);
  @override
  Iterable<MapEntry<String, FeatureCost>> toFeatureCostEntries() sync* {
    for (final type in const ['stairs_up_cost', 'stairs_with_handrail_up_cost']) {
      yield MapEntry(
        type,
        cost >= maxCost
          ? const FeatureCost.forbidden()
          // stairs with 25 steps and maxCost of 50
          // will have an accessibility cost ranging from 0 to 75
          // depending on the cost factor [50÷(50÷3)×25 = 75 | 0÷(50÷3)×25 = 75]
          : FeatureCost.allowed(
            accessibility: [0, cost / (maxCost / 3), 0],
          ),
      );
    }
  }
}

class AccessibilityGradeStairsDown extends AccessibilityGrade {
  const AccessibilityGradeStairsDown(super.value);
  @override
  Iterable<MapEntry<String, FeatureCost>> toFeatureCostEntries() sync* {
    for (final type in const ['stairs_down_cost', 'stairs_with_handrail_down_cost']) {
      yield MapEntry(
        type,
        cost >= maxCost
          ? const FeatureCost.forbidden()
          : FeatureCost.allowed(
            accessibility: [0, cost / (maxCost / 3), 0],
          ),
      );
    }
  }
}

class AccessibilityGradeEscalator extends AccessibilityGrade {
  const AccessibilityGradeEscalator(super.value);
  @override
  Iterable<MapEntry<String, FeatureCost>> toFeatureCostEntries() sync* {
    yield MapEntry(
      'escalator_cost',
      cost >= maxCost
        ? const FeatureCost.forbidden()
        : FeatureCost.allowed(
          accessibility: [cost, 0, 0],
        ),
    );
  }
}

class AccessibilityGradeMovingWalkway extends AccessibilityGrade {
  const AccessibilityGradeMovingWalkway(super.value);
  @override
  Iterable<MapEntry<String, FeatureCost>> toFeatureCostEntries() sync* {
    yield MapEntry(
      'moving_walkway_cost',
      cost >= maxCost
        ? const FeatureCost.forbidden()
        : FeatureCost.allowed(
          accessibility: [cost, 0, 0],
        ),
    );
  }
}

class AccessibilityGradeElevator extends AccessibilityGrade {
  const AccessibilityGradeElevator(super.value);
  @override
  Iterable<MapEntry<String, FeatureCost>> toFeatureCostEntries() sync* {
    yield MapEntry(
      'elevator_cost',
      cost >= maxCost
        ? const FeatureCost.forbidden()
        : FeatureCost.allowed(
          accessibility: [cost, 0, 0],
          duration: const [Duration(minutes: 1), Duration.zero, Duration.zero]
        ),
    );
  }
}

class AccessibilityGradeManualDoor extends AccessibilityGrade {
  const AccessibilityGradeManualDoor(super.value);
  @override
  Iterable<MapEntry<String, FeatureCostGroup>> toFeatureCostEntries() sync* {
    yield MapEntry('door', FeatureCostGroup({
      for (final type in const ['hinged', 'sliding', 'folding', 'revolving', 'yes'])
        type: cost >= maxCost
          ? const FeatureCost.forbidden()
          : FeatureCost.allowed(
            accessibility: [cost, 0, 0],
          ),
      // set as universally inaccessible
      'trapdoor': const FeatureCost.forbidden(),
      'overhead': const FeatureCost.forbidden(),
      // set as universally accessible
      'no': const FeatureCost.allowed(
        duration: [Duration.zero, Duration.zero, Duration.zero],
        accessibility: [0, 0, 0],
      ),
    }));

    yield MapEntry('automatic_door', FeatureCostGroup({
      'no': cost >= maxCost
        ? const FeatureCost.forbidden()
        : FeatureCost.allowed(
          accessibility: [cost, 0, 0],
        ),
    }));
  }
}

class AccessibilityGradeAutomaticRevolvingDoor extends AccessibilityGrade {
  const AccessibilityGradeAutomaticRevolvingDoor(super.value);
  @override
  Iterable<MapEntry<String, FeatureCostGroup>> toFeatureCostEntries() sync* {
    yield MapEntry('automatic_door', FeatureCostGroup({
      // Not perfect as there can also be automatic revolving doors with motion sensors
      // or even buttons ("yes" would also have to be included here)
      // but I cannot know whether the door type is revolving or not
      for (final type in const ['continuous', 'slowdown_button'])
        type: cost >= maxCost
          ? const FeatureCost.forbidden()
          : FeatureCost.allowed(
            accessibility: [cost, 0, 0],
          ),
      })
    );
  }
}

class AccessibilityGradeButtonDoor extends AccessibilityGrade {
  const AccessibilityGradeButtonDoor(super.value);
  @override
  Iterable<MapEntry<String, FeatureCostGroup>> toFeatureCostEntries() sync* {
    yield MapEntry('automatic_door', FeatureCostGroup({
      for (final type in const ['button', 'yes'])
        type: cost >= maxCost
          ? const FeatureCost.forbidden()
          : FeatureCost.allowed(
            accessibility: [cost, 0, 0],
          ),
      })
    );
  }
}

class AccessibilityGradeSensorDoor extends AccessibilityGrade {
  const AccessibilityGradeSensorDoor(super.value);
  @override
  Iterable<MapEntry<String, FeatureCostGroup>> toFeatureCostEntries() sync* {
    yield MapEntry('automatic_door', FeatureCostGroup({
      for (final type in const ['motion', 'floor'])
        type: cost >= maxCost
          ? const FeatureCost.forbidden()
          : FeatureCost.allowed(
            accessibility: [cost, 0, 0],
          ),
      })
    );
  }
}

class AccessibilityGradeUnmarkedCrossing extends _AccessibilityGradeCrossing {
  const AccessibilityGradeUnmarkedCrossing(super.value);
  @override
  String get _type => 'unmarked';
  @override
  Duration get _crossingPrimaryDuration => const Duration(seconds: 60);
  @override
  Duration get _crossingSecondaryDuration => const Duration(seconds: 20);
  @override
  Duration get _crossingTertiaryDuration => const Duration(seconds: 10);
  @override
  Duration get _crossingResidentialDuration => const Duration(seconds: 5);
  @override
  Duration get _crossingServiceDuration => Duration.zero;
}

class AccessibilityGradeMarkedCrossing extends _AccessibilityGradeCrossing {
  const AccessibilityGradeMarkedCrossing(super.value);
  @override
  String get _type => 'marked';
  @override
  Duration get _crossingPrimaryDuration => const Duration(seconds: 30);
  @override
  Duration get _crossingSecondaryDuration => const Duration(seconds: 20);
  @override
  Duration get _crossingTertiaryDuration => const Duration(seconds: 10);
  @override
  Duration get _crossingResidentialDuration => Duration.zero;
  @override
  Duration get _crossingServiceDuration => Duration.zero;
}

class AccessibilityGradeIslandCrossing extends _AccessibilityGradeCrossing {
  const AccessibilityGradeIslandCrossing(super.value);
  @override
  String get _type => 'island';
  @override
  Duration get _crossingPrimaryDuration => const Duration(seconds: 40);
  @override
  Duration get _crossingSecondaryDuration => const Duration(seconds: 25);
  @override
  Duration get _crossingTertiaryDuration => const Duration(seconds: 10);
  @override
  Duration get _crossingResidentialDuration => Duration.zero;
  @override
  Duration get _crossingServiceDuration => Duration.zero;
}

class AccessibilityGradeSignalsCrossing extends _AccessibilityGradeCrossing {
  const AccessibilityGradeSignalsCrossing(super.value);
  @override
  String get _type => 'signals';
  @override
  Duration get _crossingPrimaryDuration => const Duration(seconds: 100);
  @override
  Duration get _crossingSecondaryDuration => const Duration(seconds: 45);
  @override
  Duration get _crossingTertiaryDuration => const Duration(seconds: 40);
  @override
  Duration get _crossingResidentialDuration => const Duration(seconds: 30);
  @override
  Duration get _crossingServiceDuration => const Duration(seconds: 10);
}

class AccessibilityGradeBlindSignalsCrossing extends _AccessibilityGradeCrossing {
  const AccessibilityGradeBlindSignalsCrossing(super.value);
  @override
  String get _type => 'blind_signals';
  @override
  Duration get _crossingPrimaryDuration => const Duration(seconds: 100);
  @override
  Duration get _crossingSecondaryDuration => const Duration(seconds: 45);
  @override
  Duration get _crossingTertiaryDuration => const Duration(seconds: 40);
  @override
  Duration get _crossingResidentialDuration => const Duration(seconds: 30);
  @override
  Duration get _crossingServiceDuration => const Duration(seconds: 10);
}

sealed class _AccessibilityGradeCrossing extends AccessibilityGrade {
  const _AccessibilityGradeCrossing(super.value);

  String get _type;

  Duration get _crossingPrimaryDuration;
  Duration get _crossingSecondaryDuration;
  Duration get _crossingTertiaryDuration;
  Duration get _crossingResidentialDuration;
  Duration get _crossingServiceDuration;

  @override
  Iterable<MapEntry<String, FeatureCostGroup>> toFeatureCostEntries() sync* {
    for (final entry in [
      ('crossing_primary', _crossingPrimaryDuration),
      ('crossing_secondary', _crossingSecondaryDuration),
      ('crossing_tertiary', _crossingTertiaryDuration),
      ('crossing_residential', _crossingResidentialDuration),
      ('crossing_service', _crossingServiceDuration),
    ]) {
      yield MapEntry(entry.$1, FeatureCostGroup({
        _type: cost >= maxCost
          ? const FeatureCost.forbidden()
          : FeatureCost.allowed(
            accessibility: [cost, 0, 0],
            duration: [entry.$2, Duration.zero, Duration.zero]
          ),
        }),
      );
    }
  }
}
