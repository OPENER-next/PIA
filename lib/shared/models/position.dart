import 'package:maplibre_gl/mapbox_gl.dart';

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
  };

  factory Position.fromGeoJsonCoordinates(List<double> json) =>
    Position(json[1], json[0]);

  @override
  String toString() => 'Position(lat: $latitude, lon: $longitude, level: $level)';
}
