import 'dart:async';

import '/shared/models/level.dart';
import '/shared/models/position.dart';
import '../map_layer_manager.dart';


class MapRoutingLayer implements MapLayerDescription {
  final List<Position> path;

  const MapRoutingLayer({
    this.path = const [],
  });

  @override
  MapLayer<MapLayerDescription> create(String id) => _MapRoutingLayer(id, this);
}

class _MapRoutingLayer extends MapLayer<MapRoutingLayer> {
  _MapRoutingLayer(super.id, super.description);

  Future<void> register() async {
    await controller.addGeoJsonSource(id, _createGeoJsonFeatureCollection());
  }

  Future<void> update(oldDescription) async {
    await controller.setGeoJsonSource(id, _createGeoJsonFeatureCollection());
  }

  Future<void> unregister() async {
    await controller.removeSource(id);
  }

  Map<String, dynamic> _createGeoJsonFeature(List<List<double>> coordinates, Level level) => {
    "type": "Feature",
    "properties": {
      "level": level.toString(),
    },
    if (coordinates.length == 1) "geometry": {
      "type": "Point",
      "coordinates": coordinates.first,
    }
    else "geometry": {
      'type': 'LineString',
      "coordinates": coordinates,
    },
  };

  Iterable<Map<String, dynamic>> _createGeoJsonFeatures() sync* {
    if (description.path.isEmpty) return;

    Level level = description.path.first.level;
    List<List<double>> positionBuffer = [];

    for (final position in description.path) {
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
