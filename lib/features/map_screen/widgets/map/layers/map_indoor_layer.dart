import 'dart:async';

import 'package:maplibre_gl/mapbox_gl.dart';

import 'style_definition.dart';
import '/shared/utils/indoor_level_controller.dart';
import '../map_layer_manager.dart';

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
    await Future.wait(
      layers
      .where((layer) => layer['filter'] is List)
      .map((layer) {
        final newFilter = _nestedReplaceWhere(
          layer['filter'] as List,
          _levelVariableReplacer,
        );
        return controller.setFilter(layer['id'] as String, newFilter);
      }),
    );
  }

  /// Substitutes occurrences of `["let", "level", "0", ...]` with the current level.

  dynamic _levelVariableReplacer(dynamic item) {
    if (item is List && item[0] == 'let' && item[1] == 'level') {
      final level = description.levelController.level.asNumber.toInt();
      return [item[0], item[1], level, ...item.skip(3)];
    }
    return item;
  }

  /// Recursively replaces items in a nested List based on a replacer function.
  ///
  /// In this case it is used to replace values in mapbox expressions.
  ///
  /// This returns a new List with nested List.

  List _nestedReplaceWhere(List nestedLists, Function(dynamic item) replacer) {
    // run replacer once for every list (including top level list)
    nestedLists = replacer(nestedLists);
    return nestedLists.map<dynamic>((item) {
      if (item is List) {
        return _nestedReplaceWhere(item, replacer);
      }
      // run replacer for every list item and sub items
      return replacer(item);
    }).toList(growable: false);
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
