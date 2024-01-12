part of 'ppr.dart';


/// PPR user specific routing profile definition.

class RoutingProfile {
  final double walkingSpeed;
  final double minRequiredWidth;
  final int minAllowedIncline;
  final int maxAllowedIncline;
  final bool wheelchair;
  final bool stroller;
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

  final Map<String, FeatureCostBase> featureCosts;

  const RoutingProfile({
    this.walkingSpeed = 1.4,
    this.minRequiredWidth = 0,
    this.minAllowedIncline = -127,
    this.maxAllowedIncline = 127,
    this.wheelchair = false,
    this.stroller = false,
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
    'min_required_width': minRequiredWidth,
    'min_allowed_incline': minAllowedIncline,
    'max_allowed_incline': maxAllowedIncline,
    'wheelchair': wheelchair,
    'stroller': stroller,
    'round_distance': roundDistance,
    'round_duration': roundDuration.inSeconds,
    'round_accessibility': roundAccessibility,
    'max_routes': maxRoutes,
    'divisions_duration': divisionsDuration.inSeconds,
    'divisions_accessibility': divisionsAccessibility,
    for (final entry in featureCosts.entries) entry.key: entry.value.toJson(),
  };
}


/// Per Pedes cost definition.

abstract class FeatureCostBase {
  Map<String, dynamic> toJson();
}

/// A specific feature cost definition.
///
/// Symbolizes a json entry like `stairs_with_handrail_down_cost	{…}`.

class FeatureCost implements FeatureCostBase {
  final FeatureCostQualifier qualifier;

  final List<Duration> duration;
  final List<double> accessibility;

  final Duration durationPenalty;
  final double accessibilityPenalty;

  const FeatureCost.allowed({
    this.duration = const [Duration.zero, Duration.zero, Duration.zero],
    this.accessibility = const [0, 0, 0],
  }) :
    accessibilityPenalty = 0,
    durationPenalty = Duration.zero,
    qualifier = FeatureCostQualifier.allowed;

  const FeatureCost.penalized({
    this.duration = const [Duration.zero, Duration.zero, Duration.zero],
    this.accessibility = const [0, 0, 0],
    this.accessibilityPenalty = 0,
    this.durationPenalty = Duration.zero,
  }) :
    qualifier = FeatureCostQualifier.penalized;

  const FeatureCost.forbidden() :
    duration = const [Duration.zero, Duration.zero, Duration.zero],
    accessibility = const [0, 0, 0],
    accessibilityPenalty = 0,
    durationPenalty = Duration.zero,
    qualifier = FeatureCostQualifier.forbidden;


  @override
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

/// Maps specific feature variants to multiple cost definitions.
///
/// Symbolizes a json entry like `crossing_tertiary	{…}`.

class FeatureCostGroup implements FeatureCostBase {
  final Map<String, FeatureCost> features;

  const FeatureCostGroup(this.features);

  @override
  Map<String, dynamic> toJson() => {
    for (final entry in features.entries) entry.key : entry.value.toJson()
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
      throw StateError('Unsupported qualifier $value for FeatureCostQualifier');
    }
  }
}
