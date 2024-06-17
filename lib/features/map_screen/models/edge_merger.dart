import 'package:latlong2/latlong.dart';

import '/shared/models/per_pedes_routing/ppr.dart';

/// Helper class to merge similar edges into one.

class EdgeMerger {

  /// Callback that returns `true` when the previous edge should be merged into the current edge.

  final bool Function(RoutingEdge previousEdge, RoutingEdge edge) shouldMerge;

  List<LatLng> _positionBuffer = [];
  RoutingEdge? _previousEdge;

  /// Default merge heuristics are based on the edge type and level.

  EdgeMerger({
    this.shouldMerge = _defaultMergeHeuristics,
  });

  static bool _defaultMergeHeuristics(RoutingEdge previousEdge, RoutingEdge edge) =>
    previousEdge.runtimeType == edge.runtimeType && previousEdge.level == edge.level;

  /// Returns the last edge with the merged path whenever a new edge starts.
  /// This happens when [shouldMerge] returns `false`.
  ///
  /// If the given edge is merged with the previous one `null` is returned.

  ({RoutingEdge edge, List<LatLng> path})? add(RoutingEdge edge) {
    ({RoutingEdge edge, List<LatLng> path})? mergedEdge;
    if (_previousEdge != null && !shouldMerge(_previousEdge!, edge)) {
      mergedEdge = (edge: _previousEdge!, path: _positionBuffer);
      // new list for next geo json feature
      _positionBuffer = [];
    }
    if (_positionBuffer.isEmpty) {
      if (edge is RoutingEdgePoint) {
        _positionBuffer.add(edge.point);
      }
      else if (edge is RoutingEdgePath) {
        _positionBuffer.addAll(edge.path);
      }
    }
    else {
      // if the edges are merged into one path/segment
      // ignore RoutingEdgePoints
      if (edge is RoutingEdgePath) {
        // and skip first position since it is identical to the last position of the previous edge
        _positionBuffer.addAll(edge.path.skip(1));
      }
    }
    _previousEdge = edge;
    return mergedEdge;
  }

  /// Returns the current edge data.

  ({RoutingEdge edge, List<LatLng> path}) get current {
    if (_previousEdge == null) {
      throw StateError('current must not be read before add() has been called.');
    }
    return (edge: _previousEdge!, path: _positionBuffer);
  }
}
