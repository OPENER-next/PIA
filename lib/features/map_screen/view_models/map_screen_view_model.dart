import 'dart:async';

import 'package:flutter_mvvm_architecture/base.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:mobx/mobx.dart';
import 'package:pia/shared/services/indoor_positioning_service.dart';

import '/shared/utils/reactor_mixin.dart';
import '/shared/models/position.dart';
import '/shared/models/per_pedes_routing/ppr.dart';
import '/shared/models/level.dart';
import '/shared/services/ppr_service.dart';
import '/shared/utils/indoor_level_controller.dart';
import '../widgets/map/layers/map_indoor_layer.dart';
import '../widgets/map/layers/map_indoor_position_layer.dart';
import '../widgets/map/layers/map_routing_layer.dart';
import '../widgets/map/layers/map_backdrop_layer.dart';
import '../widgets/map/map_layer_manager.dart';

class MapViewModel extends ViewModel with Reactor {
  MapViewModel() {
    const distance = Distance();

    react(
      (_) => indoorPosition,
      (_) => _updateMapLayers(),
    );

    react(
      (_) => indoorPosition,
      (_) => _recalculateRouting(),
      equals: (next, curr) {
        // only update when position passed certain distance threshold
        return (next == curr) || (next != null && curr != null && distance.distance(next, curr) < 1);
      },
      delay: 1000,
    );

    react(
      (_) => destinationPosition,
      (_) => _recalculateRouting(),
    );

    react(
      (_) => routingPath,
      (_) => _updateMapLayers(),
    );
  }

  // can only be used in overlay

  late MaplibreMapController mapController;

  final _ppr = PerPedesRoutingService();

  final _indoorPositioningService = IndoorPositioningService(
    referenceLatitude: 52.130351530779876,
    referenceLongitude: 11.628229022026064,
    referenceAzimuth: 0,
  );

  final levelController = IndoorLevelController(
    levels: {
      Level.fromNumber(-2): 'UG2',
      Level.fromNumber(-1): 'UG1',
      Level.fromNumber(0): 'EG',
      Level.fromNumber(1): 'OG1',
      Level.fromNumber(2): 'OG2',
    },
  );

  late final mapLayerManager = MapLayerManager({
    'indoor-vector-tiles': MapIndoorLayer(levelController: levelController),
    'indoor-tint-layer': MapBackdropLayer(),
  });


  Position? get indoorPosition => _indoorPositioningService.wgs84position; // _in.value;

  final _destinationPosition = Observable<Position?>(null);

  Position? get destinationPosition => _destinationPosition.value;

  void set destinationPosition(Position? value) =>
    runInAction(() => _destinationPosition.value = value);

  final _route = Observable<Route?>(null);

  late final _routingPath = Computed(() {
    if (indoorPosition != null && _route.value != null) {
      // always ignore start point and replace it with the current user location
      return [
        indoorPosition!,
        ..._route.value!.indoorPath.skip(1),
      ];
    }
    return null;
  });

  List<Position>? get routingPath => _routingPath.value;


  Future<void> connectToTracelet() async {
    _indoorPositioningService.connectTracelet();
  }


  Future<void> _recalculateRouting() async {
    if (indoorPosition != null && destinationPosition != null) {
      final routes = await _ppr.request(RoutingRequest(
        start: indoorPosition!,
        destination: destinationPosition!,
        profile: RoutingProfile(),
        includeEdges: true,
      ));
      runInAction(() => _route.value = routes.first);
    }
  }


  void _updateMapLayers() {
    if (indoorPosition != null) {
      mapLayerManager.set('indoor-position', MapIndoorPositionLayer(
        position: indoorPosition!,
      ));
    }
    else {
      mapLayerManager.remove('indoor-position');
    }
    if (routingPath != null) {
      mapLayerManager.set('indoor-routing-path', MapRoutingLayer(
        path: routingPath!,
      ));
    }
    else {
      mapLayerManager.remove('indoor-routing-path');
    }
  }


  @override
  void dispose() {
    levelController.dispose();
    _ppr.dispose();
    _indoorPositioningService.onDispose();
    super.dispose();
  }
}
