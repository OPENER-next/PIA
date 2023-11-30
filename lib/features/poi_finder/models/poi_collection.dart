import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/shared/models/position.dart';
import '/shared/models/pois.dart';


class POICollection extends Iterable<POI> {

  static const _distanceCalc = Distance();

  final List<POI> _pois;

  POICollection(
    Iterable<POI> pois,
  ) : _pois = pois.toList(growable: false);

  const POICollection.empty() : _pois = const [];

  /// Filter the collection based on a given keyword.
  /// This will compare the name and keywordsof each POI with the given keyword.
  ///
  /// Returns a new collection.

  POICollection filterByKeyword(String searchKeyword, AppLocalizations localizations) {
    searchKeyword = searchKeyword.toLowerCase();
    final filteredPois = _pois.where(
      (poi) =>
        poi.name.toLowerCase().contains(searchKeyword) ||
        poi.keywords(localizations).any(
          (poiKeyword) => poiKeyword.toLowerCase().contains(searchKeyword),
        ),
    );
    return POICollection(filteredPois);
  }

  /// Sorts the collection in place.

  void sortByDistance(Position position) => _pois.sort(
    (a, b) => (
      _distanceCalc.distance(position, a.position) -
      _distanceCalc.distance(position, b.position)
    ).round(),
  );

  /// Filters the collection so it only contains each of the given POI class types once.
  /// The first occurrence of a matching type will be kept.
  ///
  /// Returns a new collection.

  POICollection filterUniqueByType(Set<Type> types) {
    final workingSet = Set.of(types);
    // converting this to a List/POICollection important because iterating the
    // iterable multiple times won't work, since the types are removed from the Set
    // on the first run
    return POICollection(
      _pois.where((poi) => workingSet.remove(poi.runtimeType))
    );
  }

  /// Filters the collection so it only contains the given POI class types.
  ///
  /// Returns a new collection.

  POICollection filterByType(Set<Type> types) {
    return POICollection(
      _pois.where((poi) => types.contains(poi.runtimeType)),
    );
  }

  @override
  Iterator<POI> get iterator => _pois.iterator;
}
