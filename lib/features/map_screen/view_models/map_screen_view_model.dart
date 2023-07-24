import 'package:flutter_mvvm_architecture/base.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import '/shared/models/position.dart';
import '/shared/models/per_pedes_routing/ppr.dart';
import '/shared/models/level.dart';
import '/shared/services/ppr_service.dart';
import '/shared/utils/indoor_level_controller.dart';
import '../widgets/map/layers/map_indoor_layer.dart';
import '../widgets/map/layers/map_indoor_position_layer.dart';
import '../widgets/map/layers/map_routing_layer.dart';
import '../widgets/map/map_layer_manager.dart';

class MapViewModel extends ViewModel {

  // can only be used in overlay

  late MaplibreMapController mapController;

  final _ppr = PerPedesRoutingService();

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
  });

  Future<void> setTargetLocation(Position position) async {
    final routes = await _ppr.request(
    RoutingRequest(
      start: Position(position.latitude, position.longitude),
      destination: Position(52.130351530779876, 11.628229022026064),
      profile: RoutingProfile(),
      includeEdges: true,
    ));

    mapLayerManager.set('indoor-routing-path', MapRoutingLayer(
      path: routes.first.indoorPath.toList(),
    ));
    mapLayerManager.set('indoor-position', MapIndoorPositionLayer(
      position: Position(position.latitude, position.longitude),
    ));
  }

  @override
  void dispose() {
    levelController.dispose();
    super.dispose();
  }
}
