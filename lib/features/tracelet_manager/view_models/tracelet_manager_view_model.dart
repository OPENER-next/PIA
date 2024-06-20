import 'package:flutter_mvvm_architecture/base.dart';

import '/shared/services/logging_service.dart';
import '/shared/services/indoor_positioning_service.dart';


class TraceletManagerViewModel extends ViewModel {

  IndoorPositioningService get _indoorPositioningService => getService<IndoorPositioningService>();

  LoggingService get _loggingService => getService<LoggingService>();

  bool get isConnected => _indoorPositioningService.isConnected;

  void connectToTracelet() => _indoorPositioningService.connectTracelet();

  void disconnectFromTracelet() => _indoorPositioningService.disconnectTracelet();

  int get logMessageCount  {
    // length is O(1) under the hood (ObservableBuffer)
    return _loggingService.buffer.length;
  }

  String logMessageByIndex(int index) {
    // elementAt() is O(1) under the hood (ObservableBuffer)
    return _loggingService.buffer.elementAt(index).toString();
  }

  @override
  void dispose() {
    _indoorPositioningService.onDispose();
    super.dispose();
  }
}
