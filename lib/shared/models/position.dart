import 'package:maplibre_gl/mapbox_gl.dart';

import 'level.dart';


class Position extends LatLng {
  final Level level;

  const Position(super.latitude, super.longitude, {
    this.level = Level.zero,
  });
}
