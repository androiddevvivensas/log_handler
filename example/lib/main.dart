import 'package:flutter/material.dart';
import 'package:flutter_log_handler/flutter_log_handler.dart';

void main() {
  // Initialize LogService
  LogService.init(LogConfig(
    enableConsoleLog: true,
    enableFileLog: true,
    maxLogs: 100,
    retentionDays: 5,
    fileName: "app_logs.json",
    directoryName: "logs",
    sensitiveKeys: [
      "password",
      "token",
      "accessToken",
      "refreshToken",
      "apiKey"
    ],
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Log Handler Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Log Handler Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Log an event
                LogService.to.logEvent(
                  message: "Info log clicked",
                  level: LogLevel.info,
                );
              },
              child: const Text("Log Info"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                LogService.to.logEvent(
                  message: "Warning log clicked",
                  level: LogLevel.warning,
                );
              },
              child: const Text("Log Warning"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                LogService.to.logEvent(
                  message: "Error log clicked",
                  level: LogLevel.error,
                );
              },
              child: const Text("Log Error"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Open log viewer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyLogScreen(
                      title: "App Logs",
                      appBarColor: Colors.teal,
                      centerTitle: true,

                      // Custom AppBar icons and actions
                      leadingIcon: const Icon(Icons.arrow_back),
                      leadingIconOnTap: () => Navigator.pop(context),
                      refreshIcon: const Icon(Icons.refresh_outlined),
                      refreshOnTap: () => print("Logs refreshed"),
                      shareIcon: const Icon(Icons.share),
                      shareOnTap: LogService.to.shareLogs,
                      deleteIcon: const Icon(Icons.delete_forever),
                      deleteOnTap: () => print("Delete clicked"),

                      // Delete dialog text
                      deleteDialogTitle: "Confirm Delete",
                      deleteDialogMessage: "Do you want to clear all logs?",
                      deleteDialogConfirmText: "Yes, Delete",
                      deleteDialogCancelText: "Cancel",

                      // Log list and chips
                      showChipIndicator: true,
                      levelColors: {
                        LogLevel.info: Colors.blue,
                        LogLevel.warning: Colors.orange,
                        LogLevel.error: Colors.red,
                      },
                      noLogsMessage: "No logs found",
                      dateFormat: "EEE, MMM dd yyyy hh:mm a",
                    ),
                  ),
                );
              },
              child: const Text("View Logs"),
            ),
          ],
        ),
      ),
    );
  }
}
