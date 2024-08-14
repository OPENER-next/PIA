part of 'positioning_service.dart';

class GeolocationPositionService extends PositioningService {
// ------------------  GeoLocation -------------------//

  final _geolocatorLog = Logger('Geolocator Positioning');

  StreamSubscription<Position>? _positionStream;

  final LocationSettings locationSettings = const LocationSettings();

  /// Starts listening to real time positions from platform specific location services
  void _starGeolocation() {
    _geolocatorLog.info('Starting Geolocation');
    try {
      _positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position? position) {
        if (position != null) {
          final gnssPosition = LatLng(position.latitude, position.longitude);
          final positionPackage = PositionPackage(
              position: gnssPosition,
              source: PositionSource.locationService,
              accuracy: position.accuracy);
          _controller.add(positionPackage);
          _geolocatorLog.info('Package Received : $positionPackage');
        }
      }, onDone: () {
        _geolocatorLog.info('Stopped Listening to GeoLocations');
      }, onError: (error) {
        _geolocatorLog.shout(error);
      });
    } on Exception catch (error) {
      _geolocatorLog.shout(error);
    }
  }


  @override
  void _onCancel() async {
    _geolocatorLog.info('Stopping Geolocation');
    /// Stops listening to platform specific location services
    _positionStream?.cancel();
  }

  @override
  void _onListen() {
    _starGeolocation();
  }
}
