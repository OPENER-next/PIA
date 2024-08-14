import 'dart:async';

import 'package:flutter_mvvm_architecture/base.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

import '../models/position_package.dart';
import 'positioning_service.dart';

/// Combines positions received when using a UWB Tracelet and also real time positions from the geolocator package, and fuses them using the kalman filter
/// To start positioning use the function [startPositioning].
/// To stop positioning use the function [stopPositioning].

class IndoorPositioningService extends Service implements Disposable {
  IndoorPositioningService({
    required this.referenceLatitude,
    required this.referenceLongitude,
    required this.referenceAzimuth,
  });

  factory IndoorPositioningService.fromJson(Map<String, dynamic> json) =>
      IndoorPositioningService(
        referenceLatitude: json['originLatitude'],
        referenceLongitude: json['originLongitude'],
        referenceAzimuth: json['originAzimuth'],
      );

  /// Latitude of the origin
  final double referenceLatitude;

  /// Longitude of the origin
  final double referenceLongitude;

  /// Azimuth of the origin
  final double referenceAzimuth;

  // ------------------  Current LatLng Positions -------------------//

  final Observable<PositionPackage?> _currentPositionPackage = Observable(null);

  /// A package containing the current position, accuracy and the source
  PositionPackage? get currentPositionPackage => _currentPositionPackage.value;

  // ------------------  Start and Stop Positioning -------------------//

  final Observable<bool> _isPositioning = Observable(false);

  bool get isPositioning => _isPositioning.value;

 /// Starts Positioning
  void startPositioning() {
    runInAction(() => _isPositioning.value = true);
    startFusion();
  }

  /// Stops Positioning
  void stopPositioning() {
    runInAction(() => _isPositioning.value = false);
    stopFusion();
  }

  // ------------------  System Fusion -------------------//

  late final FusedPositioningService fusedPositionService =
      FusedPositioningService(
          gnssPositionStream: geolocationPositioningService.positions,
          uwbPositionStream: traceletPositioningService.positions,
          referenceLatitude: referenceLatitude,
          referenceLongitude: referenceLongitude,
          referenceAzimuth: referenceAzimuth);

  StreamSubscription<PositionPackage>? fusionPositionSubscription;

  /// Starts listening to fusedPositions from the tracelet and the location services
  void startFusion() {
    fusionPositionSubscription =
        fusedPositionService.positions.listen((fusionPackage) {
      runInAction(() => _currentPositionPackage.value = fusionPackage);
    });
  }

  /// Stops listening to fusedPositions
  void stopFusion() {
    fusionPositionSubscription?.cancel();
  }

  // ------------------  GeoLocation -------------------//
  final GeolocationPositionService geolocationPositioningService =
      GeolocationPositionService();

  StreamSubscription<PositionPackage>? geolocationPositionSubscription;

  /// Starts listening to real time positions from platform specific location services
  void starGeolocation() {
    geolocationPositionSubscription =
        geolocationPositioningService.positions.listen((geoPositionPackage) {
      runInAction(() => _currentPositionPackage.value = geoPositionPackage);
    });
  }

  /// Stops listening to platform specific location services
  void stopGeolocation() {
    geolocationPositionSubscription?.cancel();
  }

  // ------------------  Tracelet Positioning -------------------//

  late final TraceletPositioningService traceletPositioningService =
      TraceletPositioningService(
          channel: 5,
          referenceLatitude: referenceLatitude,
          referenceLongitude: referenceLongitude,
          referenceAzimuth: referenceAzimuth);

  StreamSubscription<PositionPackage>? traceletPositionSubscription;


  /// Starts listening to positions from a connected Tracelet
  void startTraceletPositioning() {
    traceletPositionSubscription =
        traceletPositioningService.positions.listen((indoorPosition) {
      runInAction(() => _currentPositionPackage.value = indoorPosition);
    });
  }

  /// Stops listening to positions from a connected Tracelet
  void stopTraceletPositioning() {
    traceletPositionSubscription?.cancel();
  }

  @override
  FutureOr onDispose() {
    stopPositioning();
  }
}

