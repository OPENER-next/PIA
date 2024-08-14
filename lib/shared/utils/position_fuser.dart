import 'package:vector_math/vector_math.dart';

/// A position fuser that uses kalman filter to combine incoming positions from gnss and uwb sources.
class PositionFuser {
  Vector2? _position;

  Matrix2? _covariance;

  /// The time when the PositionFuser was last updated
  DateTime? _timeOfLastUpdate;

  bool _isInitialised = false;

  /// The last estimated position
  Vector2? get position => _position;

  /// The last estimated covariance
  Matrix2? get covariance => _covariance;

  /// Returns true if the PositionFuser is already initialized
  bool get isInitialised => _isInitialised;

  /// Updates the time, and the covariance based on the uncertainty in the system model
  void timeUpdate(DateTime time) {
    if (_timeOfLastUpdate != null) {
      final timeDiff = time.difference(_timeOfLastUpdate!);
      if (_isInitialised) {
        //predicted change in position for a person walking is considered to be around 5 km/h,
        const positionVariance = 5.0 / 3.6;
        // Generally Represented by Q in the Kalman filter, this can be considered as the amount of uncertainty in the system model
        final Matrix2 systemUncertainty = Matrix2.identity() *
            (timeDiff.inMilliseconds / 1000.0 * positionVariance);
        // Calculates the new covariance when based on the previous error and the uncertainty in the system model
        _covariance = _covariance! + systemUncertainty;
      }
    }
    _timeOfLastUpdate = time;
  }

  /// Updates the position and covariance based on Kalman filter which requires the new measurement and covariance.
  void measurementUpdate(Vector2 measuredPosition, Matrix2 measuredCovariance) {
    if (_isInitialised) {
      // The predicted uncertainty takes into account the previous error estimate and the current error from the measurement
      final predictedUncertainty = _covariance! + measuredCovariance;
      predictedUncertainty.invert();
      // The kalman gain takes into account the error in the measurement and the error the predicted value
      final kalmanGain = _covariance! * predictedUncertainty;
      // The residual is the difference between the new position(measured) and the value predicted by the filter
      final residual = measuredPosition - _position!;
      // Calculates the new position and covariance based on the kalman gain and the residual
      _position = _position! + (kalmanGain * residual);
      _covariance = (Matrix2.identity() - kalmanGain) * _covariance!;
    } else {
      if (_timeOfLastUpdate != null) {
        _position = measuredPosition;
        _covariance = measuredCovariance;
        _isInitialised = true;
      }
    }
  }
}
