import 'package:flutter/material.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '/features/poi_finder/widgets/poi_finder_view.dart';
import '../../view_models/map_screen_view_model.dart';
import 'indoor_level_bar.dart';

class MapOverlay extends ViewFragment<MapViewModel> {
  final void Function()? onZoomInPressed;
  final void Function()? onZoomOutPressed;

  const MapOverlay({
    super.key,
    this.onZoomInPressed,
    this.onZoomOutPressed,
  });

  @override
  Widget build(BuildContext context, viewModel) {
    return Padding(
      padding: MediaQuery.of(context).padding + const EdgeInsets.all(10),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: viewModel.mapController,
            builder: (_, child) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: viewModel.mapController.cameraPosition!.zoom >= 16 ? child : null,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedBuilder(
                animation: viewModel.levelController,
                builder: (_, __) => IndoorLevelBar(
                  levels: viewModel.levelController.levels,
                  active: viewModel.levelController.level,
                  onSelect: viewModel.levelController.changeLevel,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  onPressed: viewModel.connectToTracelet,
                  child: const Icon(Icons.wifi_find_rounded),
                ),
                FloatingActionButton.small(
                  onPressed: viewModel.connectToTracelet,
                  child: POIFinderView(
                    onSelection: (poi) {
                      viewModel.destinationPosition = poi.position;
                    },
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}
