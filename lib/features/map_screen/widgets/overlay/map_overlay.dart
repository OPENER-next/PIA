import 'package:flutter/material.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '../../view_models/map_screen_view_model.dart';
import 'indoor_level_bar.dart';

class MapOverlay extends ViewFragment<MapViewModel> {
  final void Function()? onZoomInPressed;
  final void Function()? onZoomOutPressed;

  const MapOverlay({
    Key? key,
    this.onZoomInPressed,
    this.onZoomOutPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, viewModel) {
    return Padding(
      padding: MediaQuery.of(context).padding + EdgeInsets.all(10),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: viewModel.mapController,
            builder: (_, child) => AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
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
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.small(
              child: Icon(Icons.wifi_find_rounded),
              onPressed: viewModel.connectToTracelet,
            ),
          ),
        ],
      ),
    );
  }
}
