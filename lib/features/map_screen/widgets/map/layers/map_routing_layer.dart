import 'dart:async';

import 'package:maplibre_gl/maplibre_gl.dart' hide LatLng;

import '../../../models/live_route.dart';
import '../map_layer_manager.dart';

/// **Note**: This will add two sources by appending `_metrics` and `_nometrics` to the id.

class MapRoutingLayer implements MapLayerDescription {
  final LiveRoute path;

  final String metricsIdSuffix;
  final String nometricsIdSuffix;

  const MapRoutingLayer({
    required this.path,
    this.metricsIdSuffix = '_metrics',
    this.nometricsIdSuffix = '_nometrics',
  });

  @override
  MapLayer<MapLayerDescription> create(String id) => _MapRoutingLayer(id, this);
}

class _MapRoutingLayer extends MapLayer<MapRoutingLayer> {
  _MapRoutingLayer(super.id, super.description);

  String get metricsId => id + description.metricsIdSuffix;

  String get nometricsId => id + description.nometricsIdSuffix;

  @override
  Future<void> register() async {
    final collection = description.path.toGeoJsonFeatureCollection();

    final ids = await controller.getSourceIds();
    if (ids.contains(metricsId) || ids.contains(nometricsId)) {
      return _setGeoJson(collection);
    }

    await Future.wait([
      // lineMetrics required to allow line gradients when rendering/in styles
      controller.addSource(metricsId, GeojsonSourceProperties(
        lineMetrics: true,
        data: collection,
      )),
      // Second data layer required for correct line-dasharray styles
      // because they are negatively affected by line metrics.
      // line-dasharray:
      // - doesn't support expressions (so dash array cannot be computed based on pre calculated length)
      // - scales with the length of the line when lineMetrics is specified (which is undesirable)
      controller.addSource(nometricsId, GeojsonSourceProperties(
        lineMetrics: false,
        data: collection,
      )),
    ]);
  }

  @override
  Future<void> update(oldDescription) {
    final collection = description.path.toGeoJsonFeatureCollection();
    return _setGeoJson(collection);
  }

  @override
  Future<void> unregister() {
    // remove source doesn't work here, so set empty path
    final collection = LiveRoute([]).toGeoJsonFeatureCollection();
    return _setGeoJson(collection);
  }

  Future<void> _setGeoJson(Map<String, dynamic> json) async {
    await Future.wait([
      controller.setGeoJsonSource(metricsId, json),
      controller.setGeoJsonSource(nometricsId, json),
    ]);
  }
}
