part of 'ppr.dart';

/// PPR response for a requested [RoutingRequest].

class RoutingResponse {
  final List<Route> routes;

  /// Will be empty if the [RoutingRequest] did not set `includeStatistics` to `true`.

  final Map<String, dynamic> statistics;

  RoutingResponse.fromJson(Map<String, dynamic> json) :
    routes = json['routes']
      .map<Route>((item) => Route.fromJson(item))
      .toList(growable: false),
    statistics = json['statistics'];
}


class Route {
  /// Will be `null` if the [RoutingRequest] did not set `includeInfos` to `true`.

  final RouteDetails? details;

  /// Will be empty if the [RoutingRequest] did not set `includeFullPath` to `true`.

  final List<Position> path;

  /// Will be empty if the [RoutingRequest] did not set `includeSteps` to `true`.

  final List<RoutingStep> steps;

  /// Will be empty if the [RoutingRequest] did not set `includeEdges` to `true`.

  final List<RoutingEdge> edges;

  Route.fromJson(Map<String, dynamic> json) :
  // check if one property of the route details is set
  // if set assume other properties are set as well
    details = json['distance'] != null
      ? RouteDetails.fromJson(json)
      : null,
    path = json['path']
      ?.map<Position>((item) => Position.fromGeoJsonCoordinates(item.cast<double>()))
      .toList(growable: false) ?? const [],
    steps = json['steps']
      ?.map<RoutingStep>((item) => RoutingStep.fromJson(item))
      .toList(growable: false) ?? const [],
    edges = json['edges']
      ?.map<RoutingEdge>((item) => RoutingEdge.fromJson(item))
      .toList(growable: false) ?? const [];
}


/// Contains details about the calculated route.

class RouteDetails {
  final double distance;
  final Duration duration;
  final Duration durationExact;
  final Duration durationDivision;

  final double accessibility;
  final double accessibilityExact;
  final double accessibilityDivision;

  final int elevationUp;
  final int elevationDown;

  final Duration penalizedDuration;
  final double penalizedAccessibility;

  RouteDetails.fromJson(Map<String, dynamic> json) :
    distance = json['distance'],
    duration = _durationFromSeconds(json['duration']),
    durationExact = _durationFromSeconds(json['duration_exact']),
    durationDivision = _durationFromSeconds(json['duration_division']),
    accessibility = json['accessibility'],
    accessibilityExact = json['accessibility_exact'],
    accessibilityDivision = json['accessibility_division'],
    elevationUp = json['elevation_up'],
    elevationDown = json['elevation_down'],
    penalizedDuration = _durationFromSeconds(json['penalized_duration']),
    penalizedAccessibility = json['penalized_accessibility'];
}


/// A step of a route with additional details.

class RoutingStep {
  final String stepType;
  final String streetName;
  final String streetType;
  final String crossingType;
  final String side;
  final bool beeline;

  final double distance;
  final Duration duration;
  final double accessibility;

  final int elevationUp;
  final int elevationDown;
  final bool inclineUp;
  final int incline;
  final bool? handrail;

  final String? doorType;
  final String? automaticDoorType;
  final String? trafficSignalsSound;
  final String? trafficSignalsVibration;
  final double maxWidth;

  final Duration durationPenalty;
  final double accessibilityPenalty;

  final int index;

  /// Will be empty if the [RoutingRequest] did not set `includeStepsPath` to `true`.

  final List<Position> path;

  RoutingStep.fromJson(Map<String, dynamic> json) :
    stepType = json['step_type'],
    streetName = json['street_name'],
    streetType = json['street_type'],
    crossingType = json['crossing_type'],
    side = json['side'],
    beeline = json['beeline'],
    distance = json['distance'],
    duration = _durationFromSeconds(json['duration']),
    accessibility = json['accessibility'],
    elevationUp = json['elevation_up'],
    elevationDown = json['elevation_down'],
    inclineUp = json['incline_up'],
    incline = json['incline'] ?? 0,
    handrail = json['handrail'],
    doorType = json['door_type'],
    automaticDoorType = json['door_type'],
    trafficSignalsSound = json['traffic_signals_sound'],
    trafficSignalsVibration = json['traffic_signals_vibration'],
    maxWidth = json['max_width'] ?? double.infinity,
    durationPenalty = _durationFromSeconds(json['duration_penalty']),
    accessibilityPenalty = json['accessibility_penalty'],
    index = json['index'],
    path = json['path']
      ?.map<Position>((item) => Position.fromGeoJsonCoordinates(item.cast<double>()))
      .toList(growable: false) ?? const [];
}
