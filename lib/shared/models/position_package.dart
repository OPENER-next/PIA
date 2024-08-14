import 'package:latlong2/latlong.dart';

enum PositionSource {
  tracelet,
  locationService,
  fusion;
}

class PositionPackage {
  final LatLng position;
  final PositionSource source;
  final double accuracy;

  const PositionPackage({
    required this.position,
    required this.source,
    required this.accuracy,
  });

  bool get isPositionNotZero => position.latitude != 0 && position.longitude != 0;
}
