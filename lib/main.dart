import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobx/mobx.dart';

import 'features/map_screen/widgets/map_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'shared/services/deep_link_service.dart';
import 'shared/services/indoor_positioning_service.dart';
import 'shared/services/config_service.dart';
import 'shared/services/logging_service.dart';

void main() async {
  // required for system chrome
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  GetIt.I.registerSingleton(await DeepLinkService.init());

  GetIt.I.registerSingleton(LoggingService());

  GetIt.I.registerSingleton(IndoorPositioningService(
    referenceLatitude: 52.13063751982141,
    referenceLongitude: 11.625540294595387,
    referenceAzimuth: 10.79139813008669,
  ));

  await Hive.initFlutter();
  GetIt.I.registerSingleton(ConfigService(
    await Hive.openBox('profile'),
  ));

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // Cannot use ReactionBuilder as child of MaterialApp
  // because it will be replaced when navigating to a new route
  reaction((p0) => GetIt.I.get<DeepLinkService>().watch(), (_) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MapScreen()),
      (route) => false,
    );
  });

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const MapScreen(),
      navigatorKey: navigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}
