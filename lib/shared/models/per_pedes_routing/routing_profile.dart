part of 'ppr.dart';


/// PPR user specific routing profile definition.

class RoutingProfile {
  final double walkingSpeed;
  final Duration durationLimit;
  final int maxFeatureCostDetourPrimary;
  final int maxFeatureCostDetourSecondary;
  final int maxFeatureCostDetourTertiary;
  final int maxFeatureCostDetourResidential;
  final int maxFeatureCostDetourService;
  final int roundDistance;
  final Duration roundDuration;
  final int roundAccessibility;
  final int maxRoutes;
  final Duration divisionsDuration;
  final int divisionsAccessibility;

  final Set<FeatureCostEntry> featureCosts;

  const RoutingProfile({
    this.walkingSpeed = 1.4,
    this.durationLimit = const Duration(seconds: 3600),
    this.maxFeatureCostDetourPrimary = 300,
    this.maxFeatureCostDetourSecondary = 200,
    this.maxFeatureCostDetourTertiary = 200,
    this.maxFeatureCostDetourResidential = 100,
    this.maxFeatureCostDetourService = 0,
    this.roundDistance = 0,
    this.roundDuration = const Duration(seconds: 30),
    this.roundAccessibility = 5,
    this.maxRoutes = 0,
    this.divisionsDuration = Duration.zero,
    this.divisionsAccessibility = 0,
    this.featureCosts = const {},
  });

  Map<String, dynamic> toJson() => {
    'walking_speed': walkingSpeed,
    'duration_limit': durationLimit.inSeconds,
    'max_feature_cost_detour_primary': maxFeatureCostDetourPrimary,
    'max_feature_cost_detour_secondary': maxFeatureCostDetourSecondary,
    'max_feature_cost_detour_tertiary': maxFeatureCostDetourTertiary,
    'max_feature_cost_detour_residential': maxFeatureCostDetourResidential,
    'max_feature_cost_detour_service': maxFeatureCostDetourService,
    'round_distance': roundDistance,
    'round_duration': roundDuration.inSeconds,
    'round_accessibility': roundAccessibility,
    'max_routes': maxRoutes,
    'divisions_duration': divisionsDuration.inSeconds,
    'divisions_accessibility': divisionsAccessibility,
    for (final entry in featureCosts) entry.type: entry.toJson(),
  };
}

/// Maps a specific feature to a cost definition.
///
/// Equality is only based on the name to filter duplicates via a Set.

abstract class FeatureCostEntry {
  final String type;

  const FeatureCostEntry({
    required this.type,
  });

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureCostEntry &&
      other.type == type;
  }

  @override
  int get hashCode => type.hashCode;
}

/// Maps a specific feature to a cost definition.
///
/// Symbolizes a json entry like `stairs_with_handrail_down_cost	{…}`.

class FeatureCostSingleEntry extends FeatureCostEntry {
  final FeatureCost cost;

  const FeatureCostSingleEntry({
    required super.type,
    required this.cost,
  });

  @override
  Map<String, dynamic> toJson() => cost.toJson();
}

/// Maps specific feature variants to multiple cost definitions.
///
/// Symbolizes a json entry like `crossing_tertiary	{…}`.

class FeatureCostGroupEntry extends FeatureCostEntry {
  final Set<FeatureCostSingleEntry> entries;

  const FeatureCostGroupEntry({
    required super.type,
    required this.entries,
  });

  @override
  Map<String, dynamic> toJson() => {
    for (final entry in entries) entry.type : entry.toJson()
  };
}


/// Per Pedes cost definition.

class FeatureCost {
  final FeatureCostQualifier qualifier;

  final List<Duration> duration;
  final List<int> accessibility;

  final Duration durationPenalty;
  final int accessibilityPenalty;

  const FeatureCost.allowed({
    this.duration = const [],
    this.accessibility = const [],
  }) :
    accessibilityPenalty = 0,
    durationPenalty = Duration.zero,
    qualifier = FeatureCostQualifier.allowed;

  const FeatureCost.penalized({
    this.duration = const [],
    this.accessibility = const [],
    this.accessibilityPenalty = 0,
    this.durationPenalty = Duration.zero,
  }) :
    qualifier = FeatureCostQualifier.penalized;

  const FeatureCost.forbidden() :
    duration = const [],
    accessibility = const [],
    accessibilityPenalty = 0,
    durationPenalty = Duration.zero,
    qualifier = FeatureCostQualifier.forbidden;


  Map<String, dynamic> toJson() => {
    'duration': duration
      .map((duration) => duration.inSeconds)
      .toList(growable: false),
    'duration_penalty': durationPenalty.inSeconds,
    'accessibility': accessibility,
    'accessibility_penalty': accessibilityPenalty,
    'allowed': qualifier.name,
  };
}


enum FeatureCostQualifier {
  forbidden, penalized, allowed;

  const FeatureCostQualifier();

  factory FeatureCostQualifier.fromString(String value) {
    switch(value) {
      case 'forbidden':
      return FeatureCostQualifier.forbidden;
      case 'penalized':
      return FeatureCostQualifier.penalized;
      case 'allowed':
      return FeatureCostQualifier.allowed;
      default:
      throw StateError('Unsopported qualifier $value for FeatureCostQualifier');
    }
  }
}
