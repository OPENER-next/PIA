part of 'positioning_service.dart';

class TraceletPositioningService extends PositioningService {
  TraceletPositioningService({
    required this.channel,
    required this.referenceLatitude,
    required this.referenceLongitude,
    required this.referenceAzimuth,
  });

  final int channel;

  /// Latitude of the origin
  final double referenceLatitude;

  /// Longitude of the origin
  final double referenceLongitude;

  /// Azimuth of the origin
  final double referenceAzimuth;

  Stream<bool> get connectionStatus => _connectionController.stream;

  final StreamController<bool> _connectionController =
      StreamController.broadcast();

  // ------------------  Tracelet Positioning -------------------//

  Timer _traceletScanTimer = Timer(Duration.zero, () {});

  final _traceletLog = Logger('Tracelet Positioning API');

  final _easyLocateSdk = EasyLocateSdk();

  TraceletApi? _positioningApi;

  /// Searches for a tracelet and when it finds one connects to it and starts positioning
  Future<void> _findTracelet() async {
    _traceletScanTimer = Timer(const Duration(minutes: 5), () {
      _traceletLog.warning(
          'No tracelets found. Tracelet Positioning could not take place!');
    });

    // Registers the scanListener to look for bluetooth tracelet devices
    final scanListener = BluetoothScanListener();
    _traceletLog.info('Start Scanning for Tracelets');
    while (_traceletScanTimer.isActive) {
      await _easyLocateSdk.startTraceletScan(
        scanListener,
        scanTimeout: const Duration(seconds: 2),
      );
      // Gets the closest bluetooth tracelet available
      final bluetoothTracelet = scanListener.bleDevice;
      // Stops bluetooth tracelet scanning
      await _easyLocateSdk.stopBleScan();
      if (bluetoothTracelet != null) {
        _traceletLog.info('Tracelets Found ${bluetoothTracelet.name}');
        _startTraceletPositioning(bluetoothTracelet);
        _traceletScanTimer.cancel();
        _traceletLog.info('Stop Scanning');
        break;
      }
    }
  }

  /// Connects to the Tracelet on Channel 5 with the closest RSSI value, and starts monitoring the positions.
  ///
  /// Steps:
  /// 1.Scan for the closest tracelet
  /// 2. Connects to the closest tracelet if available
  /// 3. Displays a blue flashing light on the connected tracelet
  /// 3. Sets the channel to 5, the positioning interval to 250ms and motion check interval to 0ms. (Default values used)
  /// 4. Sets the reference wgs84 position. This is the wgs84 position of the origin
  /// 5. Starts positioning
  void _startTraceletPositioning(BleDevice bluetoothTracelet) async {
    try {
      // Continue only if a ble Tracelet is found
      // Connect to the bluetooth tracelet
      _traceletLog.info('Connecting to Tracelet');
      _positioningApi =
          await _easyLocateSdk.connectBleTracelet(bluetoothTracelet,
              listener: ConnectionListener(onConnected: () async {
                _connectionController.add(true);
                _traceletLog.info(
                    'Tracelet Connected. To verify look for a blue flashing light on the device');
                // A blue LED blinks on the connected device. This can be used to verify if you're connected to the right device
                await _positioningApi!.showMe();

                _traceletLog.info('Setting channel to Channel 5');
                // Set the channel to 5 (6.5 GHz). For dw1k tracelets, channel setting is not required as the tracelets operate only on 6.5Ghz
                final channelStatus = await _positioningApi!
                    .setRadioSettings(Channel.FIVE)
                    .timeout(const Duration(seconds: 3));
                channelStatus
                    ? _traceletLog.info('Channel Set Successfully')
                    : _traceletLog.shout('Channel Not Set');
                // Sets the reference wgs84 position. This should be the wgs84 position of the origin
                // By default the tracelet does not know its position in LatLng coordinates,
                // but instead it know the distance in meters from the origin, and it uses the
                // wgs84 coordinates of the origin to find its own position in the real world
                _traceletLog.info('Setting reference wgs84 position');
                await _positioningApi!.setWgs84Reference(
                    referenceLatitude, referenceLongitude, referenceAzimuth);
                // Sets the positioning interval to 250ms. This means that we can get 4 position values every second
                _traceletLog.info('Setting up positioning interval');
                await _positioningApi!.setPositioningInterval(1);

                // Sets the motion check interval to 0. This disables checking if there is motion on the tracelet
                _traceletLog.info('Setting up motion check interval');
                await _positioningApi!.setMotionCheckInterval(0);

                // Start positioning. Uses the position listener to get wgs84 values
                _traceletLog.info('Start Positioning');
                await _positioningApi!.startPositioning(
                    PositionListener(onWgs84PositionUpdated: (position) {
                  final traceletPosition = LatLng(position.lat, position.lon);
                  final traceletPositionPackage = PositionPackage(
                      position: traceletPosition,
                      source: PositionSource.tracelet,
                      accuracy: position.acc);
                  _traceletLog.info('Position Received : $traceletPosition');
                  _controller.add(traceletPositionPackage);
                }));
              }, onDisconnected: () {
                runInAction(() {
                  _connectionController.add(false);
                });
                // Takes 1 second after disconnectTracelet() runs to execute
                _traceletLog.info('Tracelet Disconnected');
              }));
    } on Exception catch (error) {
      runInAction(() {
        _connectionController.add(false);
      });
      _traceletLog.info(error.toString());
    }
  }

  /// Disconnects from a Tracelet and stops scanning if a scan is still in progress
  Future<void> _stopTraceletPositioning() async {
    _traceletScanTimer.cancel();
    _traceletLog.info('Stopping tracelet positioning');
    if (_positioningApi != null) {
      _traceletLog.info('Disconnecting Tracelet');
      await _positioningApi!.stopPositioning();
      // The tracelet takes 1s to disconnect
      _positioningApi!.disconnect();
      _positioningApi = null;
    }
  }

  @override
  void _onCancel() async {
    await _stopTraceletPositioning();
  }

  @override
  void _onListen() {
    _findTracelet();
  }

  @override
  void close() {
    _connectionController.close();
    super.close();
  }
}

// Listener that receives information when a tracelet is connected/ disconnected
class ConnectionListener extends ConnectionStateListener {
  final VoidCallback? onDisconnected;
  final VoidCallback? onConnected;

  ConnectionListener({this.onDisconnected, this.onConnected});

  @override
  void onConnectionStateChanged(bool connected) {
    if (connected == false) {
      onDisconnected?.call();
    } else {
      onConnected?.call();
    }
  }
}

/// Listener that receives positioning data as local positions (meters) / wgs84 positions
class PositionListener extends TagPositionListener {
  final void Function(Wgs84Position wgs84position)? onWgs84PositionUpdated;

  PositionListener({this.onWgs84PositionUpdated});

  @override
  void onLocalPosition(LocalPosition localPosition) {}

  @override
  void onWgs84Position(Wgs84Position wgs84position) {
    onWgs84PositionUpdated?.call(wgs84position);
  }
}

/// Listener for bluetooth tracelet devices
class BluetoothScanListener extends BleScanListener {
  BleDevice? _bleDevice;

  /// Available list of satlets sorted according to their proximity to the device
  BleDevice? get bleDevice => _bleDevice;

  @override
  void onDeviceApproached(BleDevice bleDevice) {
    _bleDevice = bleDevice;
  }

  @override
  void onScanResults(List<BleDevice> bleDevices) {}
}
