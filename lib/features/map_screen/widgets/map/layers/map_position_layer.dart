import 'dart:async';

import '/shared/models/position.dart';
import '../map_layer_manager.dart';


class MapPositionLayer implements MapLayerDescription {
  final Position position;

  const MapPositionLayer({
    required this.position,
  });

  @override
  MapLayer<MapLayerDescription> create(String id) => _MapPositionLayer(id, this);
}

class _MapPositionLayer extends MapLayer<MapPositionLayer> {
  _MapPositionLayer(super.id, super.description);

  @override
  Future<void> register() async {
    await controller.addGeoJsonSource(id, _createGeoJsonFeatureCollection());
  }

  @override
  Future<void> update(oldDescription) async {
    await controller.setGeoJsonSource(id, _createGeoJsonFeatureCollection());
  }

  @override
  Future<void> unregister() async {
    await controller.removeSource(id);
  }

  Map<String, dynamic> _createGeoJsonFeature() => {
    'type': 'Feature',
    'properties': {
      'level': description.position.level.asNumber,
    },
    'geometry': {
      'type': 'Point',
      'coordinates': description.position.toGeoJsonCoordinates(),
    }
  };

  Map<String, dynamic> _createGeoJsonFeatureCollection() => {
    'type': 'FeatureCollection',
    'features': [
      _createGeoJsonFeature(),
    ],
  };
}
