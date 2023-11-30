import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:latlong2/latlong.dart';

import '../models/poi_collection.dart';
import '/shared/models/pois.dart';


/// This class exposes API calls for querying [POI]s via the Overpass API.

class POIQueryService {

  static const _bboxQuery =
    r'[out:json][timeout:1000][bbox];'
    r'[~"^(amenity|shop)$"~"."];'
    r'out tags center;';

  static String _radiusQuery(Circle region) =>
    r'[out:json][timeout:1000];'
    'nwr(around:${region.radius},${region.center.latitude},${region.center.longitude})'
    r'[~"^(amenity|shop)$"~"."];'
    r'out tags center;';

  final Duration timeout;

  final String endPoint;

  final RetryClient _client;

  POIQueryService({
    this.timeout = const Duration(seconds: 15),
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    this.endPoint = 'https://overpass-api.de/api/interpreter',
  }) : _client = RetryClient(
    Client(),
    retries: maxRetries,
    delay: (retryCount) => retryDelay,
  );

  /// Method to query all POIs from a specific bbox via Overpass API.
  /// This method will throw [HTTP Client] connection errors.

  Future<POICollection> queryByBBox(LatLng southWest, LatLng northEast) async {
    final uri = Uri.parse(endPoint).replace(
      queryParameters: {
        'data': _bboxQuery,
        'bbox': '${southWest.longitude},${southWest.latitude},${northEast.longitude},${northEast.latitude}',
      },
    );
    final response = await _client.get(uri).timeout(timeout);
    return POICollection(_parseResponse(response));
  }

  /// Method to query all POIs from in a specfic circle via Overpass API.
  /// This method will throw [HTTP Client] connection errors.

  Future<POICollection> queryByRadius(Circle region) async {
    final uri = Uri.parse(endPoint).replace(
      queryParameters: {
        'data': _radiusQuery(region),
      },
    );
    final response = await _client.get(uri).timeout(timeout);
    return POICollection(_parseResponse(response));
  }

  /// Method to convert the Overpass API response to a lazy [Iterable] of [Stop]s.

  Iterable<POI> _parseResponse(Response response) sync* {
    final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (data['elements'] != null) {
      for (final element in data['elements']) {
        try {
          yield POI.fromOverpassJSON(element);
        }
        on UnsupportedError { /* noop */ }
      }
    }
  }

  /// A method to terminate the api client and cleanup any open connections.
  /// This should be called inside the widgets dispose callback.

  void dispose() {
    _client.close();
  }
}
