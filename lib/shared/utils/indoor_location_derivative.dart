import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:maps_toolkit/maps_toolkit.dart' as mt;
import 'package:mobx/mobx.dart';

import '../models/level.dart';
import '../models/position.dart';
import '../models/position_package.dart';


class IndoorLocationDerivative {
  final PositionPackage? Function() _location;

  IndoorLocationDerivative(this._location);

  late final _position = Computed<Position?>(() {
    final locationPackage = _location();
    if (locationPackage == null) {
      return null;
    }
    final location = locationPackage.position;
    final level = locationPackage.source == PositionSource.locationService
      ? Level.fromNumber(0)
      : _getLevelByGeoFence(location, fallback: Level.fromNumber(0));
    return Position(location.latitude, location.longitude, level: level);
  });
  Position? get position => _position.value;

  Level _getLevelByGeoFence(LatLng loc, {required Level fallback}) {
    for (final geoFence in _geoFences) {
      if (mt.PolygonUtil.containsLocationAtLatLng(
        loc.latitude, loc.longitude, geoFence.coordinates, true,
      )) {
        Logger.root.info('Entering GeoFence ${geoFence.debugLabel} switching to level ${geoFence.level}');
        return geoFence.level;
      }
    }
    return fallback;
  }

  // Geo fences to level matching for Magdeburg central tran station
  // Overpass query to quickly created geo fences based on OSM elements (rooms)

  /*
  [out:json][timeout:205];

  way(id:1169949598, 1232666219);
  convert U2
  ::geom = geom();
  out geom;

  way(id:1169949599);
  convert U1
  ::geom = geom();
  out geom;
  */

  static final _geoFences = <_Fence>[
    _Fence('Tunnel - U2',
      Level.fromNumber(-2),
      [
        mt.LatLng(52.1306207,11.6261426),
        mt.LatLng(52.1306421,11.6261488),
        mt.LatLng(52.1306441,11.6261306),
        mt.LatLng(52.1306461,11.6261124),
        mt.LatLng(52.1306486,11.6260898),
        mt.LatLng(52.1306429,11.6260882),
        mt.LatLng(52.1306571,11.6259593),
        mt.LatLng(52.1306681,11.6258597),
        mt.LatLng(52.1306931,11.6256319),
        mt.LatLng(52.1306987,11.6255814),
        mt.LatLng(52.1307014,11.6255572),
        mt.LatLng(52.1306849,11.6255525),
        mt.LatLng(52.1306684,11.6255478),
        mt.LatLng(52.1306518,11.6255431),
        mt.LatLng(52.1306353,11.6255384),
        mt.LatLng(52.1306006,11.625854),
        mt.LatLng(52.1305704,11.6261279),
        mt.LatLng(52.130581,11.626131),
        mt.LatLng(52.1305917,11.6261341),
        mt.LatLng(52.130593,11.6261216),
        mt.LatLng(52.1306076,11.6261258),
        mt.LatLng(52.1306221,11.6261301),
        mt.LatLng(52.1306207,11.6261426),
      ],
    ),

    _Fence(
      'Backwerk - U2',
      Level.fromNumber(-2),
      [
        mt.LatLng(52.1306987,11.6255814),
        mt.LatLng(52.1307468,11.6255955),
        mt.LatLng(52.1307052,11.6259734),
        mt.LatLng(52.1306571,11.6259593),
        mt.LatLng(52.1306681,11.6258597),
        mt.LatLng(52.1306931,11.6256319),
        mt.LatLng(52.1306987,11.6255814),
      ],
    ),

    _Fence(
      'Vorzelt Richtung ZOB bis Treppen - U2',
      Level.fromNumber(-2),
      [
        mt.LatLng(52.13070514744183,11.625557184615019),
        mt.LatLng(52.13071445534064,11.625489312817933),
        mt.LatLng(52.13077961057962,11.625508807908432),
        mt.LatLng(52.130787588765884,11.625433715707004),
        mt.LatLng(52.13082349058462,11.625426495302804),
        mt.LatLng(52.130820831192125,11.625388949202545),
        mt.LatLng(52.1307884752309,11.625394725525041),
        mt.LatLng(52.130796010182564,11.625356457384385),
        mt.LatLng(52.13052076199335,11.625265480294559),
        mt.LatLng(52.13053982110168,11.625457543040113),
        mt.LatLng(52.130643537965796,11.625483536494471),
        mt.LatLng(52.130640878561934,11.625540577686195),
        mt.LatLng(52.13070514744183,11.625557184615019),
      ],
    ),

    _Fence(
      'Vorzelt Richtung ZOB bis Treppen - U1',
      Level.fromNumber(-1),
      [
        mt.LatLng(52.1307955803785,11.625356473628216),
        mt.LatLng(52.13083288404938,11.62515936559754),
        mt.LatLng(52.13081459136507,11.625036653260466),
        mt.LatLng(52.13077080172968,11.624999554624821),
        mt.LatLng(52.13065411749312,11.62509801827693),
        mt.LatLng(52.13053607914547,11.62504798847101),
        mt.LatLng(52.13048122265122,11.625134017080413),
        mt.LatLng(52.130515866192155,11.625265819353245),
        mt.LatLng(52.1307955803785,11.625356473628216),
      ],
    ),

    _Fence('Tunnel - U1',
      Level.fromNumber(-1),
      [
        mt.LatLng(52.1305704,11.6261279),
        mt.LatLng(52.1305669,11.6261594),
        mt.LatLng(52.1305635,11.6261909),
        mt.LatLng(52.1305334,11.6264645),
        mt.LatLng(52.1305227,11.6264614),
        mt.LatLng(52.1305205,11.6264816),
        mt.LatLng(52.1305183,11.6265018),
        mt.LatLng(52.1305244,11.6265036),
        mt.LatLng(52.1305211,11.6265343),
        mt.LatLng(52.1305189,11.6265336),
        mt.LatLng(52.1305178,11.6265436),
        mt.LatLng(52.1305161,11.6265594),
        mt.LatLng(52.1305102,11.6266127),
        mt.LatLng(52.1305042,11.6266675),
        mt.LatLng(52.1304987,11.6267173),
        mt.LatLng(52.1304931,11.6267681),
        mt.LatLng(52.1304886,11.6268088),
        mt.LatLng(52.130479,11.6268966),
        mt.LatLng(52.1304772,11.6269128),
        mt.LatLng(52.1304745,11.6269367),
        mt.LatLng(52.1304791,11.6269381),
        mt.LatLng(52.1304764,11.6269629),
        mt.LatLng(52.1304676,11.6269603),
        mt.LatLng(52.1304651,11.6269829),
        mt.LatLng(52.1304626,11.6270056),
        mt.LatLng(52.1304714,11.6270082),
        mt.LatLng(52.1304451,11.6272473),
        mt.LatLng(52.1304363,11.6272447),
        mt.LatLng(52.1304333,11.6272723),
        mt.LatLng(52.1304302,11.6273),
        mt.LatLng(52.130439,11.6273025),
        mt.LatLng(52.1304172,11.6275013),
        mt.LatLng(52.1304083,11.6274987),
        mt.LatLng(52.1304053,11.6275259),
        mt.LatLng(52.1304023,11.6275532),
        mt.LatLng(52.1304112,11.6275557),
        mt.LatLng(52.1303999,11.6276588),
        mt.LatLng(52.1303922,11.6276566),
        mt.LatLng(52.1303894,11.6276822),
        mt.LatLng(52.1303877,11.6276981),
        mt.LatLng(52.1303859,11.6277139),
        mt.LatLng(52.1303854,11.6277183),
        mt.LatLng(52.1303824,11.6277462),
        mt.LatLng(52.1303794,11.6277731),
        mt.LatLng(52.1303789,11.6277781),
        mt.LatLng(52.130406,11.6277861),
        mt.LatLng(52.1304332,11.627794),
        mt.LatLng(52.1304448,11.6277974),
        mt.LatLng(52.1304432,11.6278118),
        mt.LatLng(52.1304551,11.6278153),
        mt.LatLng(52.130467,11.6278188),
        mt.LatLng(52.1304687,11.6278029),
        mt.LatLng(52.1304739,11.6277555),
        mt.LatLng(52.1304757,11.6277395),
        mt.LatLng(52.1304824,11.6277415),
        mt.LatLng(52.1304807,11.6277574),
        mt.LatLng(52.1305099,11.6277659),
        mt.LatLng(52.1305307,11.6277719),
        mt.LatLng(52.1305368,11.6277737),
        mt.LatLng(52.1305386,11.6277578),
        mt.LatLng(52.13068,11.6277991),
        mt.LatLng(52.1306828,11.627774),
        mt.LatLng(52.1306855,11.627749),
        mt.LatLng(52.1305441,11.6277077),
        mt.LatLng(52.1305448,11.6277009),
        mt.LatLng(52.1305138,11.6276919),
        mt.LatLng(52.1304625,11.627677),
        mt.LatLng(52.1304664,11.6276419),
        mt.LatLng(52.1304705,11.627605),
        mt.LatLng(52.1304743,11.6275704),
        mt.LatLng(52.1305002,11.627578),
        mt.LatLng(52.1305027,11.6275554),
        mt.LatLng(52.1305051,11.6275328),
        mt.LatLng(52.1304746,11.6275239),
        mt.LatLng(52.1304976,11.6273151),
        mt.LatLng(52.1305206,11.6273218),
        mt.LatLng(52.1305231,11.627299),
        mt.LatLng(52.1305256,11.6272762),
        mt.LatLng(52.1305026,11.6272695),
        mt.LatLng(52.1305199,11.6271114),
        mt.LatLng(52.1305247,11.6270678),
        mt.LatLng(52.1305294,11.627025),
        mt.LatLng(52.1305949,11.627044),
        mt.LatLng(52.1305959,11.6270354),
        mt.LatLng(52.1305999,11.6269986),
        mt.LatLng(52.1305188,11.626975),
        mt.LatLng(52.1305211,11.6269539),
        mt.LatLng(52.1305267,11.6269555),
        mt.LatLng(52.1305309,11.6269169),
        mt.LatLng(52.1305368,11.6268627),
        mt.LatLng(52.1305414,11.6268214),
        mt.LatLng(52.1305459,11.6267795),
        mt.LatLng(52.130599,11.6267949),
        mt.LatLng(52.1307759,11.6268458),
        mt.LatLng(52.1308013,11.6268535),
        mt.LatLng(52.130824,11.6268604),
        mt.LatLng(52.1308225,11.6268734),
        mt.LatLng(52.1308331,11.6268766),
        mt.LatLng(52.1308505,11.6268818),
        mt.LatLng(52.1309109,11.6268992),
        mt.LatLng(52.1309123,11.6268863),
        mt.LatLng(52.1310607,11.6269295),
        mt.LatLng(52.1310622,11.6269159),
        mt.LatLng(52.1310663,11.6268791),
        mt.LatLng(52.1310678,11.6268655),
        mt.LatLng(52.1309194,11.6268221),
        mt.LatLng(52.1309208,11.6268092),
        mt.LatLng(52.1308766,11.6267962),
        mt.LatLng(52.1308324,11.6267833),
        mt.LatLng(52.130831,11.6267963),
        mt.LatLng(52.1306062,11.6267309),
        mt.LatLng(52.1305531,11.6267154),
        mt.LatLng(52.1305574,11.6266762),
        mt.LatLng(52.1305642,11.6266146),
        mt.LatLng(52.1305689,11.6265718),
        mt.LatLng(52.1305726,11.6265385),
        mt.LatLng(52.1305691,11.6265375),
        mt.LatLng(52.1305714,11.6265171),
        mt.LatLng(52.1306156,11.62653),
        mt.LatLng(52.1306186,11.6265029),
        mt.LatLng(52.1306195,11.6264942),
        mt.LatLng(52.1305718,11.6264803),
        mt.LatLng(52.1306024,11.6262022),
        mt.LatLng(52.1306806,11.6262251),
        mt.LatLng(52.130684,11.6261936),
        mt.LatLng(52.1306875,11.6261621),
        mt.LatLng(52.1306915,11.6261256),
        mt.LatLng(52.130676,11.6261211),
        mt.LatLng(52.130674,11.6261393),
        mt.LatLng(52.130672,11.6261576),
        mt.LatLng(52.1306421,11.6261488),
        mt.LatLng(52.1306207,11.6261426),
        mt.LatLng(52.1306221,11.6261301),
        mt.LatLng(52.1306076,11.6261258),
        mt.LatLng(52.130593,11.6261216),
        mt.LatLng(52.1305917,11.6261341),
        mt.LatLng(52.130581,11.626131),
        mt.LatLng(52.1305704,11.6261279),
      ]
    ),
  ];
}


class _Fence {
  final String debugLabel;
  final Level level;
  final List<mt.LatLng> coordinates;
  _Fence(this.debugLabel, this.level, this.coordinates);

  @override
  String toString() => debugLabel;
}
