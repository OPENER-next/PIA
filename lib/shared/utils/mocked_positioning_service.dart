import 'dart:async';
import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:mobx/mobx.dart';

import '../models/per_pedes_routing/ppr.dart';
import '../models/position.dart';


/// Generate indoor positions for testing purposes.

class MockedPositioningService {

  final Observable<Position?> _position = Observable(null);

  Position? get position => _position.value;

  StreamSubscription<Position>? _subscription;

  void walkRoute(Route route, {
    Duration interval = const Duration(milliseconds: 100),
    double stepSize = 1,
    double jitter = 1,
  }) {
    _subscription?.cancel();

    final points = _edgesToPoints(route.edges)
      .subdivide(stepSize: stepSize)
      .jitter(maxJitterDistance: jitter)
      .toList(growable: false);

    _subscription = Stream<Position>.periodic(interval, (index) {
      if (index >= points.length) {
        _subscription?.cancel();
      }
      return points[index];
    }).listen((p) => runInAction(() => _position.value = p));
  }

  Iterable<Position> _edgesToPoints(Iterable<RoutingEdge> edges) {
    return edges.expand((edge) sync* {
      if (edge is RoutingEdgePoint) {
        yield Position(
          edge.point.latitude,
          edge.point.longitude,
          level: edge.level,
        );
      }
      else if (edge is RoutingEdgePath) {
        for (final point in edge.path) {
          yield Position(
            point.latitude,
            point.longitude,
            level: edge.level,
          );
        }
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}


extension PositionSequenceExtensions on Iterable<Position> {

  /// Subdivide path into segments that are not larger than the given [stepSize].

  Iterable<Position> subdivide({ double stepSize = 1 }) sync* {
    const geo = Distance();
    // required because the iterator getter creates a new iterator instance
    final iter = iterator;

    if (!iter.moveNext()) {
      return;
    }

    var previous = iter.current;
    yield previous;

    while (iter.moveNext()) {
      final current = iter.current;
      double distance = geo.distance(previous, current);
      while (distance > stepSize) {
        final direction = geo.bearing(previous, current);
        final newPoint = geo.offset(previous, stepSize, direction);

        previous = Position(newPoint.latitude, newPoint.longitude, level: previous.level);
        yield previous;

        distance = geo.distance(previous, current);
      }

      previous = current;
      yield previous;
    }
  }

  /// Adds a random jitter to a sequence of [Positions].
  ///
  /// The [maxJitterDistance] is the maximum distance in meters a [Position] is offset.

  Iterable<Position> jitter({ double maxJitterDistance = 1 }) sync* {
    const geo = Distance();
    final rand = Random();
    for (final point in this) {
      final jitterDistance = rand.nextDouble() * maxJitterDistance;
      final jitterAngle = rand.nextDouble() * 360;
      final newPoint = geo.offset(point, jitterDistance, jitterAngle);
      yield Position(newPoint.latitude, newPoint.longitude, level: point.level);
    }
  }
}
