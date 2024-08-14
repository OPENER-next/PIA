import 'dart:math';

import 'package:easylocate_flutter_sdk/utils/geotools.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math.dart';

extension LocalPositionTransformer on Wgs84Reference {
  /// Returns local Vector2 positions from real world latLng coordinates.
  Vector2 convertToVector2(LatLng latLng) {
    final deltaX = (latLng.longitude - lonRef) / 360.0 * (2 * pi * radiusLat);

    final deltaY = (latLng.latitude - latRef) / 360.0 * (2 * pi * RADIUS_MEAN);

    final x = deltaX * cos(-aziRadians) + deltaY * sin(-aziRadians);
    final y = -deltaX * sin(-aziRadians) + deltaY * cos(-aziRadians);

    return Vector2(x, y);
  }
}

extension MapPositionTransformer on Wgs84Reference {
  /// Returns  Real world latLng coordinates from Vector2 local positions
  LatLng convertToLatLng(Vector2 position) {
    final deltaX = position.x * cos(aziRadians) + position.y * sin(aziRadians);
    final deltaY = -position.x * sin(aziRadians) + position.y * cos(aziRadians);

    final deltaLon = 360.0 * deltaX / (2 * pi * radiusLat);
    final deltaLat = 360.0 * deltaY / (2 * pi * RADIUS_MEAN);

    return LatLng(latRef + deltaLat, lonRef + deltaLon);
  }
}
