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

  final CameraPosition initialCameraPosition;

  final void Function(Point<double>, LatLng)? onMapClick;

  final void Function(Point<double>, LatLng)? onMapLongClick;

  const MapView({
    required this.styleUrl,
    this.mapLayerManager,
    this.overlayBuilder,
    this.initialCameraPosition = const CameraPosition(
      bearing: 0.0,
      target: LatLng(51.02549, 13.72344),
      tilt: 0.0,
      zoom: 17,
    ),
    this.onMapClick,
    this.onMapLongClick,
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
          onMapClick: widget.onMapClick,
          onMapLongClick: widget.onMapLongClick,
          onMapCreated: _onMapCreated,
          initialCameraPosition: widget.initialCameraPosition,
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
