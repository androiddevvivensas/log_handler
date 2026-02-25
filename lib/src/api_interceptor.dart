import 'package:dio/dio.dart';
import 'services/log_service.dart';
import 'models/log_model.dart';

class ApiInterceptor extends Interceptor {
  final LogService logService;
  final int slowRequestThresholdMs;

  ApiInterceptor(
    this.logService, {
    this.slowRequestThresholdMs = 2000,
  });

  static const String _startTimeKey = 'startTime';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    try {
      await logService.logEvent(
        message: "REQUEST → ${options.method} ${options.uri}\n"
            "Body: ${logService.sanitizeData(options.data)}",
        level: LogLevel.info,
        apiEndpoint: options.uri.toString(),
      );
    } catch (_) {
      // Logging should NEVER break API flow
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final startTime = response.requestOptions.extra[_startTimeKey] as int?;

    final duration = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;

    try {
      // Slow API detection
      if (duration > slowRequestThresholdMs) {
        await logService.logEvent(
          message: "SLOW API (${duration}ms)\n"
              "→ ${response.requestOptions.method} "
              "${response.requestOptions.uri}",
          level: LogLevel.warning,
          apiEndpoint: response.requestOptions.uri.toString(),
        );
      }

      await logService.logEvent(
        message: "RESPONSE ← ${response.statusCode} "
            "${response.requestOptions.uri} "
            "(${duration}ms)\n"
            "Response: ${logService.sanitizeData(response.data)}",
        level: LogLevel.info,
        apiEndpoint: response.requestOptions.uri.toString(),
      );
    } catch (_) {}

    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      await logService.logEvent(
        message: "ERROR ← ${err.requestOptions.method} "
            "${err.requestOptions.uri}\n"
            "Message: ${err.message}",
        level: LogLevel.error,
        stackTrace: err.stackTrace.toString(),
        apiEndpoint: err.requestOptions.uri.toString(),
      );
    } catch (_) {}

    handler.next(err);
  }
}
