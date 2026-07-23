import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/models/notification_record.dart';

/// Local history of push notifications received while the app was running
/// (foreground display or tapped-to-open) — OneSignal's SDK doesn't expose a
/// way to retrieve notifications delivered while the app was fully closed,
/// so this can only capture what arrives from when a session first sees it.
class NotificationInboxService {
  static const _key = 'notification_inbox';
  static const _maxEntries = 50;
  static bool _loaded = false;

  static final ValueNotifier<List<NotificationRecord>> items =
      ValueNotifier<List<NotificationRecord>>([]);

  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    items.value = raw
        .map((s) => NotificationRecord.fromJson((json.decode(s) as Map).cast<String, dynamic>()))
        .toList();
    _loaded = true;
  }

  static Future<void> add(String title, String body) async {
    await ensureLoaded();
    final record = NotificationRecord(title: title, body: body, receivedAt: DateTime.now());
    items.value = [record, ...items.value].take(_maxEntries).toList();
    await _persist();
  }

  static Future<void> clear() async {
    await ensureLoaded();
    items.value = [];
    await _persist();
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      items.value.map((r) => json.encode(r.toJson())).toList(),
    );
  }

  @visibleForTesting
  static void resetForTesting() {
    _loaded = false;
    items.value = [];
  }
}
