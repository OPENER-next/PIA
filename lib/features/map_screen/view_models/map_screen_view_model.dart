import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mobx/mobx.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:render_metrics/render_metrics.dart';

import '/shared/services/config_service.dart';
import '/shared/services/indoor_positioning_service.dart';
import '/shared/utils/reactor_mixin.dart';
import '/shared/models/position.dart';
import '/shared/models/per_pedes_routing/ppr.dart';
import '/shared/models/level.dart';
import '/shared/services/ppr_service.dart';
import '/shared/utils/indoor_level_controller.dart';
import '../widgets/map/layers/map_indoor_layer.dart';
import '../widgets/map/layers/map_position_layer.dart';
import '../widgets/map/layers/map_routing_layer.dart';
import '../widgets/map/layers/map_backdrop_layer.dart';
import '../widgets/map/map_layer_manager.dart';

class MapViewModel extends ViewModel with Reactor {
  MapViewModel() {
    react(
      (_) => indoorPosition,
      (_) => _updateIndoorPositionLayer(),
      fireImmediately: true,
    );

    react(
      (_) => indoorPosition,
      (_) => _requestRoutes(),
      delay: 1000,
    );

    react(
      (_) => destinationPosition,
      (_) {
        _requestRoutes();
        _updateDestinationLayer();
      }
    );

    react(
      (_) => routingPath,
      (_) => _updateRoutingLayer(),
    );

    react(
      (_) => _routingProfile.value,
      (_) => _requestRoutes(),
    );

    react(
      (_) => selectedRoute,
      (_) {
        if (!isNavigationActive) showRouteSelection();
      },
    );
  }

  final _isNavigationActive = Observable(false);
  bool get isNavigationActive => _isNavigationActive.value;


  // can only be used in overlay

  late MaplibreMapController mapController;

  final renderManager = RenderParametersManager<String>();

  final _ppr = PerPedesRoutingService();

  IndoorPositioningService get _indoorPositioningService => getService<IndoorPositioningService>();

  ConfigService get _configService => getService<ConfigService>();

  final levelController = IndoorLevelController(
    levels: {
      Level.fromNumber(-2): 'UG2',
      Level.fromNumber(-1): 'UG1',
      Level.fromNumber(0): 'EG',
      Level.fromNumber(1): 'OG1',
    },
  );

  late final mapLayerManager = MapLayerManager({
    'indoor-vector-tiles': MapIndoorLayer(levelController: levelController),
    'indoor-tint-layer': const MapBackdropLayer(),
  });


  Position? get indoorPosition => _indoorPositioningService.wgs84position;

  final _destinationPosition = Observable<Position?>(null);

  Position? get destinationPosition => _destinationPosition.value;

  set destinationPosition(Position? value) =>
    runInAction(() => _destinationPosition.value = value);

  // ROUTES \\

  final _routes = ObservableList<Route>();

  int get routeCount => _routes.length;

  bool get hasAnyRoutes => _routes.isNotEmpty;

  String  routeDistanceFormatted(int index) {
    final distance = _routes[index].details!.distance;
    return distance < 999
      ? '${distance.toStringAsFixed(0)}m'
      : '${(distance/1000).toStringAsFixed(2)}km';
  }

  String  routeDurationFormatted(int index) {
    final duration = _routes[index].details!.duration;
    return duration.toDurationString(
      round: false,
      dropPrefixOrSuffix: true,
      form: Abbreviation.semi,
      format: DurationFormat.ms,
    );
  }

  Future<void> _requestRoutes() async {
    if (indoorPosition != null && destinationPosition != null) {
      final routes = await _ppr.request(RoutingRequest(
        start: indoorPosition!,
        destination: destinationPosition!,
        profile: _routingProfile.value,
        includeEdges: true,
      ));
      runInAction(() {
        _routes.clear();
        _routes.addAll(routes);
        _routes.sort(_sortByDuration);
        // ensure if route count changes that the index is still valid
        selectRoute(math.min(selectedRouteIndex, routeCount - 1));
      });
    }
  }

  /// Sort route so that fastest come first
  ///
  /// When navigating we are constantly updating the routes
  /// We might get new routes or loose routes on the way
  /// That is why it is important to sort the routes

  int _sortByDuration(Route a, Route b) {
    return (a.details!.duration - b.details!.duration).inSeconds.toInt();
  }

  // ROUTE SELECTION \\

  // controller recreation important to be able to provide an inital page
  // the PageStorage with keepPage and PageStorageKey mostly worked but had some side effects
  final _routePageController = Observable<PageController?>(null);

  PageController? get routePageController => _routePageController.value;

  bool get routeSelectionVisible => routePageController != null;

  void showRouteSelection() {
    // in case the sheet is still hidden we need to postpone the execution
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _focusCurrentRoute();
    });
    runInAction(
      () => _routePageController.value = PageController(
        initialPage: selectedRouteIndex,
        keepPage: false,
      ),
    );
  }
  void hideRouteSelection() {
    runInAction(() {
      routePageController?.dispose();
      _routePageController.value = null;
    });
  }

  final _selectedRouteIndex = Observable(0);

  int get selectedRouteIndex => _selectedRouteIndex.value;
  void selectRoute(int index) {
    runInAction(() => _selectedRouteIndex.value = index);
  }

  Route? get selectedRoute {
    if (selectedRouteIndex > -1 && selectedRouteIndex < _routes.length) {
      return _routes[selectedRouteIndex];
    }
    return null;
  }

  late final _routingPath = Computed(() {
    if (indoorPosition != null && selectedRoute != null) {
      final route = MapRoutingPath.fromEdges(selectedRoute!.edges);
      if (route.isNotEmpty) {
        // always ignore start point and replace it with the current user location
        route.first.path[0] = indoorPosition!;
        return route;
      }
    }
    return null;
  });
  MapRoutingPath? get routingPath => _routingPath.value;

  void _focusCurrentRoute() {
    if (selectedRoute != null) {
      final sheetSize = renderManager.getRenderData('routesBottomSheet');
      final padding = const EdgeInsets.symmetric(horizontal: 60, vertical: 50)
        + EdgeInsets.only(bottom: sheetSize?.height ?? 0);

      mapController.animateCamera(CameraUpdate.newLatLngBounds(
        selectedRoute!.bounds,
        left: padding.left,
        top: padding.top,
        right: padding.right,
        bottom: padding.bottom,
      ));
    }
  }


  Future<void> connectToTracelet() async {
    _indoorPositioningService.connectTracelet();
  }

  late final _routingProfile = Computed<RoutingProfile>(() {
    return _configService.userProfile.toRoutingProfile();
  });

  void _updateRoutingLayer() {
    if (routingPath != null) {
      mapLayerManager.set('indoor-routing-path', MapRoutingLayer(
        path: routingPath!,
      ));
    }
    else {
      mapLayerManager.remove('indoor-routing-path');
    }
  }

  void _updateIndoorPositionLayer() {
    if (indoorPosition != null) {
      mapLayerManager.set('indoor-position', MapPositionLayer(
        position: indoorPosition!,
      ));
    }
    else {
      mapLayerManager.remove('indoor-position');
    }
  }

  void _updateDestinationLayer() {
    if (destinationPosition != null) {
      mapLayerManager.set('indoor-routing-destination', MapPositionLayer(
        position: destinationPosition!,
      ));
    }
    else {
      mapLayerManager.remove('indoor-routing-destination');
    }
  }

  @override
  void dispose() {
    levelController.dispose();
    _ppr.dispose();
    _indoorPositioningService.onDispose();
    routePageController?.dispose();
    super.dispose();
  }
}
