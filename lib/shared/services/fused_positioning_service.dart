part of 'positioning_service.dart';

class FusedPositioningService extends PositioningService {
  FusedPositioningService({
    required double referenceLatitude,
    required double referenceLongitude,
    required double referenceAzimuth,
    this.gnssPositionStream,
    this.uwbPositionStream,
    this.updateInterval = const Duration(
      milliseconds: 250,
    ),
  }) : _wgs84reference = Wgs84Reference(
            referenceLatitude, referenceLongitude, referenceAzimuth);

  final Wgs84Reference _wgs84reference;

  // Interval of the kalman filter
  final Duration updateInterval;

  final Stream<PositionPackage>? uwbPositionStream;

  final Stream<PositionPackage>? gnssPositionStream;

  // Gnss accuracy threshold for fusion
  static const _gnssAccuracyThreshold = 15.0;

  // Uwb accuracy threshold for fusion
  static const _uwbAccuracyThreshold = 3.0;

  // The number of seconds to wait for a UWB position before considering GNSS
  static const _uwbWaitTimeInSeconds = 3;

  /// The last timestamp for a valid uwb position
  DateTime _lastUwbTimeStamp = DateTime.now();

  late final positionFuser = PositionFuser();

  /// The last know position source that influences the fused Position. This is generally the source that has the most accurate position
  PositionSource _positionSource = PositionSource.fusion;

  // ------------------  System Fusion -------------------//

  final _fusionLog = Logger('Fusion Positioning');

  StreamSubscription? _gnssPositionSubscription;

  StreamSubscription? _uwbPositionSubscription;

  Timer _fusionTimer = Timer(Duration.zero, () {});

  @override
  void _onListen() {
    _fusionLog.info('Starting Position Fusion');
    _gnssPositionSubscription =
        gnssPositionStream?.listen(_registerGnssPosition);
    _uwbPositionSubscription = uwbPositionStream?.listen(_registerUwbPosition);
    _fusionTimer = Timer.periodic(updateInterval, (timer) {
      _updatePositionFuser();
    });
  }

  /// Calculates the accuracy from the covariance
  static double _calculateAcc(Matrix2 covarianceMatrix) {
    final covXxYySum = covarianceMatrix.row0.x + covarianceMatrix.row1.y;
    final covXxYyProduct = covarianceMatrix.row0.x * covarianceMatrix.row1.y;
    final double covXyYxProduct =
        covarianceMatrix.row0.y * covarianceMatrix.row1.x;
    final a = covXxYySum / 2;
    final b = covXxYyProduct - covXyYxProduct;
    final var1 = a + sqrt(a * a - b);
    final var2 = a - sqrt(a * a - b);
    return sqrt(max(var1, var2));
  }

  /// Updates the stream with a fused position
  _updatePositionFuser() {
    if (positionFuser.isInitialised) {
      positionFuser.timeUpdate(DateTime.now());
      if (positionFuser.position != null && positionFuser.covariance != null) {
        final fusedPosition =
            _wgs84reference.convertToLatLng(positionFuser.position!);
        final fusedPositionPackage = PositionPackage(
            position: fusedPosition,
            source: _positionSource,
            accuracy: _calculateAcc(positionFuser.covariance!));
        _fusionLog.info('Package Received : $fusedPositionPackage');
        _controller.add(fusedPositionPackage);
      }
    }
  }

  /// Registers a uwb position on the fuser if certain conditions are met
  void _registerUwbPosition(PositionPackage positionPackage) {
    final currentTimestamp = DateTime.now();
    positionFuser.timeUpdate(currentTimestamp);
    if (positionPackage.accuracy > 0 &&
        positionPackage.accuracy < _uwbAccuracyThreshold) {
      _fusionLog.info('Updating UWB Measurement');
      _positionSource = PositionSource.tracelet;
      _lastUwbTimeStamp = currentTimestamp;
      positionFuser.measurementUpdate(
          _wgs84reference.convertToVector2(positionPackage.position),
          Matrix2.identity() *
              (positionPackage.accuracy * positionPackage.accuracy));
    }
  }

  /// Registers a gnss position on the fuser if certain conditions are met
  void _registerGnssPosition(PositionPackage positionPackage) {
    final currentTimestamp = DateTime.now();
    // Calculates the time between the last valid uwb position received and now.
    final uwbTimeDiff = currentTimestamp.difference(_lastUwbTimeStamp);
    positionFuser.timeUpdate(currentTimestamp);
    if ((positionPackage.isPositionNotZero) &&
        positionPackage.accuracy < _gnssAccuracyThreshold &&
        // Waits for a period to receive a uwb position. If a valid uwb position exists in this time we don't consider gnss
        uwbTimeDiff.inSeconds >= _uwbWaitTimeInSeconds) {
      _fusionLog.info('Updating GNSS Measurement');
      _positionSource = PositionSource.locationService;
      positionFuser.measurementUpdate(
          _wgs84reference.convertToVector2(positionPackage.position),
          Matrix2.identity() *
              (positionPackage.accuracy * positionPackage.accuracy));
    }
  }

  @override
  void _onCancel() {
    _fusionLog.info('Stop Position Fusion');
    _gnssPositionSubscription?.cancel();
    _uwbPositionSubscription?.cancel();
    _fusionTimer.cancel();
  }
}
