import 'package:maplibre_gl/mapbox_gl.dart';


class MapLayerManager {
  final List<MapLayer> _layers;

  MapLayerManager([ this._layers = const [] ]);

  MaplibreMapController? _controller;

  set controller(MaplibreMapController value) {
    if (_controller != value) {
      if (_controller != null) {
        _unregisterLayers();
      }
      _controller = value;
      _registerLayers();
    }
  }

  Future<void> _registerLayers() async {
    for (final layer in _layers) {
      assert(_controller != null);
      layer._controller = _controller;
      try {
        await layer.register();
      }
      catch(e) {
        // swallow errors for now
        print(e);
      }
    }
  }

  Future<void> _unregisterLayers() async {
    for (final layer in _layers) {
      await layer.unregister();
      layer._controller = null;
    }
  }
}



abstract class MapLayer {
  MaplibreMapController? _controller;

  MaplibreMapController get controller => _controller!;

  Future<void> register();

  Future<void> unregister();
}



mixin MapLayerStyleSupport on MapLayer {
  Future<void> addJSONLayers(List<Map<String, dynamic>> layers, { String? belowLayerId }) async {
    await Future.wait(
      layers.map(
        (layer) => controller.addLayer(
          layer['source'] as String,
          layer['id'] as String,
          _createLayerPropertiesFromJson(layer),
          sourceLayer: layer['source-layer'] as String?,
          filter: layer['filter'],
          // add all non symbol layers below first symbol layer to avoid overlaps
          belowLayerId: layer['type'] != 'symbol' ? belowLayerId : null,
        ),
      )
    );
  }

  Future<void> removeJSONLayers(List<Map<String, dynamic>> layers) async {
    await Future.wait(
      layers.map(
        (layer) => controller.removeLayer(layer['id'] as String),
      ),
    );
  }

  LayerProperties _createLayerPropertiesFromJson(Map<String, dynamic> layer) {
    // merge json
    final json = mapFromMultiple([
      (layer['paint'] as Map<String, dynamic>?),
      (layer['layout'] as Map<String, dynamic>?),
    ]);

    switch (layer['type']) {
      case 'fill':
        return FillLayerProperties.fromJson(json);
      case 'line':
        return LineLayerProperties.fromJson(json);
      case 'circle':
        return CircleLayerProperties.fromJson(json);
      case 'symbol':
        return SymbolLayerProperties.fromJson(json);
      case 'raster':
        return RasterLayerProperties.fromJson(json);
      case 'hillshade':
        return HillshadeLayerProperties.fromJson(json);
      default: throw StateError('Unknown Layer type.');
    }
  }
}

/// Merge multiple maps together.
/// Note: the order of the Maps in the iterable is important.
/// Keys from preceding maps will be overridden by subsequent maps.
Map<A, B> mapFromMultiple<A,B>(Iterable<Map<A, B>?> maps) => {
  for (final map in maps) ...?map,
};
