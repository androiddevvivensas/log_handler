import 'dart:math';
import 'log_context.dart';

class SessionManager {
  static void startSession() {
    final sessionId = _generateSessionId();
    LogContext.setSession(sessionId);
  }

  static String _generateSessionId() {
    final rand = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        rand.nextInt(9999).toString();
  }
}
