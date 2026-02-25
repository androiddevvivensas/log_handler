class LogConfig {
  final int maxLogs;
  final int retentionDays;
  final bool enableConsoleLog;
  final bool enableFileLog;
  final String fileName;
  final String directoryName;

  /// Keys that must be masked in logs
  final List<String> sensitiveKeys;

  const LogConfig({
    this.maxLogs = 500,
    this.retentionDays = 5,
    this.enableConsoleLog = true,
    this.enableFileLog = true,
    this.fileName = "app_logs.txt",
    this.directoryName = "logs",
    this.sensitiveKeys = const [
      "password",
      "token",
      "accessToken",
      "refreshToken",
      "authorization",
      "apiKey",
    ],
  });
}
