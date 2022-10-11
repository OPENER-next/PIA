import 'dart:async';

import '/models/position.dart';
import '/shared/utils/map_layer_manager.dart';

class MapRoutingLayer extends MapLayer {
  final sourceId = 'indoor-routing-path';

  final List<Position> path;

  MapRoutingLayer([
    List<Position>? path,
  ]) : path = path ?? [];

  Future<void> register() async {
    await controller.addGeoJsonSource(sourceId, _createGeoJsonFeatureCollection());
  }

  Future<void> unregister() async {
    await controller.removeSource(sourceId);
  }


  Map<String, dynamic> _createGeoJsonFeature(List<List<double>> coordinates, num level) => {
    "type": "Feature",
    "properties": {
      "level": level.toString(),
    },
    "geometry": {
      'type': 'LineString',
      "coordinates": coordinates,
    },
  };

  Iterable<Map<String, dynamic>> _createGeoJsonFeatures() sync* {
    num level = path.isNotEmpty ? path.first.level : double.nan;
     List<List<double>> positionBuffer = [];

    for (final position in path) {
      if (position.level != level) {
        yield _createGeoJsonFeature(positionBuffer, level);

        level = position.level;
        positionBuffer = [];
      }
      positionBuffer.add(position.toGeoJsonCoordinates());
    }
    if (positionBuffer.isNotEmpty) {
      yield _createGeoJsonFeature(positionBuffer, level);
    }
  }

  Map<String, dynamic> _createGeoJsonFeatureCollection() => {
    "type": "FeatureCollection",
    "features": _createGeoJsonFeatures().toList(),
  };
}
