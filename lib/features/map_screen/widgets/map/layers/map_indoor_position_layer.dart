import 'dart:async';

import '/shared/models/position.dart';
import '../map_layer_manager.dart';


class MapIndoorPositionLayer implements MapLayerDescription {
  final Position position;

  const MapIndoorPositionLayer({
    required this.position,
  });

  @override
  MapLayer<MapLayerDescription> create(String id) => _MapIndoorPositionLayer(id, this);
}

class _MapIndoorPositionLayer extends MapLayer<MapIndoorPositionLayer> {
  _MapIndoorPositionLayer(super.id, super.description);

  Future<void> register() async {
    await controller.addGeoJsonSource(id, _createGeoJsonFeatureCollection());
  }

  Future<void> update(oldDescription) async {
    await controller.setGeoJsonSource(id, _createGeoJsonFeatureCollection());
  }

  Future<void> unregister() async {
    await controller.removeSource(id);
  }

  Map<String, dynamic> _createGeoJsonFeature() => {
    "type": "Feature",
    "properties": {
      "level": description.position.level.toString(),
    },
    "geometry": {
      "type": "Point",
      "coordinates": description.position.toGeoJsonCoordinates(),
    }
  };

  Map<String, dynamic> _createGeoJsonFeatureCollection() => {
    "type": "FeatureCollection",
    "features": [
      _createGeoJsonFeature(),
    ],
  };
}
