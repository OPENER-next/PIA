import 'dart:collection';

import 'package:latlong2/latlong.dart';

import '/shared/models/level.dart';
import '/shared/models/per_pedes_routing/ppr.dart';
import 'edge_merger.dart';


/// Routing path based based on individual segments.
///
/// Can be created from PPR [RoutingEdge]s.

class MapRoutingPath extends IterableBase<MapRoutingEdge> {
  final List<MapRoutingEdge> _edges;

  MapRoutingPath({
    required Iterable<MapRoutingEdge> path,
  }) : _edges = List.of(path);

  MapRoutingPath.fromEdges(Iterable<RoutingEdge> edges) :
    _edges = List.of(_edgesToSegments(_filter(edges)));

  /// Filter edges by pre-defined criteria.

  static Iterable<RoutingEdge> _filter(Iterable<RoutingEdge> edges) {
    return edges.where((element) {
      if (element is RoutingEdgeEntrance && element.doorType == 'no') {
        return false;
      }
      return true;
    });
  }


  /// Maps all [RoutingEdge]s of the routing path to [MapRoutingEdge]s.
  ///
  /// Edges of the same type are combined into one [MapRoutingEdge].

  static Iterable<MapRoutingEdge> _edgesToSegments(Iterable<RoutingEdge> edges) sync* {
    final iter = edges.iterator;
    final merger = EdgeMerger();

    // exit on empty path
    if (!iter.moveNext()) return;
    var previousEdge = iter.current;
    merger.add(previousEdge);

    // return single geo json feature
    if (!iter.moveNext()) {
      final mergeData = merger.current;
      yield MapRoutingEdge(
        path: mergeData.path,
        fromLevel: mergeData.edge.level,
        toLevel: mergeData.edge.level,
        type: _typeToName(mergeData.edge),
      );
      return;
    }

    var currentEdge = iter.current;
    {
      final mergeData = merger.add(currentEdge);
      if (mergeData != null) {
        yield MapRoutingEdge(
          path: mergeData.path,
          fromLevel: previousEdge.level,
          toLevel: currentEdge.level,
          type: _typeToName(previousEdge),
        );
      }
    }

    while (iter.moveNext()) {
      final nextEdge = iter.current;
      final mergeData = merger.add(nextEdge);

      if (mergeData != null) {
        final Level from;
        final Level to;
        switch (currentEdge) {
          case RoutingEdgeElevator():
          case RoutingEdgeStairs():
          case RoutingEdgeRamp():
          case RoutingEdgeEscalator():
          case RoutingEdgeMovingWalkway():
            from = previousEdge.level;
            to = nextEdge.level;
          break;
          default:
            from = currentEdge.level;
            to = currentEdge.level;
        }

        yield MapRoutingEdge(
          path: mergeData.path,
          fromLevel: from,
          toLevel: to,
          type: _typeToName(currentEdge),
        );
      }

      previousEdge = currentEdge;
      currentEdge = nextEdge;
    }
    // return final geo json feature
    {
      final mergeData = merger.current;
      yield MapRoutingEdge(
        path: mergeData.path,
        fromLevel: currentEdge.level,
        toLevel: currentEdge.level,
        type: _typeToName(currentEdge),
      );
    }
  }

  static _typeToName (RoutingEdge edge) {
    switch (edge) {
      case RoutingEdgeBeeline(): return 'beeline';
      case RoutingEdgeEntrance(): return 'entrance';
      case RoutingEdgeElevator(): return 'elevator';
      case RoutingEdgeCycleBarrier(): return 'cycle_barrier';
      case RoutingEdgeCrossing(): return 'street_crossing';
      case RoutingEdgeStreet(): return 'street';
      case RoutingEdgeFootway(): return 'footway';
      case RoutingEdgeStairs(): return 'stairs';
      case RoutingEdgeRamp(): return 'ramp';
      case RoutingEdgeEscalator(): return 'escalator';
      case RoutingEdgeMovingWalkway(): return 'moving_walkway';
    }
  }

  Map<String, dynamic> toGeoJsonFeatureCollection() => {
    'type': 'FeatureCollection',
    'features': _edges
      .map((s) => s.toGeoJsonFeature())
      .toList(growable: false),
  };

  @override
  int get length => _edges.length;

  @override
  Iterator<MapRoutingEdge> get iterator => _edges.iterator;
}


class MapRoutingEdge {
  final List<LatLng> path;
  final Level fromLevel;
  final Level toLevel;
  final String type;

  MapRoutingEdge({
    required Iterable<LatLng> path,
    required this.fromLevel,
    required this.toLevel,
    required this.type,
  }) : path = List.of(path);

  Map<String, dynamic> toGeoJsonFeature() => {
    'type': 'Feature',
    'properties': {
      'type': type,
      'from_level': fromLevel.asNumber,
      'to_level': toLevel.asNumber,
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
}
