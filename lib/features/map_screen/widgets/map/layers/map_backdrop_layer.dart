import 'dart:async';

import '../map_layer_manager.dart';

/// Can be used to add an overlay or backdrop between map layers.
///
/// Unfortunately there is no fill layer that is static to the camera.
/// The existing BackgroundLayer will always be displayed behind all other layers.
/// Therefore this layer uses a geoJSON layer that spans the whole globe to achieve this effect.

class MapBackdropLayer implements MapLayerDescription {
  const MapBackdropLayer();

  @override
  MapLayer<MapLayerDescription> create(String id) => _MapBackdropLayer(id, this);
}

class _MapBackdropLayer extends MapLayer<MapBackdropLayer> {
  _MapBackdropLayer(super.id, super.description);

  Future<void> register() async {
    await controller.addGeoJsonSource(id, _createGeoJsonFeatureCollection());
  }

  Future<void> update(oldDescription) async {
    await controller.setGeoJsonSource(id, _createGeoJsonFeatureCollection());
  }

  Future<void> unregister() async {
    await controller.removeSource(id);
  }

  Map<String, dynamic> _createGeoJsonFeatureCollection() => {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "coordinates": [
            [
              [
                -180,
                90,
              ],
              [
                180,
                90,
              ],
              [
                180,
                -90,
              ],
              [
                -180,
                -90,
              ],
              [
                -180,
                90,
              ],
            ],
          ],
          "type": "Polygon"
        },
      },
    ],
  };
}
