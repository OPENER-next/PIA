import 'package:maplibre_gl/mapbox_gl.dart';


class MapLayerManager {
  final Map<String, MapLayer> _layers;

  MapLayerManager([ Map<String, MapLayerDescription> layers = const {} ]) :
    _layers = layers.map(
      (id, description) => MapEntry(id, description.create(id)),
    );

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

  Future<bool> set(String id, MapLayerDescription description) async {
    var isNew = false;

    final layer = _layers.putIfAbsent(id, () {
      isNew = true;
      return description.create(id);
    });

    if (_controller != null) {
      if (isNew) {
        await _registerLayer(layer);
      }
      else {
        await layer._update(description);
      }
    }
    return isNew;
  }

  Future<void> remove(String id) async {
    final layer = _layers.remove(id);
    if (layer != null) {
      await _unregisterLayer(layer);
    }
  }

  /// Should be called on hot reload.

  void reassemble() async {
    for (final layer in _layers.values) {
      await layer._update();
    }
  }


  Future<void> _registerLayers() async {
    for (final layer in _layers.values) {
      await _registerLayer(layer);
    }
  }

  Future<void> _registerLayer(MapLayer layer) async {
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

  Future<void> _unregisterLayers() async {
    for (final layer in _layers.values) {
      await _unregisterLayer(layer);
    }
  }

  Future<void> _unregisterLayer(MapLayer layer) async {
    await layer.unregister();
    layer._controller = null;
  }
}



// This construct works like Flutter's Widget (MapLayerDescription) and
// Element (MapLayer) or StatefulWidget and State separation.

/// Used to update a respective element layer.

abstract interface class MapLayerDescription {
  MapLayer create(String id);
}

/// The actual element layer.

abstract class MapLayer<T extends MapLayerDescription> {
  final String id;

  T _description;

  T get description => _description;

  MapLayer(this.id, T description) : _description = description;

  // Will be set by the MapLayerManager

  MaplibreMapController? _controller;

  MaplibreMapController get controller => _controller!;

  Future<void> register();

  Future<void> _update([T? description]) async {
    description ??= _description;
    final old = _description;
    _description = description;
    return update(old);
  }

  Future<void> update(T oldDescription);

  Future<void> unregister();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapLayer<T> && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}



mixin MapLayerStyleSupport<T extends MapLayerDescription> on MapLayer<T> {
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
