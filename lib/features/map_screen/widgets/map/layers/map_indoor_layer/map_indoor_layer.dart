import 'dart:async';

import 'package:maplibre_gl/mapbox_gl.dart';

import 'style_definition.dart';
import '/shared/utils/indoor_level_controller.dart';
import '../../map_layer_manager.dart';

class MapIndoorLayer implements MapLayerDescription {
  final IndoorLevelController levelController;

  const MapIndoorLayer({
    required this.levelController,
  });

  @override
  _MapIndoorLayer create(String id) => _MapIndoorLayer(id, this);
}

class _MapIndoorLayer extends MapLayer<MapIndoorLayer> with MapLayerStyleSupport {
  // TODO: currently this is hard coded and extracted manually from the theme/style, but it depends on the style that is used
  final belowLayerId = 'waterway';

  _MapIndoorLayer(super.id, super.description);

  Future<void> register() async {
    await controller.addSource(id, VectorSourceProperties(
      url: 'https://tiles.indoorequal.org/?key=iek_3sf20d7fK0dzUhvVBcrOEg3YR6X1'
    ));
    await addJSONLayers(layers, belowLayerId: belowLayerId);

    description.levelController.addListener(_handleLevelChange);
    await _handleLevelChange();
  }

  Future<void> update(oldDescription) async {
    if (description != oldDescription) {
      oldDescription.levelController.removeListener(_handleLevelChange);
      description.levelController.addListener(_handleLevelChange);
      await _handleLevelChange();
    }
  }

  Future<void> unregister() async {
   description.levelController.removeListener(_handleLevelChange);
    await controller.removeSource(id);
    await removeJSONLayers(layers);
  }


  /// Update the map filter for the provided layers based on the level controllers level.

  Future<void> _handleLevelChange() async {
    final level = description.levelController.level.asNumber.toInt();
    // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
    final levelFilter = [
      'any',
      ['==', ['ceil', ['to-number', ['get', 'level']]], level],
      ['==', ['floor', ['to-number', ['get', 'level']]], level],
    ];
    await Future.wait(
      layers.map(
        (layer) {
          final newFilter = [
            'all',
            if (layer['filter'] is List<dynamic>) layer['filter'],
            levelFilter
          ];
          return controller.setFilter(layer['id'] as String, newFilter);
        }
      )
    );
  }
}


  // Timer? _debounce;


  // void _handleMapViewChange () {
  //   if (_debounce?.isActive != true) {
  //     _debounce = Timer(const Duration(milliseconds: 500), () async {
  //       final renderBox = context.findRenderObject() as RenderBox?;
  //       if (renderBox != null) {
  //         final position = renderBox.localToGlobal(Offset.zero);
  //         widget.levelController?.levels = await _extractLevels(
  //           position & renderBox.size,
  //           widget.layers.map<String>((l) => l['id']).toList(),
  //         );
  //       }
  //     });
  //   }
  // }

  // TODO: querySourceFeatures is currently unimplemented
  // Future<Map<num, String>> _extractLevels(Rect viewRect, List<String> layerIds) async {
  //   final features = await widget.controller.querySourceFeatures(
  //     viewRect,
  //     layerIds,
  //     null,
  //   );

  //   for (final feature in features) {
  //     //print(feature['properties']['level']);
  //   }
  // }
