import 'package:latlong2/latlong.dart';

import '/shared/models/level.dart';
import '/shared/models/per_pedes_routing/ppr.dart';

/// An immutable segment of a [LiveRoute].

class LiveRouteSegment {
  final String name;

  final Level fromLevel;
  final Level toLevel;

  final List<LatLng> path;

  final double distance;

  final Duration duration;

  final bool discomfort;

  LiveRouteSegmentType type;

  LiveRouteSegment({
    required this.name,
    required this.fromLevel,
    required this.toLevel,
    required this.path,
    required this.duration,
    required this.discomfort,
    required this.type,
  }) :
    distance = Path.from(path).distance;

  LiveRouteSegment.fromRawEdge(RoutingEdge edge, {
    Level? fromLevel,
    Level? toLevel,
  }) :
    name = edge.name,
    fromLevel = fromLevel ?? edge.level,
    toLevel = toLevel ?? edge.level,
    path = edge is RoutingEdgePath
      ? edge.path : [(edge as RoutingEdgePoint).point],
    distance = edge is RoutingEdgePath
      ? edge.distance : 0,
    duration = edge.duration,
    discomfort = edge.accessibility > 0,
    type = LiveRouteSegmentType.fromRawEdge(edge);

  Map<String, dynamic> toGeoJsonFeature() => {
    'type': 'Feature',
    'properties': {
      'type': type.geoJsonString,
      'from_level': fromLevel.asNumber,
      'to_level': toLevel.asNumber,
      'discomfort': discomfort,
    },
    if (path.length == 1) 'geometry': {
      'type': 'Point',
      'coordinates': [path.first.longitude, path.first.latitude],
    }
    else 'geometry': {
      'type': 'LineString',
      'coordinates': path
        .map((p) => [p.longitude, p.latitude])
        .toList(growable: false),
    }
  };

  LiveRouteSegment copyWith({
    String? name,
    Level? fromLevel,
    Level? toLevel,
    List<LatLng>? path,
    Duration? duration,
    bool? discomfort,
    LiveRouteSegmentType? type,
  }) {
    return LiveRouteSegment(
      name: name ?? this.name,
      fromLevel: fromLevel ?? this.fromLevel,
      toLevel: toLevel ?? this.toLevel,
      path: path ?? this.path,
      duration: duration ?? this.duration,
      discomfort: discomfort ?? this.discomfort,
      type: type ?? this.type,
    );
  }
}

/// Describes the type of a route segment.

enum LiveRouteSegmentType {
  beeline('beeline'),
  entrance('entrance'),
  elevator('elevator'),
  cycleBarrier('cycle_barrier'),
  controlledStreetCrossing('controlled_street_crossing'),
  uncontrolledStreetCrossing('uncontrolled_street_crossing'),
  street('street'),
  footway('footway'),
  stairs('stairs'),
  ramp('ramp'),
  escalator('escalator'),
  movingWalkway('moving_walkway');

  final String geoJsonString;

  const LiveRouteSegmentType(this.geoJsonString);

  static LiveRouteSegmentType fromRawEdge(RoutingEdge edge) {
    switch (edge) {
      case RoutingEdgeBeeline(): return LiveRouteSegmentType.beeline;
      case RoutingEdgeEntrance(): return LiveRouteSegmentType.entrance;
      case RoutingEdgeElevator(): return LiveRouteSegmentType.elevator;
      case RoutingEdgeCycleBarrier(): return LiveRouteSegmentType.cycleBarrier;
      case RoutingEdgeCrossing():
        return edge.type == 'blind_signals' || edge.type == 'signals'
          ? LiveRouteSegmentType.controlledStreetCrossing
          : LiveRouteSegmentType.uncontrolledStreetCrossing;
      case RoutingEdgeStreet(): return LiveRouteSegmentType.street;
      case RoutingEdgeFootway(): return LiveRouteSegmentType.footway;
      case RoutingEdgeStairs(): return LiveRouteSegmentType.stairs;
      case RoutingEdgeRamp(): return LiveRouteSegmentType.ramp;
      case RoutingEdgeEscalator(): return LiveRouteSegmentType.escalator;
      case RoutingEdgeMovingWalkway(): return LiveRouteSegmentType.movingWalkway;
    }
  }
}
