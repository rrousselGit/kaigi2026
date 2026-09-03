import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogType {
  networkRequest,
  networkResponse,
  networkError,
  exception,
}

class LogEntry {
  final String id;
  final LogType type;
  final DateTime timestamp;
  final String title;
  final String? details;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.title,
    this.details,
    this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'details': details,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
  }

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}

class AppLogger extends ChangeNotifier {
  static final AppLogger instance = AppLogger._internal();

  AppLogger._internal() {
    try {
      developer.registerExtension('ext.books.logs', (method, parameters) async {
        final logsJson = _logs.map((e) => e.toJson()).toList();
        return developer.ServiceExtensionResponse.result(
          jsonEncode({'logs': logsJson}),
        );
      });
    } catch (_) {
      // Ignore if extension is already registered
    }
  }

  final List<LogEntry> _logs = [];

  List<LogEntry> get logs => List.unmodifiable(_logs);

  int _nextId = 1;

  void logNetworkRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
  }) {
    final buffer = StringBuffer();
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('Headers:');
      headers.forEach((key, value) => buffer.writeln('  $key: $value'));
    }
    if (body != null && body.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.writeln();
      buffer.writeln('Body:\n$body');
    }

    final entry = LogEntry(
      id: '${_nextId++}',
      type: LogType.networkRequest,
      timestamp: DateTime.now(),
      title: '$method $url',
      details: buffer.toString().trim(),
    );

    _addLog(entry);
  }

  void logNetworkResponse({
    required String method,
    required String url,
    required int statusCode,
    String? body,
    Duration? duration,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Status Code: $statusCode');
    if (duration != null) {
      buffer.writeln('Duration: ${duration.inMilliseconds}ms');
    }
    if (body != null && body.isNotEmpty) {
      buffer.writeln('Response Body:\n$body');
    }

    final entry = LogEntry(
      id: '${_nextId++}',
      type: LogType.networkResponse,
      timestamp: DateTime.now(),
      title: '$statusCode $method $url',
      details: buffer.toString().trim(),
    );

    _addLog(entry);
  }

  void logException(
    Object exception, [
    StackTrace? stackTrace,
    String? context,
  ]) {
    final buffer = StringBuffer();
    if (context != null && context.isNotEmpty) {
      buffer.writeln('Context: $context');
    }
    buffer.writeln('Exception: $exception');
    if (stackTrace != null) {
      buffer.writeln('\nStackTrace:\n$stackTrace');
    }

    final entry = LogEntry(
      id: '${_nextId++}',
      type: LogType.exception,
      timestamp: DateTime.now(),
      title: context != null ? '$context: $exception' : '$exception',
      details: buffer.toString().trim(),
      error: exception,
      stackTrace: stackTrace,
    );

    _addLog(entry);
  }

  void _addLog(LogEntry entry) {
    _logs.insert(0, entry);
    _printToConsole(entry);
    notifyListeners();
  }

  void _printToConsole(LogEntry entry) {
    final prefix = switch (entry.type) {
      LogType.networkRequest => '[NETWORK REQ]',
      LogType.networkResponse => '[NETWORK RES]',
      LogType.networkError => '[NETWORK ERR]',
      LogType.exception => '[EXCEPTION]',
    };

    final message =
        '$prefix [${entry.formattedTime}] ${entry.title}\n${entry.details ?? ""}';
    debugPrint(message);
    developer.log(
      entry.title,
      name: 'books.${entry.type.name}',
      error: entry.error,
      stackTrace: entry.stackTrace,
    );
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }
}
