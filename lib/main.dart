import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/map_screen/widgets/map_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'shared/services/indoor_positioning_service.dart';
import 'shared/services/config_service.dart';

void main() async {
  // required for system chrome
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  GetIt.I.registerSingleton(IndoorPositioningService(
    referenceLatitude: 52.13052287240374,
    referenceLongitude: 11.625185377957138,
    referenceAzimuth: 9.89916231907847,
  ));

  await Hive.initFlutter();
  GetIt.I.registerSingleton(ConfigService(
    await Hive.openBox('profile'),
  ));

  runApp(
    MaterialApp(
      theme: ThemeData.light(),
      home: const MapScreen(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}
