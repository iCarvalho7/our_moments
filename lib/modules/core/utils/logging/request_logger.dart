import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Pretty, colorful logging for backend (Firebase) requests.
///
/// Wrap any async data-source call with [RequestLogger.track] to get a nicely
/// formatted, single-block log in the console showing the operation, its
/// parameters, how long it took and whether it succeeded:
///
/// ```dart
/// Future<MomentModel> fetchMoment(String id) => RequestLogger.track(
///       'Moment.fetchMoment',
///       params: {'momentId': id},
///       request: () async {
///         final result = await momentsDBRef.where('id', isEqualTo: id).get();
///         return result.docs.first.data();
///       },
///     );
/// ```
///
/// Logging is a no-op in release/profile builds, so production stays clean.
class RequestLogger {
  const RequestLogger._();

  // ANSI escape codes — rendered as colors by most IDE / terminal consoles.
  static const _reset = '\x1B[0m';
  static const _dim = '\x1B[90m';
  static const _bold = '\x1B[1m';
  static const _cyan = '\x1B[36m';
  static const _green = '\x1B[32m';
  static const _red = '\x1B[31m';
  static const _magenta = '\x1B[35m';

  static const _width = 64;

  static const _jsonEncoder = JsonEncoder.withIndent('  ', _toEncodable);


  /// Runs [request], measuring its duration, and prints a pretty log block.
  ///
  /// The full block is buffered and printed at once so concurrent requests
  /// (e.g. `Future.wait`) never interleave their lines. The original result is
  /// returned and any error is re-thrown untouched.
  static Future<T> track<T>(
    String operation, {
    required Future<T> Function() request,
    Map<String, dynamic>? params,
  }) async {
    if (!kDebugMode) return request();

    final stopwatch = Stopwatch()..start();
    try {
      final result = await request();
      stopwatch.stop();
      _emit(
        operation: operation,
        params: params,
        elapsedMs: stopwatch.elapsedMilliseconds,
        result: result,
      );
      return result;
    } catch (error) {
      stopwatch.stop();
      _emit(
        operation: operation,
        params: params,
        elapsedMs: stopwatch.elapsedMilliseconds,
        error: error,
      );
      rethrow;
    }
  }

  static void _emit({
    required String operation,
    required int elapsedMs,
    Map<String, dynamic>? params,
    Object? result,
    Object? error,
  }) {
    final isError = error != null;
    final accent = isError ? _red : _green;
    final icon = isError ? '🔥' : '🔥';

    final lines = <String>[
      '$accent┌─ $icon ${_bold}REQUEST$_reset$accent ─ $_cyan$operation$_reset',
    ];

    if (params != null && params.isNotEmpty) {
      lines.add('$accent│$_reset $_magenta📤 params$_reset');
      _appendJson(lines, accent, _magenta, params);
    }

    if (isError) {
      lines.add('$accent│$_reset ❌ ${_bold}ERROR$_reset $accent· ${_timing(elapsedMs)}');
      lines.add('$accent│$_reset 💥 $_red${_describeError(error)}$_reset');
    } else {
      final count = result is Iterable ? ' $_dim(${result.length} items)$_reset' : '';
      lines.add('$accent│$_reset ✅ ${_bold}OK$_reset $_green· ${_timing(elapsedMs)}$_reset 📥 ${_cyan}response$_reset$count');
      _appendJson(lines, accent, _cyan, result);
    }

    lines.add('$accent└${'─' * _width}$_reset');

    for (final line in lines) {
      debugPrint(line);
    }
  }

  /// Encodes [value] as pretty JSON and adds each line, prefixed by the box
  /// border. Falls back to a plain string if the value cannot be serialized.
  static void _appendJson(List<String> lines, String accent, String color, Object? value) {
    final json = _encode(value);
    for (final line in json.split('\n')) {
      lines.add('$accent│$_reset $color$line$_reset');
    }
  }

  static String _encode(Object? value) {
    if (value == null) return 'null';
    try {
      return _jsonEncoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  /// Makes arbitrary objects JSON-encodable: model classes via their `toJson`,
  /// everything else via `toString` so encoding never throws.
  static Object? _toEncodable(dynamic object) {
    try {
      return object.toJson();
    } catch (_) {
      return object.toString();
    }
  }

  static String _timing(int ms) {
    final slow = ms >= 1000;
    final mark = slow ? '🐢' : '⚡';
    return '$mark ${ms}ms';
  }

  static String _describeError(Object error) {
    final message = error.toString().replaceAll('\n', ' ');
    return '${error.runtimeType}: $message';
  }
}
