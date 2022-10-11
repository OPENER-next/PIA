import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/map_screen/map_screen.dart';

void main() {
  // required for system chrome
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MaterialApp(
      theme: ThemeData.light(),
      home: MapScreen(),
    ),
  );
}
