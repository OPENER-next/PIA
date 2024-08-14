import 'package:flutter_mvvm_architecture/base.dart';
import 'package:logging/logging.dart';

import '/shared/utils/observable_buffer.dart';


class LoggingService extends Service {
  final _logBuffer = ObservableBuffer<LogRecord>(limit: 100);

  Iterable<LogRecord> get buffer => _logBuffer;

  LoggingService._() {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(_logBuffer.push);
  }

  static final LoggingService _singleton = LoggingService._();

  factory LoggingService() => _singleton;
}
