import 'dart:convert';

enum LogLevel { info, warning, error }

class AppLogModel {
  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final String? stackTrace;
  final String? route;
  final String? apiEndpoint;
  final Map<String, dynamic>? tags;

  AppLogModel({
    required this.message,
    required this.level,
    required this.timestamp,
    this.stackTrace,
    this.route,
    this.apiEndpoint,
    this.tags,
  });

  Map<String, dynamic> toJson() => {
        "message": message,
        "level": level.name,
        "timestamp": timestamp.toIso8601String(),
        "stackTrace": stackTrace,
        "route": route,
        "apiEndpoint": apiEndpoint,
        "tags": tags ?? {},
      };

  factory AppLogModel.fromJson(Map<String, dynamic> json) {
    return AppLogModel(
      message: json["message"] ?? "",
      level: LogLevel.values.firstWhere(
        (e) => e.name == json["level"],
        orElse: () => LogLevel.info,
      ),
      timestamp: DateTime.tryParse(json["timestamp"] ?? "") ?? DateTime.now(),
      stackTrace: json["stackTrace"],
      route: json["route"],
      apiEndpoint: json["apiEndpoint"],
      tags: json["tags"] != null ? Map<String, dynamic>.from(json["tags"]) : {},
    );
  }

  // ==============================
  // STATIC ENCODE / DECODE HELPERS
  // ==============================

  static String encode(List<AppLogModel> logs) {
    return jsonEncode(
      logs.map((log) => log.toJson()).toList(),
    );
  }

  static List<AppLogModel> decode(String source) {
    if (source.isEmpty) return [];

    final List<dynamic> data = jsonDecode(source);

    return data.map((json) => AppLogModel.fromJson(json)).toList();
  }
}
