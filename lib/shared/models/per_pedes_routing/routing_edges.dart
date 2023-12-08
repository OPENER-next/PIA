part of 'ppr.dart';

/// Base class of a PPR routing edge.
///
/// One can switch over all edge types like this:
/// ```dart
/// RoutingEdge edge;
/// switch (edge) {
///   case final RoutingEdgeEntrance e:
///     e;
///   break;
///   case final RoutingEdgeElevator e:
///     e;
///   break;
///   ...
/// }
/// ```

sealed class RoutingEdge {
  final String name;

  final Duration duration;
  final Duration durationPenalty;

  final double accessibility;
  final double accessibilityPenalty;

  final double maxWidth;

  final Level level;

  LevelConnection get connectionType;

  RoutingEdge._fromJson(Map<String, dynamic> json) :
    name = json['name'],
    duration = _durationFromSeconds(json['duration']),
    accessibility = json['accessibility'],
    maxWidth = json['max_width'] ?? double.infinity,
    durationPenalty = _durationFromSeconds(json['duration_penalty']),
    accessibilityPenalty = json['accessibility_penalty'],
    level = Level.fromNumber(json['level']);


  factory RoutingEdge.fromJson(Map<String, dynamic> json) {
    final type = json['edge_type'];
    switch (type) {
      case 'footway':
      case 'connection':
        final streetType = json['street_type'];
        switch (streetType) {
          case 'stairs': return RoutingEdgeStairs._fromJson(json);
          case 'escalator': return RoutingEdgeEscalator._fromJson(json);
          case 'moving_walkway': return RoutingEdgeMovingWalkway._fromJson(json);
        }
        if (
          json['incline'] != null &&
          json['incline'] != 0 &&
          !const ['sidewalk', 'crossing', 'alley'].contains(json['footway'])
        ) return RoutingEdgeRamp._fromJson(json);
        return RoutingEdgeFootway._fromJson(json);
      case 'street': return RoutingEdgeStreet._fromJson(json);
      case 'crossing': return RoutingEdgeCrossing._fromJson(json);
      case 'entrance': return RoutingEdgeEntrance._fromJson(json);
      case 'cycle_barrier': return RoutingEdgeCycleBarrier._fromJson(json);
      case 'elevator': return RoutingEdgeElevator._fromJson(json);
    }
    throw UnsupportedError('Got unsupported edge_type: "$type" in the PPR response.');
  }
}

sealed class RoutingEdgePoint extends RoutingEdge {
  final LatLng point;
  final int osmNodeId;

  RoutingEdgePoint._fromJson(super.json) :
    point = LatLng(json['path'].first[1], json['path'].first[0]),
    osmNodeId = json['from_node_osm_id'],
    super._fromJson();
}

sealed class RoutingEdgePath extends RoutingEdge {
  final List<LatLng> path;
  final int osmWayId;
  final int fromNodeOsmId;
  final int toNodeOsmId;
  final double distance;
  final int elevationUp;
  final int elevationDown;
  final bool area;

  RoutingEdgePath._fromJson(super.json) :
    path = json['path']
      .map<LatLng>((item) => LatLng(item[1], item[0]))
      .toList(growable: false),
    osmWayId = json['osm_way_id'],
    fromNodeOsmId = json['from_node_osm_id'],
    toNodeOsmId = json['to_node_osm_id'],
    distance = json['distance'],
    elevationUp = json['elevation_up'],
    elevationDown = json['elevation_down'],
    area = json['area'],
    super._fromJson();
}

// actual routing edge type implementations \\

// nodes \\

class RoutingEdgeEntrance extends RoutingEdgePoint {
  final String doorType;
  final String automaticDoorType;

  @override
  LevelConnection get connectionType => LevelConnection.level;

  RoutingEdgeEntrance._fromJson(super.json) :
    doorType = json['door_type'] ?? 'unknown',
    automaticDoorType = json['automatic_door_type'] ?? 'unknown',
    super._fromJson();
}

class RoutingEdgeElevator extends RoutingEdgePoint {
  @override
  final LevelConnection connectionType;

  RoutingEdgeElevator._fromJson(super.json) :
    connectionType = json['incline_up'] ? LevelConnection.up : LevelConnection.down,
    super._fromJson();
}

class RoutingEdgeCycleBarrier extends RoutingEdgePoint {
  @override
  LevelConnection get connectionType => LevelConnection.level;

  RoutingEdgeCycleBarrier._fromJson(super.json) : super._fromJson();
}

// paths \\

class RoutingEdgeCrossing extends RoutingEdgePath {
  final String type;

  final int markedCrossingDetour;

  final bool? trafficSignalsSound;
  final bool? trafficSignalsVibration;

  @override
  LevelConnection get connectionType => LevelConnection.level;

  RoutingEdgeCrossing._fromJson(super.json) :
    type = json['crossing_type'],
    trafficSignalsSound = json['traffic_signals_sound'],
    trafficSignalsVibration = json['traffic_signals_vibration'],
    markedCrossingDetour = json['marked_crossing_detour'],
    super._fromJson();
}

class RoutingEdgeStreet extends RoutingEdgePath {
  final String type;
  final int? incline;
  final String footwaySide;

  @override
  LevelConnection get connectionType => LevelConnection.level;

  RoutingEdgeStreet._fromJson(super.json) :
    type = json['street_type'],
    incline = json['incline'],
    footwaySide = json['side'],
    super._fromJson();
}

class RoutingEdgeFootway extends RoutingEdgePath {

  /// Type "none" is a generated/virtual path at the start and end of an entire routing path

  final String type;
  final int? incline;

  @override
  LevelConnection get connectionType => LevelConnection.level;

  RoutingEdgeFootway._fromJson(super.json) :
    type = json['street_type'],
    incline = json['incline'],
    super._fromJson();
}

class RoutingEdgeStairs extends RoutingEdgePath {
  final bool? handrail;

  @override
  final LevelConnection connectionType;

  RoutingEdgeStairs._fromJson(super.json) :
    handrail = json['handrail'],
    connectionType = json['incline_up'] ? LevelConnection.up : LevelConnection.down,
    super._fromJson();
}

class RoutingEdgeRamp extends RoutingEdgePath {
  final bool? handrail;

  @override
  final LevelConnection connectionType;

  /// Actual incline in percent.
  /// This will be negative if traveling downwards.

  final int incline;

  RoutingEdgeRamp._fromJson(super.json) :
    handrail = json['handrail'],
    connectionType = json['incline_up'] ? LevelConnection.up : LevelConnection.down,
    incline = json['incline'],
    super._fromJson();
}

class RoutingEdgeEscalator extends RoutingEdgePath {
  final bool? handrail;

  @override
  final LevelConnection connectionType;

  RoutingEdgeEscalator._fromJson(super.json) :
    handrail = json['handrail'],
    connectionType = json['incline_up'] ? LevelConnection.up : LevelConnection.down,
    super._fromJson();
}

class RoutingEdgeMovingWalkway extends RoutingEdgePath {
  final bool? handrail;

  @override
  final LevelConnection connectionType;

  /// Actual incline in percent.
  /// This will be negative if traveling downwards.

  final int? incline;

  RoutingEdgeMovingWalkway._fromJson(super.json) :
    handrail = json['handrail'],
    incline = json['incline'],
    connectionType = json['incline_up'] != null
      ? json['incline_up'] ? LevelConnection.up : LevelConnection.down
      : LevelConnection.level,
    super._fromJson();
}


Duration _durationFromSeconds(num seconds) {
  return Duration(
    microseconds: (seconds * Duration.microsecondsPerSecond).round(),
  );
}


enum LevelConnection {
  up, down, level
}
