import 'dart:async';
import 'dart:collection';

import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' hide LatLng;

import '/shared/models/level.dart';
import '../map_layer_manager.dart';
import '/shared/models/per_pedes_routing/ppr.dart';

/// **Note**: This will add two sources by appending `_metrics` and `_nometrics` to the id.

class MapRoutingLayer implements MapLayerDescription {
  final MapRoutingPath path;

  final String metricsIdSuffix;
  final String nometricsIdSuffix;

  const MapRoutingLayer({
    required this.path,
    this.metricsIdSuffix = '_metrics',
    this.nometricsIdSuffix = '_nometrics',
  });

  @override
  MapLayer<MapLayerDescription> create(String id) => _MapRoutingLayer(id, this);
}

class _MapRoutingLayer extends MapLayer<MapRoutingLayer> {
  _MapRoutingLayer(super.id, super.description);

  String get metricsId => id + description.metricsIdSuffix;

  String get nometricsId => id + description.nometricsIdSuffix;

  @override
  Future<void> register() async {
    final collection = description.path.toGeoJsonFeatureCollection();
    await Future.wait([
      // lineMetrics required to allow line gradients when rendering/in styles
      controller.addSource(metricsId, GeojsonSourceProperties(
        lineMetrics: true,
        data: collection,
      )),
      // Second data layer required for correct line-dasharray styles
      // because they are negatively affected by line metrics.
      // line-dasharray:
      // - doesn't support expressions (so dash array cannot be computed based on pre calculated length)
      // - scales with the length of the line when lineMetrics is specified (which is undesirable)
      controller.addSource(nometricsId, GeojsonSourceProperties(
        lineMetrics: false,
        data: collection,
      )),
    ]);
  }

  @override
  Future<void> update(oldDescription) async {
    final collection = description.path.toGeoJsonFeatureCollection();
    await Future.wait([
      controller.setGeoJsonSource(metricsId, collection),
      controller.setGeoJsonSource(nometricsId, collection),
    ]);
  }

  @override
  Future<void> unregister() async {
    await Future.wait([
      controller.removeSource(metricsId),
      controller.removeSource(nometricsId),
    ]);
  }
}


/// Routing path based based on individual segments.
///
/// Can be created from PPR [RoutingEdge]s.

class MapRoutingPath extends ListBase<MapRoutingEdge> {
  final List<MapRoutingEdge> _path;

  MapRoutingPath({
    required List<MapRoutingEdge> path,
  }) : _path = path;

  MapRoutingPath.fromEdges(Iterable<RoutingEdge> edges) :
    _path = _edgesToSegments(edges).toList();

  /// Maps all [RoutingEdge]s of the routing path to [MapRoutingEdge]s.
  ///
  /// Edges of the same type are combined into one [MapRoutingEdge].

  static Iterable<MapRoutingEdge> _edgesToSegments(Iterable<RoutingEdge> edges) sync* {
    final iter = edges.iterator;
    // exit on empty path
    if (!iter.moveNext()) return;

    var previousEdge = iter.current;
    var positionBuffer = <LatLng>[];

    do {
      final edge = iter.current;

      if (previousEdge.runtimeType != edge.runtimeType || previousEdge.level != edge.level) {
        yield MapRoutingEdge(
          path: positionBuffer,
          level: previousEdge.level,
          type: _typeToName(previousEdge),
          connection: previousEdge.connectionType,
        );
        // new list for next geo json feature
        positionBuffer = [];
      }

      if (positionBuffer.isEmpty) {
        if (edge is RoutingEdgePoint) {
          positionBuffer.add(edge.point);
        }
        else if (edge is RoutingEdgePath) {
          positionBuffer.addAll(edge.path);
        }
      }
      else {
        // if the edges are merged into one path/segment
        // ignore RoutingEdgePoints
        if (edge is RoutingEdgePath) {
          // and skip first position since it is identical to the last position of the previous edge
          positionBuffer.addAll(edge.path.skip(1));
        }
      }
      previousEdge = edge;
    } while (iter.moveNext());

    // return final geo json feature
    yield MapRoutingEdge(
      path: positionBuffer,
      level: previousEdge.level,
      type: _typeToName(previousEdge),
      connection: previousEdge.connectionType,
    );
  }

  static _typeToName (RoutingEdge edge) {
    switch (edge) {
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
    'features': _path
      .map((s) => s.toGeoJsonFeature())
      .toList(growable: false),
  };

  @override
  int get length => _path.length;

  @override
  set length(int value) => _path.length = value;

  @override
  MapRoutingEdge operator [](int index) {
    return _path[index];
  }

  @override
  void operator []=(int index, MapRoutingEdge value) {
    _path[index] = value;
  }
}


class MapRoutingEdge {
  final List<LatLng> path;
  final Level level;
  final String type;

  /// For stairs, escalators and the like this indicates an incline/decline in the path direction.
  /// For elevators this simply tells if they should travel up or down.
  final LevelConnection connection;

  MapRoutingEdge({
    required this.path,
    required this.level,
    required this.type,
    required this.connection,
  });

  Map<String, dynamic> toGeoJsonFeature() => {
    'type': 'Feature',
    'properties': {
      'type': type,
      'level': level.toString(),
      'connection': connection.name,
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
