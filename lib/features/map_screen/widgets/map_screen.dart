import 'package:flutter/material.dart' hide View;
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:flutter_mvvm_architecture/extras.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../widgets/overlay/map_overlay.dart';
import '../view_models/map_screen_view_model.dart';
import '/shared/models/position.dart';
import 'map/map_view.dart';


class MapScreen extends View<MapViewModel> with PromptHandler {
  const MapScreen({ super.key }) : super(create: MapViewModel.new);

  @override
  Widget build(BuildContext context, viewModel) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MapView(
        styleUrl: 'https://api.maptiler.com/maps/1263a335-3d81-4ba9-9fcf-310c8d3b4534/style.json?key=3Uam2soS3S9RCPvHdP7E',
        mapLayerManager: viewModel.mapLayerManager,
        initialCameraPosition: const CameraPosition(
          target: LatLng(52.13079444242991, 11.627435088157656),
          zoom: 17,
        ),
        onMapLongClick: (p0, position) async {
          viewModel.setDestination(Position(
            position.latitude, position.longitude, level: viewModel.levelController.level
          ), viewModel.clearDestination);
        },
        overlayBuilder: (context, controller) {
          viewModel.mapController = controller;
          return const MapOverlay();
        }
      ),
    );
  }
}
