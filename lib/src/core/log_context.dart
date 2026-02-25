class LogContext {
  static String? _userId;
  static String? _sessionId;
  static String? _flavor;
  static String? _appVersion;
  static String? _platform;

  static void setUser(String? userId) {
    _userId = userId;
  }

  static void setSession(String sessionId) {
    _sessionId = sessionId;
  }

  static void setEnvironment({
    required String flavor,
    required String appVersion,
    required String platform,
  }) {
    _flavor = flavor;
    _appVersion = appVersion;
    _platform = platform;
  }

  static Map<String, dynamic> get tags => {
        "userId": _userId,
        "sessionId": _sessionId,
        "flavor": _flavor,
        "appVersion": _appVersion,
        "platform": _platform,
      };
}
