import 'package:flutter/foundation.dart';
import '../flutter_log_handler.dart';

class CrashWrapper {
  static void initialize({
    required LogService logService,
  }) {
    final FlutterExceptionHandler? originalOnError = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) async {
      originalOnError?.call(details);

      await logService.logEvent(
        message: "FLUTTER ERROR: ${details.exceptionAsString()}",
        level: LogLevel.error,
        stackTrace: details.stack?.toString(),
        route: details.context?.toString(),
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      logService.logEvent(
        message: "UNCAUGHT ERROR: $error",
        level: LogLevel.error,
        stackTrace: stackTrace.toString(),
      );
      return true;
    };
  }
}
