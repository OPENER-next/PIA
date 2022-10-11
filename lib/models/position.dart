import 'package:maplibre_gl/mapbox_gl.dart';


class Position extends LatLng {
  final num level;

  const Position(super.latitude, super.longitude, {
    this.level = 0,
  });
}
