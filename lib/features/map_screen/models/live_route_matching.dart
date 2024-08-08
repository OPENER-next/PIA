import 'package:latlong2/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;

import '/shared/models/position.dart';

import 'live_route_segment.dart';

/// Simple (sort of) map matching implementation to match the current position to the route and update the route.

mixin LiveRouteMatching {

  List<LiveRouteSegment> get edges;

  /// Updates the route to the given position by removing obsolete parts and updating the path
  /// unless it exceeds the [maxDeviation] value.
  ///
  /// Returns true if the route is updated and false if the position is to far away from the given deviation
  /// meaning the rout is not updated.

  bool fitTo(Position position, { required num maxDeviation }) {
    final edge = nearestEdge(position, maxDeviation);
    if (edge != null) {
      // removes all edges till the given edge is found including the given edge
      while (edges.isNotEmpty && edges.removeLast() != edge) {}
      // adds a new shortened version of the target edge
      edges.add(_shortenEdgeToPosition(edge, position));
      return true;
    }
    return false;
  }

  LiveRouteSegment? nearestEdge(Position position, num maxDeviation) {
    final point = maps_toolkit.LatLng(position.latitude, position.longitude);
    // only edges that touch the current level starting from the nearest edge
    final sameLevelEdges = edges.reversed.where(
      (edge) => edge.fromLevel == position.level || edge.toLevel == position.level,
    );

    LiveRouteSegment? nearestEdge;
    for (final edge in sameLevelEdges) {
      final path = edge.path
        .map((p) => maps_toolkit.LatLng(p.latitude, p.longitude))
        .toList(growable: false);


      if (edge.path.length == 1) {
        final deviation = maps_toolkit.SphericalUtil.computeDistanceBetween(
          point, path.first,
        );
        // <= instead of < to favor later route segments
        if (deviation <= maxDeviation) {
          nearestEdge = edge;
          maxDeviation = deviation;
        }
      }
      else {
        final index = maps_toolkit.PolygonUtil.locationIndexOnPath(
          point, path, true, tolerance: maxDeviation,
        );
        if (index != -1) {
          nearestEdge = edge;
          // reduce deviation for each new hit but use ceil to allow some variation
          maxDeviation = maps_toolkit.PolygonUtil.distanceToLine(
            point, path[index], path[index + 1],
          ).ceil();
        }
      }
    }
    return nearestEdge;
  }

  LiveRouteSegment _shortenEdgeToPosition(LiveRouteSegment edge, Position position) {
    // prevent node edges like doors and elevators from updating their position
    if (edge.path.length == 1) {
      return edge;
    }
    final path = List.of(edge.path);
    const geo = Distance();
    var previousDistance = double.infinity;
    // >1 to prevent the creation of paths with only one coordinate
    while (path.length > 1) {
      final point = path.first;
      final distance = geo.distance(position, point);
      if (distance > previousDistance) {
        break;
      }
      path.removeAt(0);
      previousDistance = distance;
    }

    path.insert(0, position);
    return edge.copyWith(path: path);
  }
}
