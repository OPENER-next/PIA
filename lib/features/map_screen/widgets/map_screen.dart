import 'package:flutter/material.dart' hide View;
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pia/features/map_screen/widgets/overlay/map_overlay.dart';

import '../view_models/map_screen_view_model.dart';
import '/shared/models/position.dart';
import 'map/map_view.dart';


class MapScreen extends View<MapViewModel> {
  MapScreen({ super.key }) : super(create: MapViewModel.new);

  @override
  Widget build(BuildContext context, viewModel) {
    return Scaffold(
      body: MapView(
        styleUrl: 'https://api.maptiler.com/maps/bright-v2/style.json?key=3Uam2soS3S9RCPvHdP7E',
        mapLayerManager: viewModel.mapLayerManager,
        initialCameraPosition: CameraPosition(
          target: LatLng(52.13079444242991, 11.627435088157656),
          zoom: 17,
          tilt: 180, // will be clamped to max tilt
        ),
        onMapLongClick: (p0, position) async {
          viewModel.destinationPosition = Position(
            position.latitude, position.longitude, level: viewModel.levelController.level
          );
        },
        overlayBuilder: (context, controller) {
          viewModel.mapController = controller;
          return MapOverlay();
        }
      ),
    );
  }
}
