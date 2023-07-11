import 'package:flutter/material.dart';

import '/shared/models/position.dart';
import '/shared/utils/indoor_level_controller.dart';
import 'map/map_view.dart';
import 'map/map_layer_manager.dart';
import 'map/layers/map_routing_layer.dart';
import 'map/layers/map_indoor_layer.dart';
import 'overlay/indoor_level_bar.dart';


class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  final _levelController = IndoorLevelController(
    levels: {-1: '-1', 0: 'EG', 1: 'OG1', 2: 'OG2', 3: 'OG3'},
  );

  late final _mapLayerManager = MapLayerManager([
    MapIndoorLayer(_levelController),
    MapRoutingLayer([
      Position( 51.0257624, 13.7227283, level: 1 ),
      Position( 51.0256934, 13.7231176, level: 1 ),
      Position( 51.0254485, 13.7230115, level: 1 ),
      Position( 51.0253990, 13.7232873, level: 1 ),
      Position( 51.0253433, 13.7232624, level: 1 ),
      Position( 51.0253433, 13.7232624, level: 0 ),
      Position( 51.0252868, 13.7232387, level: 0 ),
      Position( 51.0253017, 13.7231613, level: 0 ),
      Position( 51.0255040, 13.7232477, level: 0 ),
    ]),
  ]);

  @override
  Widget build(BuildContext context) {
    return MapView(
      styleUrl: 'https://api.maptiler.com/maps/bright-v2/style.json?key=3Uam2soS3S9RCPvHdP7E',
      mapLayerManager: _mapLayerManager,
      overlayBuilder: (context, controller) {
        return Padding(
          padding: MediaQuery.of(context).padding + EdgeInsets.all(10),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: controller,
                builder: (_, child) => AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: controller.cameraPosition!.zoom >= 16 ? child : null,
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: AnimatedBuilder(
                    animation: _levelController,
                    builder: (_, __) => IndoorLevelBar(
                      levels: _levelController.levels,
                      active: _levelController.level,
                      onSelect: _levelController.changeLevel,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _levelController.dispose();
    super.dispose();
  }
}
