import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import '/shared/static/layer.dart';
import '/shared/utils/indoor_level_controller.dart';
import '../map_layer_manager.dart';


class MapIndoorLayer extends MapLayer with MapLayerStyleSupport {
  final sourceId = 'indoor-vector-tiles';
  // TODO: currently this is hard coded and extracted manually from the theme/style, but it depends on the style that is used
  final belowLayerId = 'waterway';

  final IndoorLevelController? levelController;

  MapIndoorLayer([this.levelController]);

  Future<void> register() async {
    await controller.addSource(sourceId, VectorSourceProperties(
      url: 'https://tiles.indoorequal.org/?key=iek_3sf20d7fK0dzUhvVBcrOEg3YR6X1'
    ));
    await addJSONLayers(layers, belowLayerId: belowLayerId);

    levelController?.addListener(_handleLevelChange);
    await _handleLevelChange();
  }

  /// Update the map filter for the provided layers based on the level controllers level.

  Future<void> _handleLevelChange() async {
    await Future.wait(
      layers.map(
        (layer) => controller.setFilter(layer['id'] as String,
          // combine existing layer filter with additional filter for level
          [
            ...(layer['filter'] as List<dynamic>? ?? ['all']),
            // without toString the filter won't work
            ['==', 'level',  levelController?.level.toString() ?? '0']
          ],
        ),
      )
    );
  }

  Future<void> unregister() async {
    levelController?.removeListener(_handleLevelChange);
    await controller.removeSource(sourceId);
    await removeJSONLayers(layers);
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
