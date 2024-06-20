import 'live_route.dart';
import 'live_route_segment.dart';

/// Extracts all discomforts of a given route for a given user profile.
///
/// A discomfort is e.g. if a user wants to avoid stairs but the route goes along stairs.

class RouteDiscomforts {
  late final Map<DiscomfortType, int> stats;

  RouteDiscomforts({
    required LiveRoute route,
  }) : stats = _complicationStats(route.edges);

  static Map<DiscomfortType, int> _complicationStats(Iterable<LiveRouteSegment> edges) {
    final stats = <DiscomfortType, int>{};

    for (final edge in edges.where((e) => e.discomfort)) {
      final int value;
      final DiscomfortType type;

      switch (edge.type) {
        case LiveRouteSegmentType.entrance:
          type = DiscomfortType.door;
          value = 1;
        break;
        case LiveRouteSegmentType.elevator:
          type = DiscomfortType.elevator;
          value = edge.duration.inSeconds;
        break;
        case LiveRouteSegmentType.controlledStreetCrossing:
          type = DiscomfortType.crossingWithSignals;
          value = 1;
        break;
        case LiveRouteSegmentType.uncontrolledStreetCrossing:
          type = DiscomfortType.crossingWithoutSignals;
          value = 1;
        break;
        case LiveRouteSegmentType.stairs:
          if (edge.fromLevel > edge.toLevel) {
            type = DiscomfortType.stairsDown;
            value = (edge.distance / 0.3).round(); // roughly estimate steps
          }
          else {
            type = DiscomfortType.stairsUp;
            value = (edge.distance / 0.3).round(); // roughly estimate steps
          }
        break;
        case LiveRouteSegmentType.escalator:
          type = DiscomfortType.escalator;
          value = edge.duration.inSeconds;
        break;
        case LiveRouteSegmentType.movingWalkway:
          type = DiscomfortType.movingWalkway;
          value = edge.duration.inSeconds;
        break;
        default:
          throw UnimplementedError('Given edge $edge has no implementation.');
      }

      stats.update(type,
        (v) => v + value,
        ifAbsent: () => value,
      );
    }
    return stats;
  }
}


enum DiscomfortType {
  door,
  stairsUp,
  stairsDown,
  elevator,
  escalator,
  movingWalkway,
  crossingWithSignals,
  crossingWithoutSignals,
}
