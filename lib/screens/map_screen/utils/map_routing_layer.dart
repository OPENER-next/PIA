import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import '/shared/utils/map_layer_manager.dart';

// NEXT:
// - move this style to the json layer style
// - add "source" property for layer in style and use this if available in indoor_layer
// GOAL, showing/hiding of path dependent on level

class MapRoutingLayer extends MapLayer {
  final sourceId = 'trace';
  final layerId = 'trace';
  // TODO: currently this is hard coded and extracted manually from the theme/style, but it depends on the style that is used
  final belowLayerId = 'waterway';

  Future<void> register() async {
    await controller.addGeoJsonSource(sourceId, _createGeoJsonSource());
    await controller.addLayer(sourceId, layerId,
      LineLayerProperties(
        lineColor: Colors.blueAccent.toHexStringRGB(),
        lineWidth: 8,
        lineJoin: 'round',
        lineCap: 'round',
      ),
      belowLayerId: belowLayerId,
    );
  }


  Map<String, dynamic> _createGeoJsonSource() => {
    "type": "FeatureCollection",
    "features": [{
      "type": "Feature",
      "properties": {},
      "geometry": {
        'type': 'LineString',
        "coordinates": [
          [ 13.72360, 51.02534 ],
          [ 13.72301, 51.02545 ],
          [ 13.72312, 51.02569 ]
        ],
      },
    }]
  };

  Future<void> unregister() async {
    await controller.removeSource(sourceId);
    await controller.removeLayer(layerId);
  }
}
