import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:flutter_mvvm_architecture/extras.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'package:mobx/mobx.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:render_metrics/render_metrics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/live_route.dart';
import '../models/route_discomforts.dart';
import '/shared/models/deep_link_actions.dart';
import '/shared/services/deep_link_service.dart';
import '/shared/services/config_service.dart';
import '/shared/services/indoor_positioning_service.dart';
import '/shared/services/orientation_service.dart';
import '/shared/utils/reactor_mixin.dart';
import '/shared/models/position.dart';
import '/shared/models/per_pedes_routing/ppr.dart';
import '/shared/models/level.dart';
import '/shared/services/ppr_service.dart';
import '/shared/utils/indoor_level_controller.dart';
import '/shared/utils/indoor_location_derivative.dart';
import '../widgets/map/layers/map_indoor_layer.dart';
import '../widgets/map/layers/map_position_layer.dart';
import '../widgets/map/layers/map_routing_layer.dart';
import '../widgets/map/layers/map_backdrop_layer.dart';
import '../widgets/map/map_layer_manager.dart';

class MapViewModel extends ViewModel with Reactor, PromptMediator {
  MapViewModel() {
    react(
      (_) => indoorPosition,
      (_) {
        _updateIndoorPositionLayer();
        if (isTrackingPosition) {
          _updateCamera();
        }
        if (selectedRoute != null) {
          if (!selectedRoute!.fitTo(indoorPosition!, maxDeviation: 3)) {
            _requestRoutes();
          }
          _updateLevel();
        }
      },
      fireImmediately: true,
    );

    react(
      (_) => _orientationService.orientation,
      (_) {
        if (isTrackingPosition) {
          _updateCamera();
        }
      }
    );

    react(
      (_) => destinationPosition,
      (_) {
        _requestRoutes();
        _updateDestinationLayer();
      }
    );

    react(
      // listen to route selection changes and route modifications
      (_) => selectedRoute?.edges.length,
      (_) => _updateRoutingLayer(),
      // required since we return length
      equals: (p0, p1) => false,
    );

    react(
      (_) => _routingProfile.value,
      (_) => _requestRoutes(),
    );

    {
      // when profile or destination changes
      // wait till the first route change (response from PPR server)
      // then run a one time
      // Note: directly waiting on route changes will also fire to often like while navigating
      ReactionDisposer? awaitNewRoute;
      react(
        (_) {
          _routingProfile.value;
          destinationPosition;
        },
        (_) {
          awaitNewRoute?.call();
          awaitNewRoute = reaction((p0) => selectedRoute, (p0) {
            awaitNewRoute?.call();
            showRouteSelection();
          });
        },
        equals: (p0, p1) => false,
      );
      // when selection changes
      react(
        (_) => selectedRouteIndex,
        (_) => showRouteSelection(),
      );
    }

    // important: needs to be defined after the reactions are hooked up
    final deepLinkAction = getService<DeepLinkService>().consume<NavigateAction>();
    if (deepLinkAction != null) {
      setDestination(deepLinkAction.destination, () async {
        final localizations = AppLocalizations.of(context)!;
        final result = await promptUserInput(
          title: localizations.destinationReachedPromptTitle,
          message: localizations.destinationReachedPromptMessage,
          choices: {
            localizations.destinationReachedPromptStayButton: false,
            localizations.destinationReachedPromptReturnButton: true,
          },
          isDismissible: true,
        );
        if (result == true) {
          SystemNavigator.pop();
        }
      });
    }
  }


  // can only be used in overlay

  late ml.MaplibreMapController mapController;

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

  final _orientationService = OrientationService();

  // Workaround to derive level information for our specific scenario (using the location source and geo fences)
  // because we do not get any level information yet from the positioning engine
  late final _indoorPosition = IndoorLocationDerivative(
    () => _indoorPositioningService.currentPositionPackage,
  );
  Position? get indoorPosition => _indoorPosition.position;

  final _trackPosition = Observable(false);
  togglePositioningTracking() {
    runInAction(() => _trackPosition.value = ! _trackPosition.value);
    if (_trackPosition.value) {
      // workaround to reset padding to navigation mode
      final p =  ml.LatLng(indoorPosition!.latitude, indoorPosition!.longitude);
      mapController.moveCamera(
        ml.CameraUpdate.newLatLngBounds(
          selectedRoute?.bounds ?? ml.LatLngBounds(northeast: p, southwest: p),
          top: 150,
        ),
      );
      _updateCamera();
    }
    else {
      mapController.animateCamera(
        ml.CameraUpdate.tiltTo(0),
        duration: const Duration(milliseconds: 500),
      );
    }
  }
  bool get isTrackingPosition => _trackPosition.value;

  final _destinationPosition = Observable<Position?>(null);

  Position? get destinationPosition => _destinationPosition.value;

  // used to register a single one time reaction when the destination is reached
  ReactionDisposer? _destinationReachedDisposer;
  setDestination(Position? value, [VoidCallback? onReached]) {
    runInAction(() => _destinationPosition.value = value);
    // always clear any previous destination reaction
    _destinationReachedDisposer?.call();
    // optionally register new destination reaction
    if (onReached != null) {
      _destinationReachedDisposer = when(
        (_) => destinationPosition != null &&
               indoorPosition != null &&
               Circle(destinationPosition!, 3).isPointInside(indoorPosition!) &&
               destinationPosition!.level == indoorPosition!.level,
        onReached,
      );
    }
  }

  void clearDestination() {
    runInAction(() {
      setDestination(null);
      _routes.clear();
      selectRoute(0);
    });
  }

  // ROUTES \\

  final _routes = ObservableList<LiveRoute>();

  int get routeCount => _routes.length;

  bool get hasAnyRoutes => _routes.isNotEmpty;

  String routeDistanceFormatted(int index) {
    final distance = _routes[index].distance;
    return distance < 999
      ? '${distance.toStringAsFixed(0)}m'
      : '${(distance/1000).toStringAsFixed(2)}km';
  }

  String routeDurationFormatted(int index) {
    final duration = _routes[index].duration;
    return duration.toDurationString(
      round: false,
      dropPrefixOrSuffix: true,
      form: Abbreviation.semi,
      format: DurationFormat.ms,
    );
  }

  RouteDiscomforts routeDiscomforts(int index) {
    return RouteDiscomforts(
      route: _routes[index],
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
        _routes.addAll(routes.map(LiveRoute.fromRawRoute));
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

  int _sortByDuration(LiveRoute a, LiveRoute b) {
    return (a.duration - b.duration).inSeconds.toInt();
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

  LiveRoute? get selectedRoute {
    if (selectedRouteIndex < _routes.length && selectedRouteIndex > -1) {
      return _routes[selectedRouteIndex];
    }
    return null;
  }

  void _focusCurrentRoute() {
    if (selectedRoute != null) {
      final sheetSize = renderManager.getRenderData('routesBottomSheet');
      final padding = const EdgeInsets.symmetric(horizontal: 60, vertical: 50)
        + EdgeInsets.only(bottom: sheetSize?.height ?? 0);

      mapController.animateCamera(ml.CameraUpdate.newLatLngBounds(
        selectedRoute!.bounds,
        left: padding.left,
        top: padding.top,
        right: padding.right,
        bottom: padding.bottom,
      ));
    }
  }

  late final _routingProfile = Computed<RoutingProfile>(() {
    return _configService.userProfile.toRoutingProfile();
  });

  void _updateRoutingLayer() {
    if (selectedRoute != null) {
      mapLayerManager.set('indoor-routing-path', MapRoutingLayer(
        path: selectedRoute!,
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

  void _updateLevel() {
    if (indoorPosition != null) {
      levelController.changeLevel(indoorPosition!.level);
    }
  }

  void _updateCamera() {
    if (indoorPosition != null) {
      mapController.animateCamera(
        ml.CameraUpdate.newCameraPosition(ml.CameraPosition(
          bearing: _orientationService.orientation / pi * 180,
          target: ml.LatLng(indoorPosition!.latitude, indoorPosition!.longitude),
          zoom: 21,
          tilt: 60,
        )), duration: const Duration(milliseconds: 500),
      );
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
    routePageController?.dispose();
    _orientationService.dispose();
    super.dispose();
  }
}
