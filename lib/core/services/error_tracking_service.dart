import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class ErrorTrackingService {
  static final ErrorTrackingService _instance = ErrorTrackingService._internal();
  factory ErrorTrackingService() => _instance;
  ErrorTrackingService._internal();

  final List<AppError> _errors = [];
  final StreamController<AppError> _errorStreamController = 
      StreamController<AppError>.broadcast();
  
  Stream<AppError> get errorStream => _errorStreamController.stream;
  List<AppError> get errors => List.unmodifiable(_errors);
  
  int _maxStoredErrors = 1000;
  bool _enableConsoleLogging = kDebugMode;
  bool _enableLocalStorage = true;
  bool _enableRemoteLogging = false;
  String? _remoteEndpoint;
  
  bool _isInitialized = false;

  void initialize({
    int? maxStoredErrors,
    bool? enableConsoleLogging,
    bool? enableLocalStorage,
    bool? enableRemoteLogging,
    String? remoteEndpoint,
  }) {
    if (_isInitialized) return;
    
    _maxStoredErrors = maxStoredErrors ?? _maxStoredErrors;
    _enableConsoleLogging = enableConsoleLogging ?? _enableConsoleLogging;
    _enableLocalStorage = enableLocalStorage ?? _enableLocalStorage;
    _enableRemoteLogging = enableRemoteLogging ?? _enableRemoteLogging;
    _remoteEndpoint = remoteEndpoint;
    
    _setupErrorHandling();
    _loadStoredErrors();
    _isInitialized = true;
  }

  void _setupErrorHandling() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      logError(
        error: details.exception,
        stackTrace: details.stack,
        context: 'Flutter Framework',
        level: ErrorLevel.error,
        additionalData: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );
    };

    // Handle platform dispatcher errors (unhandled exceptions)
    PlatformDispatcher.instance.onError = (error, stack) {
      logError(
        error: error,
        stackTrace: stack,
        context: 'Platform Dispatcher',
        level: ErrorLevel.fatal,
      );
      return true;
    };
  }

  void logError({
    required Object error,
    StackTrace? stackTrace,
    String? context,
    ErrorLevel level = ErrorLevel.error,
    Map<String, dynamic>? additionalData,
  }) {
    final appError = AppError(
      id: _generateId(),
      error: error,
      stackTrace: stackTrace,
      context: context,
      level: level,
      timestamp: DateTime.now(),
      additionalData: additionalData ?? {},
      deviceInfo: _getDeviceInfo(),
    );

    _addError(appError);
  }

  void logInfo(String message, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    logError(
      error: message,
      context: context,
      level: ErrorLevel.info,
      additionalData: additionalData,
    );
  }

  void logWarning(String message, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    logError(
      error: message,
      context: context,
      level: ErrorLevel.warning,
      additionalData: additionalData,
    );
  }

  void logDebug(String message, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    if (kDebugMode) {
      logError(
        error: message,
        context: context,
        level: ErrorLevel.debug,
        additionalData: additionalData,
      );
    }
  }

  void logCustomEvent(String eventName, {
    Map<String, dynamic>? properties,
    String? context,
  }) {
    logError(
      error: 'Event: $eventName',
      context: context,
      level: ErrorLevel.info,
      additionalData: {
        'event_name': eventName,
        'properties': properties ?? {},
        'event_type': 'custom_event',
      },
    );
  }

  void logUserAction(String action, {
    Map<String, dynamic>? properties,
    String? userId,
    String? sessionId,
  }) {
    logError(
      error: 'User Action: $action',
      context: 'User Interaction',
      level: ErrorLevel.info,
      additionalData: {
        'action': action,
        'properties': properties ?? {},
        'user_id': userId,
        'session_id': sessionId,
        'event_type': 'user_action',
      },
    );
  }

  void logPerformance(String operation, Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    logError(
      error: 'Performance: $operation took ${duration.inMilliseconds}ms',
      context: 'Performance',
      level: ErrorLevel.info,
      additionalData: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        'metadata': metadata ?? {},
        'event_type': 'performance',
      },
    );
  }

  void _addError(AppError error) {
    _errors.add(error);
    
    // Maintain max size
    if (_errors.length > _maxStoredErrors) {
      _errors.removeAt(0);
    }

    // Notify listeners
    _errorStreamController.add(error);

    // Log to console in debug mode
    if (_enableConsoleLogging) {
      _logToConsole(error);
    }

    // Save to local storage
    if (_enableLocalStorage) {
      _saveToLocalStorage(error);
    }

    // Send to remote endpoint
    if (_enableRemoteLogging && _remoteEndpoint != null) {
      _sendToRemoteEndpoint(error);
    }
  }

  void _logToConsole(AppError error) {
    final levelPrefix = _getLevelPrefix(error.level);
    final contextSuffix = error.context != null ? ' [${error.context}]' : '';
    
    debugPrint('$levelPrefix ${error.error}$contextSuffix');
    
    if (error.stackTrace != null && error.level.severity >= ErrorLevel.error.severity) {
      debugPrint('Stack trace:\n${error.stackTrace}');
    }
  }

  String _getLevelPrefix(ErrorLevel level) {
    switch (level) {
      case ErrorLevel.debug:
        return '[DEBUG]';
      case ErrorLevel.info:
        return '[INFO]';
      case ErrorLevel.warning:
        return '[WARN]';
      case ErrorLevel.error:
        return '[ERROR]';
      case ErrorLevel.fatal:
        return '[FATAL]';
    }
  }

  void _saveToLocalStorage(AppError error) {
    try {
      final storage = web.window.localStorage;
      final key = 'bloom_error_${error.id}';
      final data = jsonEncode(error.toJson());
      storage.setItem(key, data);
      
      // Also maintain a list of error IDs for cleanup
      final errorIds = _getStoredErrorIds();
      errorIds.add(error.id);
      
      // Keep only the latest errors
      if (errorIds.length > _maxStoredErrors) {
        final oldId = errorIds.removeAt(0);
        storage.removeItem('bloom_error_$oldId');
      }
      
      storage.setItem('bloom_error_ids', jsonEncode(errorIds));
    } catch (e) {
      debugPrint('Failed to save error to local storage: $e');
    }
  }

  List<String> _getStoredErrorIds() {
    try {
      final storage = web.window.localStorage;
      final idsData = storage.getItem('bloom_error_ids');
      if (idsData != null) {
        return List<String>.from(jsonDecode(idsData));
      }
    } catch (e) {
      debugPrint('Failed to load error IDs from local storage: $e');
    }
    return [];
  }

  void _loadStoredErrors() {
    if (!_enableLocalStorage) return;
    
    try {
      final errorIds = _getStoredErrorIds();
      final storage = web.window.localStorage;
      
      for (final id in errorIds) {
        final data = storage.getItem('bloom_error_$id');
        if (data != null) {
          final json = jsonDecode(data);
          final error = AppError.fromJson(json);
          _errors.add(error);
        }
      }
      
      // Sort by timestamp
      _errors.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      debugPrint('Failed to load stored errors: $e');
    }
  }

  Future<void> _sendToRemoteEndpoint(AppError error) async {
    if (_remoteEndpoint == null) return;
    
    try {
      // This would normally use http package to send to your backend
      // For now, just log that it would be sent
      debugPrint('Would send error to $_remoteEndpoint: ${error.toJson()}');
    } catch (e) {
      debugPrint('Failed to send error to remote endpoint: $e');
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (DateTime.now().microsecond % 1000).toString().padLeft(3, '0');
  }

  DeviceInfo _getDeviceInfo() {
    return DeviceInfo(
      userAgent: web.window.navigator.userAgent,
      platform: web.window.navigator.platform,
      language: web.window.navigator.language,
      screenWidth: web.window.screen.width,
      screenHeight: web.window.screen.height,
      viewportWidth: web.window.innerWidth,
      viewportHeight: web.window.innerHeight,
      timestamp: DateTime.now(),
    );
  }

  List<AppError> getErrorsByLevel(ErrorLevel level) {
    return _errors.where((error) => error.level == level).toList();
  }

  List<AppError> getErrorsByTimeRange(DateTime start, DateTime end) {
    return _errors.where((error) => 
      error.timestamp.isAfter(start) && error.timestamp.isBefore(end)
    ).toList();
  }

  List<AppError> getErrorsByContext(String context) {
    return _errors.where((error) => error.context == context).toList();
  }

  void clearErrors() {
    _errors.clear();
    
    if (_enableLocalStorage) {
      try {
        final storage = web.window.localStorage;
        final errorIds = _getStoredErrorIds();
        
        for (final id in errorIds) {
          storage.removeItem('bloom_error_$id');
        }
        
        storage.removeItem('bloom_error_ids');
      } catch (e) {
        debugPrint('Failed to clear errors from local storage: $e');
      }
    }
  }

  ErrorStats getStats() {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));
    
    final totalErrors = _errors.length;
    final recentErrors = _errors.where((e) => e.timestamp.isAfter(last24h)).length;
    
    final errorsByLevel = <ErrorLevel, int>{};
    for (final error in _errors) {
      errorsByLevel[error.level] = (errorsByLevel[error.level] ?? 0) + 1;
    }
    
    return ErrorStats(
      totalErrors: totalErrors,
      recentErrors: recentErrors,
      errorsByLevel: errorsByLevel,
      firstErrorTime: _errors.isNotEmpty ? _errors.first.timestamp : null,
      lastErrorTime: _errors.isNotEmpty ? _errors.last.timestamp : null,
    );
  }

  void dispose() {
    _errorStreamController.close();
  }
}

class AppError {
  final String id;
  final Object error;
  final StackTrace? stackTrace;
  final String? context;
  final ErrorLevel level;
  final DateTime timestamp;
  final Map<String, dynamic> additionalData;
  final DeviceInfo deviceInfo;

  AppError({
    required this.id,
    required this.error,
    this.stackTrace,
    this.context,
    required this.level,
    required this.timestamp,
    required this.additionalData,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
      'level': level.name,
      'timestamp': timestamp.toIso8601String(),
      'additionalData': additionalData,
      'deviceInfo': deviceInfo.toJson(),
    };
  }

  factory AppError.fromJson(Map<String, dynamic> json) {
    return AppError(
      id: json['id'],
      error: json['error'],
      stackTrace: json['stackTrace'] != null 
          ? StackTrace.fromString(json['stackTrace'])
          : null,
      context: json['context'],
      level: ErrorLevel.values.firstWhere((e) => e.name == json['level']),
      timestamp: DateTime.parse(json['timestamp']),
      additionalData: Map<String, dynamic>.from(json['additionalData'] ?? {}),
      deviceInfo: DeviceInfo.fromJson(json['deviceInfo']),
    );
  }

  @override
  String toString() {
    return 'AppError(id: $id, level: $level, error: $error, context: $context, timestamp: $timestamp)';
  }
}

enum ErrorLevel {
  debug(0),
  info(1),
  warning(2),
  error(3),
  fatal(4);

  const ErrorLevel(this.severity);
  final int severity;
}

class DeviceInfo {
  final String userAgent;
  final String? platform;
  final String? language;
  final int screenWidth;
  final int screenHeight;
  final int viewportWidth;
  final int viewportHeight;
  final DateTime timestamp;

  DeviceInfo({
    required this.userAgent,
    this.platform,
    this.language,
    required this.screenWidth,
    required this.screenHeight,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userAgent': userAgent,
      'platform': platform,
      'language': language,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'viewportWidth': viewportWidth,
      'viewportHeight': viewportHeight,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      userAgent: json['userAgent'],
      platform: json['platform'],
      language: json['language'],
      screenWidth: json['screenWidth'],
      screenHeight: json['screenHeight'],
      viewportWidth: json['viewportWidth'],
      viewportHeight: json['viewportHeight'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ErrorStats {
  final int totalErrors;
  final int recentErrors;
  final Map<ErrorLevel, int> errorsByLevel;
  final DateTime? firstErrorTime;
  final DateTime? lastErrorTime;

  ErrorStats({
    required this.totalErrors,
    required this.recentErrors,
    required this.errorsByLevel,
    this.firstErrorTime,
    this.lastErrorTime,
  });

  int get criticalErrors => 
      (errorsByLevel[ErrorLevel.error] ?? 0) + 
      (errorsByLevel[ErrorLevel.fatal] ?? 0);
  
  int get warnings => errorsByLevel[ErrorLevel.warning] ?? 0;
  int get infos => errorsByLevel[ErrorLevel.info] ?? 0;
  int get debugs => errorsByLevel[ErrorLevel.debug] ?? 0;
}

// Widget for displaying error information in debug builds
class ErrorDisplayWidget extends StatelessWidget {
  final bool showInRelease;
  
  const ErrorDisplayWidget({
    super.key,
    this.showInRelease = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode && !showInRelease) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<AppError>(
      stream: ErrorTrackingService().errorStream,
      builder: (context, snapshot) {
        final stats = ErrorTrackingService().getStats();
        
        if (stats.totalErrors == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Errors: ${stats.totalErrors} total, ${stats.criticalErrors} critical',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (stats.lastErrorTime != null)
                Text(
                  'Last: ${stats.lastErrorTime!.toLocal().toString().split('.')[0]}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}