import '/shared/models/per_pedes_routing/ppr.dart';
import '../../routing_profile/models/user_profile.dart';

/// Extracts all discomforts of a given route for a given user profile.
///
/// A discomfort is e.g. if a user wants to avoid stairs but the route goes along stairs.

class RouteDiscomforts {
  late final List<RoutingEdge> edges;
  late final Map<DiscomfortType, int> stats;

  RouteDiscomforts({
    required Route route,
    required UserProfile profile,
  }) {
    edges = _complicationsFilter(profile, route.edges).toList(growable: false);
    stats = _complicationStats(edges);
  }

  static Iterable<RoutingEdge> _complicationsFilter(UserProfile profile, Iterable<RoutingEdge> edges) {
    return edges.where((edge) {
      if (edge is RoutingEdgeEntrance) {
        if (edge.automaticDoorType == 'continuous' || edge.automaticDoorType == 'slowdown_button') {
          return profile.automaticRevolvingDoor.isAdverselyAccessible;
        }
        if (edge.automaticDoorType == 'button') {
          return profile.buttonDoor.isAdverselyAccessible;
        }
        if (edge.automaticDoorType == 'motion') {
          return profile.sensorDoor.isAdverselyAccessible;
        }
        if (edge.automaticDoorType == 'no' || edge.automaticDoorType.isEmpty) {
          return profile.manualDoor.isAdverselyAccessible;
        }
      }
      else if (edge is RoutingEdgeCrossing) {
        if (edge.type == 'blind_signals') {
          return profile.blindSignalsCrossing.isAdverselyAccessible;
        }
        if (edge.type == 'signals') {
          return profile.signalsCrossing.isAdverselyAccessible;
        }
        if (edge.type == 'island') {
          return profile.islandCrossing.isAdverselyAccessible;
        }
        if (edge.type == 'marked') {
          return profile.markedCrossing.isAdverselyAccessible;
        }
        if (edge.type == 'unmarked') {
          return profile.unmarkedCrossing.isAdverselyAccessible;
        }
      }
      else if (edge is RoutingEdgeStairs) {
        if (edge.inclineDirection == Incline.down) {
          return profile.stairsDown.isAdverselyAccessible;
        }
        else {
          return profile.stairsUp.isAdverselyAccessible;
        }
      }
      else if (edge is RoutingEdgeEscalator) {
        return profile.escalator.isAdverselyAccessible;
      }
      else if (edge is RoutingEdgeMovingWalkway) {
        return profile.movingWalkway.isAdverselyAccessible;
      }
      else if (edge is RoutingEdgeElevator) {
        return profile.elevator.isAdverselyAccessible;
      }
      return false;
    });
  }


  static Map<DiscomfortType, int> _complicationStats(Iterable<RoutingEdge> edges) {
    final stats = <DiscomfortType, int>{};
    for (final edge in edges) {
      final int value;
      final DiscomfortType type;

      if (edge is RoutingEdgeEntrance) {
        type = DiscomfortType.door;
        value = 1;
      }
      else if (edge is RoutingEdgeCrossing) {
        if (edge.type == 'blind_signals' || edge.type == 'signals') {
          type = DiscomfortType.crossingWithSignals;
          value = 1;
        }
        else {
          type = DiscomfortType.crossingWithoutSignals;
          value = 1;
        }
      }
      else if (edge is RoutingEdgeStairs) {
        if (edge.inclineDirection == Incline.down) {
          type = DiscomfortType.stairsDown;
          value = (edge.distance / 0.3).round(); // roughly estimate steps
        }
        else {
          type = DiscomfortType.stairsUp;
          value = (edge.distance / 0.3).round(); // roughly estimate steps
        }
      }
      else if (edge is RoutingEdgeEscalator) {
        type = DiscomfortType.escalator;
        value = edge.duration.inSeconds;
      }
      else if (edge is RoutingEdgeMovingWalkway) {
        type = DiscomfortType.movingWalkway;
        value = edge.duration.inSeconds;
      }
      else if (edge is RoutingEdgeElevator) {
        type = DiscomfortType.elevator;
        value = edge.duration.inSeconds;
      }
      else {
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
