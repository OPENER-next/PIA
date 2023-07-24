import 'dart:async';

import 'package:easylocate_flutter_sdk/cmds/commands.dart';
import 'package:easylocate_flutter_sdk/easylocate_sdk.dart';
import 'package:easylocate_flutter_sdk/tracelet_api.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:get_it/get_it.dart';

import 'package:mobx/mobx.dart';

/// Provides functionality to connect to a uwb tracelet, and receive position values

/// To start positioning use the function[connectTracelet].
/// To stop positioning use the function[disconnectTracelet].

class IndoorPositioningService implements Disposable {
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

  // ------------------  Connection Status -------------------//

  final Observable<bool> _isConnected = Observable(false);

  /// Return true if a tracelet is connected, and false otherwise
  bool get isConnected => _isConnected.value;

  // ------------------  Current Wgs84 Position -------------------//

  final Observable<Wgs84Position?> _wgs84Position = Observable(null);

  /// Returns the current wgs84 position from a tracelet. If no position found returns null
  Wgs84Position? get wgs84position => _wgs84Position.value;

  // ------------------  EasyLocate SDK -------------------//

  final _easyLocateSdk = EasyLocateSdk();

  TraceletApi? _positioningApi;

  // ------------------  Bluetooth device -------------------//

  final Observable<BleDevice?> _bluetoothTracelet = Observable(null);

  /// Retrieves the currently connected bluetooth tracelet. Null when no device is found
  BleDevice? get bluetoothTracelet => _bluetoothTracelet.value;

  // ------------------  Tracelet Connecting & Disconnecting-------------------//

  /// Connects to the Tracelet on Channel 5 with the closest RSSI value, and starts monitoring the positions.
  ///
  /// Steps:
  /// 1.Scan for the closest tracelet
  /// 2. Connects to the closest tracelet if available
  /// 3. Displays a blue flashing light on the connected tracelet
  /// 3. Sets the channel to 5, the positioning interval to 250ms and motion check interval to 0ms. (Default values used)
  /// 4. Sets the reference wgs84 position. This is the wgs84 position of the origin
  /// 5. Starts positioning
  void connectTracelet() async {
    try {
      // Registers the scanListener to look for bluetooth tracelets
      final scanListener = BluetoothScanListener();
      EasyLocateSdk easyLocateSdk = EasyLocateSdk();
      // Starts scanning and looks for tracelets for 5 seconds
      debugPrint('Start Scanning for Tracelets');
      await easyLocateSdk.startTraceletScan(
        scanListener,
        scanTimeout: 5,
      );
      // Gets the closest bluetooth tracelet available
      final bluetoothTracelet = scanListener.bleDevice;
      debugPrint('Tracelets Found ${bluetoothTracelet?.name}');
      // Stops bluetooth tracelet scanning
      await easyLocateSdk.stopBleScan();
      debugPrint('Stop Scanning');

      // Continue only if a ble Tracelet is found
      if (bluetoothTracelet != null) {
        // Connect to the bluetooth tracelet
        debugPrint('Connecting to Tracelet');
        _positioningApi = await _easyLocateSdk.connectBleTracelet(
          bluetoothTracelet,
          ConnectionListener(
            onConnected: () async {
              runInAction(() => _isConnected.value = true);
              debugPrint(
                  'Tracelet Connected. To verify look for a blue flashing light on the device');
              // A blue LED blinks on the connected device. This can be used to verify if you're connected to the right device
              await _positioningApi!.showMe();

              debugPrint('Setting channel to Channel 5');
              // Set the channel to 5 (6.5 GHz). For dw1k tracelets, channel setting is not required as the tracelets operate only on 6.5Ghz
              final channelStatus = await _positioningApi!
                  .setChannel(Channel.FIVE)
                  .timeout(const Duration(seconds: 3));
              debugPrint(channelStatus
                  ? 'Channel Set Successfully '
                  : 'Channel Not Set');

              // Sets the reference wgs84 position. This should be the wgs84 position of the origin
              // By default the tracelet does not know its position in LatLng coordinates,
              // but instead it know the distance in meters from the origin, and it uses the
              // wgs84 coordinates of the origin to find its own position in the real world
              debugPrint('Setting reference wgs84 position');
              await _positioningApi!.setWgs84Reference(
                  referenceLatitude, referenceLongitude, referenceAzimuth);

              // Sets the positioning interval to 250ms. This means that we can get 4 position values every second
              debugPrint('Setting up positioning interval');
              await _positioningApi!.setPositioningInterval(1);

              // Sets the motion check interval to 0. This disables checking if there is motion on the tracelet
              debugPrint('Setting up motion check interval');
              await _positioningApi!.setMotionCheckInterval(0);

              // Start positioning. Uses the position listener to get wgs84 values
              debugPrint('Start Positioning');
              await _positioningApi!.startPositioning(
                PositionListener(
                  onWgs84PositionUpdated: (position) {
                    runInAction(
                      () => _wgs84Position.value = position,
                    );
                  },
                ),
              );
            },
            onDisconnected: () {
              runInAction(() {
                _isConnected.value = false;
                _bluetoothTracelet.value = null;
                _wgs84Position.value = null;
              });
              // Takes 1 second after disconnectTracelet() runs to execute
              debugPrint('Tracelet Disconnected');
            },
          ),
        );
      }
    } on Exception catch (error) {
      runInAction(() {
        _bluetoothTracelet.value = null;
        _isConnected.value = false;
        _wgs84Position.value = null;
      });
      debugPrint(error.toString());
    }
  }

  /// Disconnects from a Tracelet
  void disconnectTracelet() async {
    if (_positioningApi != null) {
      debugPrint('Disconnecting Tracelet');
      await _positioningApi!.stopPositioning();
      // The tracelet takes 1s to disconnect
      _positioningApi!.disconnect();
      _positioningApi = null;
    }
  }

  @override
  FutureOr onDispose() {
    if (_positioningApi != null) {
      debugPrint(' Disconnecting Tracelet');
      _positioningApi!.disconnect();
    }
    debugPrint('Service disposed successfully');
  }
}

/// Listener that receives information when a tracelet is connected/ disconnected
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
