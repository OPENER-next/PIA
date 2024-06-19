import 'dart:math';

import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;
import 'package:mobx/mobx.dart';

import '/shared/models/level.dart';
import '/shared/models/per_pedes_routing/ppr.dart';
import 'live_route_matching.dart';
import 'live_route_segment.dart';

/// A mutable and observable instance of a route.
///
/// The first item (index 0) is the destination point and the last item (index: length - 1) is the starting point.

class LiveRoute with LiveRouteMatching {
  final ObservableList<LiveRouteSegment> _edges;

  /// The [LiveRouteSegment]s this route is composed of.
  ///
  /// It is safe to mutate this list.

  @override
  List<LiveRouteSegment> get edges => _edges;

  LiveRoute(Iterable<LiveRouteSegment> edges)
    : _edges = ObservableList.of(edges);

  LiveRoute.fromRawRoute(Route route) :
    // reverse so we can efficiently pop from the start point
    _edges = ObservableList.of(
      List.of(
        _rawEdgesToSegments(_filterRawEdges(route.edges)),
      ).reversed
    );

  /// Filter edges by pre-defined criteria.

  static Iterable<RoutingEdge> _filterRawEdges(Iterable<RoutingEdge> edges) {
    return edges.where((element) {
      if (element is RoutingEdgeEntrance && element.doorType == 'no') {
        return false;
      }
      return true;
    });
  }

  /// Maps all [RoutingEdge]s of the routing path to [LiveRouteSegment]s.
  ///
  /// This tries to assign the correct from/to levels to the segments based on the previous and next edge.

  static Iterable<LiveRouteSegment> _rawEdgesToSegments(Iterable<RoutingEdge> edges) sync* {
    final iter = edges.iterator;
    // exit on empty path
    if (!iter.moveNext()) return;
    var previousEdge = iter.current;
    // return first edge
    yield LiveRouteSegment.fromRawEdge(previousEdge);
    // return on single edge
    if (!iter.moveNext()) return;
    var currentEdge = iter.current;

    while (iter.moveNext()) {
      final nextEdge = iter.current;

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

      yield LiveRouteSegment.fromRawEdge(
        currentEdge,
        fromLevel: from,
        toLevel: to,
      );

      previousEdge = currentEdge;
      currentEdge = nextEdge;
    }
    // return last edge
    yield LiveRouteSegment.fromRawEdge(currentEdge);
  }

  /// Holds the total distance of this route.

  double get distance => _distance.value;
  late final _distance = Computed<double>(() {
    return _edges
      .fold<double>(0, (result, edge) => edge.distance + result);
  });

  /// Holds the total duration of this route.

  Duration get duration => _duration.value;
  late final _duration = Computed<Duration>(() {
    return _edges
      .fold<Duration>(Duration.zero, (result, edge) => edge.duration + result);
  });

  /// Holds the latitude and longitude bounds of this route.

  maplibre.LatLngBounds get bounds => _bounds.value;
  late final _bounds = Computed<maplibre.LatLngBounds>(() {
    double minX = 180;
    double maxX = -180;
    double minY = 90;
    double maxY = -90;

    final path = _edges.expand((edge) => edge.path);
    for (final point in path) {
      minX = min(minX, point.longitude);
      minY = min(minY, point.latitude);
      maxX = max(maxX, point.longitude);
      maxY = max(maxY, point.latitude);
    }

    return maplibre.LatLngBounds(
      southwest: maplibre.LatLng(minY, minX),
      northeast: maplibre.LatLng(maxY, maxX),
    );
  });


  Map<String, dynamic> toGeoJsonFeatureCollection() => {
    'type': 'FeatureCollection',
    'features': _edges
      .reversed
      .map((s) => s.toGeoJsonFeature())
      .toList(growable: false),
  };
}
