import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Generic read-through cache for API responses, backed by [SharedPreferences].
///
/// On a successful [fetch], the result is persisted and returned normally.
/// On failure (no connection, timeout, server error), the last persisted
/// value for [key] is returned instead (if one exists) and
/// [isServingCachedContent] is flipped to true so the UI can show an
/// "offline / showing saved content" banner. If nothing has ever been
/// cached for [key], the original error is rethrown so the existing
/// loading/error/retry UI still applies.
class CacheService {
  static final ValueNotifier<bool> isServingCachedContent =
      ValueNotifier<bool>(false);

  static const _prefix = 'cache_';

  static Future<T> cached<T>({
    required String key,
    required Future<T> Function() fetch,
    required String Function(T value) encode,
    required T Function(String raw) decode,
  }) async {
    try {
      final result = await fetch();
      isServingCachedContent.value = false;
      unawaited(_write(key, encode(result)));
      return result;
    } catch (error) {
      final raw = await _read(key);
      if (raw == null) rethrow;
      isServingCachedContent.value = true;
      return decode(raw);
    }
  }

  static Future<void> _write(String key, String raw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', raw);
  }

  static Future<String?> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$key');
  }
}
