import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'map_layer_manager.dart';


typedef OverlayBuilder = Widget Function(
  BuildContext context,
  MaplibreMapController mapController,
);


class MapView extends StatefulWidget {
  final String styleUrl;

  final OverlayBuilder? overlayBuilder;

  final MapLayerManager? mapLayerManager;

  final LatLng initialPosition;

  final double initialZoom;

  const MapView({
    required this.styleUrl,
    this.mapLayerManager,
    this.overlayBuilder,
    this.initialPosition = const LatLng(51.02549, 13.72344),
    this.initialZoom = 17,
  });

  @override
  State createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MaplibreMapController? _mapController;

  var _styleLoaded = false;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.of(context).padding + EdgeInsets.all(10);

    return Stack(
      children: [
        MaplibreMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: widget.initialZoom,
          ),
          trackCameraPosition: true,
          onStyleLoadedCallback: _onStyleLoaded,
          styleString: widget.styleUrl,
          attributionButtonPosition: AttributionButtonPosition.BottomLeft,
          attributionButtonMargins: Point(viewPadding.left, viewPadding.bottom),
        ),
        if (widget.overlayBuilder != null && _styleLoaded)
          widget.overlayBuilder!(context, _mapController!),
      ],
    );
  }

  void _onMapCreated(MaplibreMapController controller) async {
    setState(() {
      _mapController = controller;
    });
  }

  void _onStyleLoaded() {
    setState(() {
      _styleLoaded = true;
      widget.mapLayerManager?.controller = _mapController!;
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
