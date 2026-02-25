import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/log_service.dart';
import '../models/log_model.dart';

typedef LogIconCallback = void Function();

class MyLogScreen extends StatefulWidget {
  // ==============================
  // Basic Texts & Labels
  // ==============================
  final String title;
  final String noLogsMessage;
  final String dateFormat;

  // ==============================
  // Log Level Colors & Chips
  // ==============================
  final Map<LogLevel, Color> levelColors;
  final bool showChipIndicator;

  // ==============================
  // AppBar Customization
  // ==============================
  final Color appBarColor;
  final bool centerTitle;
  final Widget? leadingIcon;
  final LogIconCallback? leadingIconOnTap;

  final Widget? refreshIcon;
  final LogIconCallback? refreshOnTap;

  final Widget? shareIcon;
  final LogIconCallback? shareOnTap;

  final Widget? deleteIcon;
  final LogIconCallback? deleteOnTap;

  // ==============================
  // Delete Dialog Texts
  // ==============================
  final String deleteDialogTitle;
  final String deleteDialogMessage;
  final String deleteDialogConfirmText;
  final String deleteDialogCancelText;

  const MyLogScreen({
    super.key,
    this.title = "Application Logs",
    this.noLogsMessage = "No Logs Available",
    this.dateFormat = "EEE MMM dd yyyy hh:mm a",
    this.levelColors = const {
      LogLevel.info: Colors.blue,
      LogLevel.warning: Colors.orange,
      LogLevel.error: Colors.red,
    },
    this.showChipIndicator = true,
    this.appBarColor = Colors.blue,
    this.centerTitle = true,
    this.leadingIcon,
    this.leadingIconOnTap,
    this.refreshIcon,
    this.refreshOnTap,
    this.shareIcon,
    this.shareOnTap,
    this.deleteIcon,
    this.deleteOnTap,
    this.deleteDialogTitle = "Delete Logs",
    this.deleteDialogMessage = "Are you sure you want to delete all logs?",
    this.deleteDialogConfirmText = "Delete",
    this.deleteDialogCancelText = "Cancel",
  });

  @override
  State<MyLogScreen> createState() => _MyLogScreenState();
}

class _MyLogScreenState extends State<MyLogScreen> {
  LogLevel? selectedLevel;
  late Future<List<AppLogModel>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    _logsFuture = LogService.to.getLogs();
  }

  Future<void> _refreshLogs() async {
    _loadLogs();
    setState(() {});
    await _logsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.appBarColor,
        centerTitle: widget.centerTitle,
        title: Text(widget.title),
        leading: widget.leadingIcon != null
            ? IconButton(
                icon: widget.leadingIcon!,
                onPressed: widget.leadingIconOnTap,
              )
            : null,
        actions: [
          IconButton(
            icon: widget.refreshIcon ?? const Icon(Icons.refresh),
            onPressed: widget.refreshOnTap ?? _refreshLogs,
          ),
          IconButton(
            icon: widget.shareIcon ?? const Icon(Icons.share),
            onPressed: widget.shareOnTap ?? LogService.to.shareLogs,
          ),
          IconButton(
            icon: widget.deleteIcon ?? const Icon(Icons.delete),
            onPressed: widget.deleteOnTap ?? _confirmClearLogs,
          ),
        ],
      ),
      body: FutureBuilder<List<AppLogModel>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          var logs = snapshot.data ?? [];
          if (selectedLevel != null) {
            logs = logs.where((e) => e.level == selectedLevel).toList();
          }

          return RefreshIndicator(
            onRefresh: _refreshLogs,
            child: Column(
              children: [
                _buildFilterChips(),
                Expanded(
                  child: logs.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Text(
                                  widget.noLogsMessage,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: logs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) => _logCard(logs[index]),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        children: [
          _dottedChip(null, "All"),
          _dottedChip(LogLevel.info, "Info"),
          _dottedChip(LogLevel.warning, "Warning"),
          _dottedChip(LogLevel.error, "Error"),
        ],
      ),
    );
  }

  Widget _dottedChip(LogLevel? level, String label) {
    final isSelected = selectedLevel == level;
    final color =
        level != null ? widget.levelColors[level] ?? Colors.grey : Colors.grey;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showChipIndicator)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.5),
              ),
            ),
          if (widget.showChipIndicator) const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: color.withValues(alpha: 0.2),
      onSelected: (_) => setState(() => selectedLevel = level),
    );
  }

  Widget _logCard(AppLogModel log) {
    final color = widget.levelColors[log.level] ?? Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Icon(_levelIcon(log.level), color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                log.message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        subtitle: Text(
          "${_formatDate(log.timestamp)}${log.route != null ? ' • ${log.route}' : ''}",
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          if (log.stackTrace != null)
            SelectableText(
              log.stackTrace!,
              style: const TextStyle(fontSize: 12, fontFamily: "monospace"),
            ),
        ],
      ),
    );
  }

  IconData _levelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.warning:
        return Icons.warning_amber_outlined;
      case LogLevel.error:
        return Icons.error_outline;
    }
  }

  String _formatDate(DateTime date) {
    try {
      final formatter = DateFormat(widget.dateFormat);
      return formatter.format(date);
    } catch (_) {
      return date.toIso8601String();
    }
  }

  Future<void> _confirmClearLogs() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.deleteDialogTitle),
        content: Text(widget.deleteDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(widget.deleteDialogCancelText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              widget.deleteDialogConfirmText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await LogService.to.clearLogs();
      _refreshLogs();
    }
  }
}
