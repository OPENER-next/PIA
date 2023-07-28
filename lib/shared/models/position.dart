import 'package:latlong2/latlong.dart';

import 'level.dart';


class Position extends LatLng {
  final Level level;

  const Position(super.latitude, super.longitude, {
    this.level = Level.zero,
  });

  @override
  Map<String, double> toJson() => {
    'lat': latitude,
    'lng': longitude,
    'level': level.asNumber.toDouble(),
  };

  List<double> toGeoJsonCoordinates() => [longitude, latitude];

  factory Position.fromGeoJsonCoordinates(List<double> json) =>
    Position(json[1], json[0]);

  @override
  String toString() => 'Position(lat: $latitude, lon: $longitude, level: $level)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Position &&
      super == other && other.level == level;
  }

  @override
  int get hashCode => super.hashCode ^ level.hashCode;
}
