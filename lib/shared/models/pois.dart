import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import 'level.dart';
import 'position.dart';

/// Base class for a point of interest.
///
/// Sealed allows switch expression on class type.

sealed class POI {
  final String id;

  final String name;

  final Position position;

  Iterable<String> keywords(AppLocalizations localizations);

  IconData get symbol;

  const POI({
    required this.id,
    required this.name,
    required this.position,
  });

  /// This can throw an [UnsupportedError] if the given element is not supported.

  factory POI.fromOverpassJSON(Map<String, dynamic> data) {
    final tags = data['tags'];
    final constructor = _tagToConstructor(tags.cast<String, String>());
    final position = data['center'] ?? data;

    return constructor(
      id: '${data['type']}:${data['id']}',
      name: tags['name'] ?? '',
      position: Position(position['lat'], position['lon'],
        level: Level.fromNumber( num.tryParse(tags['level'] ?? '0') ?? 0 ),
      ),
    );
  }

  static POI Function({required String id, required String name, required Position position}) _tagToConstructor(Map<String, String> tags) {
    if (tags['amenity'] == 'taxi') {
      return POITaxi.new;
    }
    if (tags['amenity'] == 'parking') {
      return POIParking.new;
    }
    if (tags['amenity'] == 'bicycle_parking') {
      return POIBicycleParking.new;
    }
    if (tags['amenity'] == 'toilets') {
      return POIToilet.new;
    }
    if (tags['amenity'] == 'waste_basket') {
      return POIWasteBasket.new;
    }
    if (tags['amenity'] == 'bench') {
      return POIBench.new;
    }
    if (tags['amenity'] == 'shelter') {
      return POIShelter.new;
    }
    if (tags['amenity'] == 'lockers') {
      return POILockers.new;
    }
    if (tags['amenity'] == 'vending_machine' && tags['vending'] == 'public_transport_tickets') {
      return POITicketMachine.new;
    }
    if (tags['amenity'] == 'atm') {
      return POIAtm.new;
    }
    if (tags['amenity'] == 'post_box') {
      return POIPostBox.new;
    }
    if (tags['amenity'] == 'photo_booth') {
      return POIPhotoBooth.new;
    }
    if (tags['amenity'] == 'police') {
      return POIPolice.new;
    }
    if (tags['amenity'] == 'waiting_room') {
      return POIWaitingRoom.new;
    }
    if (tags['shop'] != null) {
      return POIShop.new;
    }
    throw UnsupportedError('Cannot derive POI type from given tags');
  }
}

// Individual poi type implementations \\

class POITaxi extends POI {
  POITaxi({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.taxi;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordTaxi01;
    yield localizations.poiKeywordTaxi02;
  }
}

class POIParking extends POI {
  POIParking({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.parking;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordParking01;
    yield localizations.poiKeywordParking02;
  }
}

class POIBicycleParking extends POI {
  POIBicycleParking({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.bicycle;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordBicycleParking01;
  }
}

class POIToilet extends POI {
  POIToilet({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.toilet;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordToilet01;
    yield localizations.poiKeywordToilet02;
    yield localizations.poiKeywordToilet03;
    yield localizations.poiKeywordToilet04;
    yield localizations.poiKeywordToilet05;
  }
}

class POIWasteBasket extends POI {
  POIWasteBasket({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.trashCan;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordWasteBasket01;
    yield localizations.poiKeywordWasteBasket02;
    yield localizations.poiKeywordWasteBasket03;
    yield localizations.poiKeywordWasteBasket04;
    yield localizations.poiKeywordWasteBasket05;
  }
}

class POIBench extends POI {
  POIBench({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.benchBack;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordBench01;
    yield localizations.poiKeywordBench02;
  }
}

class POIShelter extends POI {
  POIShelter({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.busStopCovered;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordShelter01;
  }
}

class POILockers extends POI {
  POILockers({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.lockerMultiple;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordLockers01;
    yield localizations.poiKeywordLockers02;
  }
}

class POITicketMachine extends POI {
  POITicketMachine({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.ticketConfirmation;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordTicketMachine01;
  }
}

class POIAtm extends POI {
  POIAtm({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.cashMultiple;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordATM01;
    yield localizations.poiKeywordATM02;
  }
}

class POIPostBox extends POI {
  POIPostBox({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.mail;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordPostBox01;
    yield localizations.poiKeywordPostBox02;
    yield localizations.poiKeywordPostBox03;
  }
}

class POIPhotoBooth extends POI {
  POIPhotoBooth({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.accountBoxOutline;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordPhotoBooth01;
  }
}

class POIPolice extends POI {
  POIPolice({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.policeStation;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordPolice01;
  }
}

class POIWaitingRoom extends POI {
  POIWaitingRoom({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.seatPassenger;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordWaitingRoom01;
    yield localizations.poiKeywordWaitingRoom02;
    yield localizations.poiKeywordWaitingRoom03;
  }
}

class POIShop extends POI {
  POIShop({
    required super.id,
    required super.name,
    required super.position
  });

  @override
  get symbol => MdiIcons.basketOutline;

  @override
  Iterable<String> keywords(localizations) sync* {
    yield localizations.poiKeywordShop01;
    yield localizations.poiKeywordShop02;
  }
}
