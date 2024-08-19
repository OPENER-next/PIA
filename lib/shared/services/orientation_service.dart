import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobx/mobx.dart';


class OrientationService {
  final _orientation = Observable(0.0);
  double get orientation => _orientation.value;

  final Duration orientationUpdateInterval;

  StreamSubscription<SensorEvent>? _orientationStreamSub;

  OrientationService({
    this.orientationUpdateInterval = const Duration(milliseconds: 200),
  }) {
    _setupRotationSensorStream();
  }

  void _setupRotationSensorStream() async {
    if (await SensorManager().isSensorAvailable(Sensors.ROTATION)) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ROTATION,
        interval: orientationUpdateInterval,
      );
      _orientationStreamSub = stream.listen(_handleAbsoluteOrientationEvent);
    }
  }

  void _cleanupRotationSensorStream() {
    _orientationStreamSub?.cancel();
    _orientationStreamSub = null;
  }

  void _handleAbsoluteOrientationEvent(SensorEvent event) {
    const piDoubled = 2 * pi;
    final double newOrientation;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // ios provides azimuth in degrees
      newOrientation = degToRadian(event.data.first);
    }
    else if (defaultTargetPlatform == TargetPlatform.android) {
      final g = event.data;
      final norm = sqrt(g[0] * g[0] + g[1] * g[1] + g[2] * g[2] + g[3] * g[3]);
      // normalize and set values to commonly known quaternion letter representatives
      final x = g[0] / norm;
      final y = g[1] / norm;
      final z = g[2] / norm;
      final w = g[3] / norm;
      // calc azimuth in radians
      final sinA = 2.0 * (w * z + x * y);
      final cosA = 1.0 - 2.0 * (y * y + z * z);
      final azimuth = atan2(sinA, cosA);
      // convert from [-pi, pi] to [0,2pi]
      newOrientation = (piDoubled - azimuth) % piDoubled;
    }
    else {
      newOrientation = 0;
    }
    runInAction(() => _orientation.value = newOrientation);
  }

  void dispose() {
    _cleanupRotationSensorStream();
  }
}
