import 'dart:async';
import 'dart:math';

import 'package:easylocate_flutter_sdk/cmds/commands.dart';
import 'package:easylocate_flutter_sdk/easylocate_sdk.dart';
import 'package:easylocate_flutter_sdk/tracelet_api.dart';
import 'package:easylocate_flutter_sdk/utils/geotools.dart';
import 'package:vector_math/vector_math.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:mobx/mobx.dart';

import '../models/position_package.dart';
import '../utils/position_fuser.dart';
import '../utils/position_transformation.dart';

part 'tracelet_positioning_service.dart';
part 'geolocation_position_service.dart';
part 'fused_positioning_service.dart';

/// Base Positioning Service for tracelet, remote and fusion position services.
abstract class PositioningService extends Service {
  PositioningService() {
    _controller = StreamController.broadcast(
      onListen: _onListen,
      onCancel: _onCancel,
    );
  }

  late final StreamController<PositionPackage> _controller;

  void _onListen();

  void _onCancel();

  bool get isActive => _controller.hasListener;

  Stream<PositionPackage> get positions => _controller.stream;

  @mustCallSuper
  void close() {
    _controller.close();
  }
}
