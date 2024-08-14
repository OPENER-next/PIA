import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/shared/models/pois.dart';
import '/shared/services/indoor_positioning_service.dart';
import '../models/poi_collection.dart';
import '../services/poi_query_service.dart';

// Due to the nature of the SearchAnchor widget this view model does not contain any observables.
// Instead everything fits the SearchController and SearchAnchor widget.
// The view model rather acts as a controller here.

class POIFinderViewModel extends ViewModel {

  final double _searchRadius = 300;

  final _poiService = POIQueryService();

  final controller = SearchController();

  LatLng? get _currentLocation =>
      getService<IndoorPositioningService>().currentPositionPackage?.position;

  Completer<POICollection>? _nearbyPois;

  bool get nearbyPoisLoaded => _nearbyPois != null && _nearbyPois!.isCompleted;

  void open() async {
    // clear any previous data
    controller.clear();
    _nearbyPois = Completer();
    controller.openView();

    if (_currentLocation != null) {
      final result = await _poiService.queryByRadius(
        Circle(_currentLocation!, _searchRadius),
      );
      if (!_nearbyPois!.isCompleted) {
        // always sort pois by distance
        result.sortByDistance(_currentLocation!);
        _nearbyPois!.complete(result);
      }
    }
  }

  // Should only be read after a call to [open].

  Future<Iterable<POI>> get poiResults async {
    final locale = AppLocalizations.of(context)!;
    final pois = await _nearbyPois!.future;
    if (controller.text.isNotEmpty) {
      return pois.filterByKeyword(controller.text, locale);
    }
    // if no search keyword is present show a specific selection of loaded pois
    return pois.filterUniqueByType({
      POIToilet, POITicketMachine, POIAtm, POITaxi, POIWasteBasket
    });
  }

  String poiName(POI poi) {
    final keyword = poi.keywords(AppLocalizations.of(context)!).first;
    if (poi.name.isNotEmpty) {
      return '${poi.name} - $keyword';
    }
    return keyword;
  }

  String poiDistance(POI poi) {
    final distance = const Distance()
      .distance(_currentLocation!, poi.position)
      .round();
    return '$distance m';
  }

  @override
  void dispose() {
    _poiService.dispose();
    controller.dispose();
    super.dispose();
  }
}
