**# Changelog

All notable changes to this project will be documented in this file.

---

## 0.0.5

### 🚀 Enhancements
- Added **custom AppBar customization** in LogScreen:
  - `appBarColor` to change AppBar background
  - `centerTitle` to toggle title alignment
  - Custom icons for leading, refresh, share, and delete actions
  - Custom callbacks for AppBar icon taps
- Added **customizable delete confirmation dialog**:
  - `deleteDialogTitle`, `deleteDialogMessage`, `deleteDialogConfirmText`, `deleteDialogCancelText`
  - Fully supports custom button actions
- Added **enhanced log list display**:
  - Shows log timestamp + route
  - Pull-to-refresh for logs
  - Filter logs by level with horizontal chips
  - Selectable stack trace in expanded log card
- Improved **log sharing** with customizable share action
- Updated **color handling** using `.withValues()` for consistent opacity

### 🛠 Improvements
- Refactored internal LogScreen UI for **flexible customization**
- Improved **performance** of log filtering, refresh, and sharing
- Enhanced **null safety** in log models and UI
- Fixed sensitive data masking to ensure keys like `password`, `token`, `apiKey` are hidden
- Minor bug fixes and code cleanup

---

## 0.0.4

### 🚀 Enhancements
- Added **customizable LogScreen UI** with:
    - Custom title, no-logs message, and log colors per level
    - Optional chip indicators for log levels
    - Customizable delete confirmation dialog text
    - Customizable date format for log timestamps
- Added **pull-to-refresh support** for LogScreen
- Added **share logs feature** using `share_plus`
- Improved **filter chips** with horizontal scroll and better color indicators
- Added **expanded error & info display** with selectable stack trace
- Updated **color handling** to use `.withValues()` instead of deprecated `.withOpacity()`

### 🛠 Improvements
- Refactored internal log UI for **modern Flutter best practices**
- Improved **performance of log filtering and refresh**
- Enhanced **null safety and resilience** in log encoding/decoding
- Updated **clear logs confirmation flow** with improved UX
- Minor bug fixes and code cleanup

---

## 0.0.3

### 🚀 Enhancements
- Added automatic crash tagging (device info, platform metadata, build flavor support)
- Added API endpoint tagging in error logs
- Improved structured log model
- Improved stack trace handling
- Enhanced API interceptor logging structure
- Improved sensitive data masking
- Enterprise branding improvements
- SEO optimized README documentation

### 🛠 Improvements
- Performance refinements
- Improved log persistence reliability
- Refactored internal log encoding/decoding
- Enhanced production safety for logging flow

---

## 0.0.2

- Added fileName and directoryName configuration
- Added getLogs() method
- Improved log loading mechanism
- Enhanced README documentation
- Improved MIT License
- Production-ready refinements

---

## 0.0.1

- Initial release of flutter_log_handler
- Configurable log storage
- Console logging support
- File logging support
- Built-in LogScreen UI
- Crash wrapper support
- API interceptor support**
