import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/log_context.dart';
import '../models/log_model.dart';
import '../config/log_config.dart';

class LogService {
  static late LogService _instance;

  final LogConfig config;
  final List<AppLogModel> _logs = [];

  bool _isWriting = false;

  LogService._(this.config);

  static void init(LogConfig config) {
    _instance = LogService._(config);
  }

  static LogService get to => _instance;

  List<AppLogModel> get logs => List.unmodifiable(_logs);

  // ==============================
  // MAIN LOG METHOD
  // ==============================

  Future<void> logEvent({
    required String message,
    LogLevel level = LogLevel.info,
    String? stackTrace,
    String? route,
    String? apiEndpoint,
  }) async {
    try {
      final log = AppLogModel(
        message: sanitizeData(message),
        level: level,
        timestamp: DateTime.now(),
        stackTrace: stackTrace,
        route: route,
        apiEndpoint: apiEndpoint,
        tags: Map<String, dynamic>.from(LogContext.tags),
      );

      _logs.insert(0, log);

      if (_logs.length > config.maxLogs) {
        _logs.removeLast();
      }

      if (config.enableConsoleLog) {
        _printToConsole(log);
      }

      if (config.enableFileLog) {
        _scheduleFileWrite();
      }
    } catch (_) {
      // Never allow logging to crash the app
    }
  }

  // ==============================
  // FILE HANDLING
  // ==============================

  Future<List<AppLogModel>> getLogs() async {
    if (!config.enableFileLog) return _logs;

    final file = await _getLogFile();

    if (await file.exists()) {
      final content = await file.readAsString();
      final decoded = AppLogModel.decode(content);

      _logs
        ..clear()
        ..addAll(decoded);

      await _applyRetentionPolicy();

      return _logs;
    }

    return _logs;
  }

  Future<void> _scheduleFileWrite() async {
    if (_isWriting) return;
    _isWriting = true;

    Future.delayed(const Duration(milliseconds: 300), () async {
      await _writeToFile();
      _isWriting = false;
    });
  }

  Future<void> _writeToFile() async {
    try {
      final file = await _getLogFile();
      await file.writeAsString(AppLogModel.encode(_logs));
    } catch (_) {}
  }

  Future<File> _getLogFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final logDir = Directory("${dir.path}/${config.directoryName}");

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    return File("${logDir.path}/${config.fileName}");
  }

  // ==============================
  // RETENTION POLICY
  // ==============================

  Future<void> _applyRetentionPolicy() async {
    final cutoff =
        DateTime.now().subtract(Duration(days: config.retentionDays));

    _logs.removeWhere((log) => log.timestamp.isBefore(cutoff));

    await _writeToFile();
  }

  // ==============================
  // CLEAR
  // ==============================

  Future<void> clearLogs() async {
    _logs.clear();
    await _writeToFile();
  }

  // ==============================
  // CLEAR
  // ==============================

  Future<void> shareLogs() async {
    try {
      final file = await exportLogFile();
      if (file != null && await file.exists()) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: "Application Logs",
          ),
        );
      }
    } catch (e) {
      debugPrint("Error sharing logs: $e");
    }
  }

  // ==============================
  // CONSOLE OUTPUT
  // ==============================

  void _printToConsole(AppLogModel log) {
    final tagString = log.tags != null ? jsonEncode(log.tags) : "";

    // ignore: avoid_print
    debugPrint(
      "[${log.level.name.toUpperCase()}] "
      "[${log.timestamp.toIso8601String()}] "
      "${log.apiEndpoint ?? ""} "
      "$tagString\n"
      "${log.message}",
    );
  }

  // ==============================
  // SANITIZATION
  // ==============================

  String sanitizeData(dynamic data) {
    if (data == null) return "N/A";

    try {
      // Handle Map
      if (data is Map) {
        final sanitizedMap = <String, dynamic>{};
        data.forEach((key, value) {
          if (config.sensitiveKeys.contains(key.toLowerCase())) {
            sanitizedMap[key] = "***";
          } else {
            sanitizedMap[key] =
                sanitizeData(value); // recursive for nested maps
          }
        });
        return jsonEncode(sanitizedMap);
      }

      // Handle List
      if (data is List) {
        return jsonEncode(data.map((e) => sanitizeData(e)).toList());
      }

      // Handle String (for query params etc.)
      var masked = data.toString();
      for (final key in config.sensitiveKeys) {
        // mask key=value patterns
        masked = masked.replaceAllMapped(
          RegExp('$key=([^&\\s]+)', caseSensitive: false),
          (match) => '$key=***',
        );
        // mask "key":"value" patterns
        masked = masked.replaceAllMapped(
          RegExp('"$key"\\s*:\\s*".*?"', caseSensitive: false),
          (match) => '"$key":"***"',
        );
      }

      return masked;
    } catch (_) {
      return data.toString();
    }
  }

  // ==============================
  // SHARE LOGS (READY)
  // ==============================

  Future<File?> exportLogFile() async {
    try {
      final file = await _getLogFile();
      if (await file.exists()) return file;
    } catch (_) {}
    return null;
  }
}
