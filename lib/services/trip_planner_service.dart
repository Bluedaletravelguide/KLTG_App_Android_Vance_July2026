import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/models/trip_day.dart';
import 'package:kltheguide/models/trip_item.dart';

/// Backs the single running itinerary (grouped by day) shown in
/// TripPlannerPage and fed from the "Add to Trip" button on ListingCard.
/// Persists to SharedPreferences the same way the blog bookmarks feature
/// does (a JSON-encoded string list), and exposes a ValueNotifier so every
/// open view (the page, any card's day-picker) stays in sync in-memory.
class TripPlannerService {
  static const _key = 'trip_days';
  static bool _loaded = false;

  static final ValueNotifier<List<TripDay>> days = ValueNotifier<List<TripDay>>([]);

  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    days.value = raw
        .map((s) => TripDay.fromJson((json.decode(s) as Map).cast<String, dynamic>()))
        .toList();
    _loaded = true;
  }

  static Future<TripDay> addDay() async {
    await ensureLoaded();
    final day = TripDay(label: 'Day ${days.value.length + 1}');
    days.value = [...days.value, day];
    await _persist();
    return day;
  }

  static Future<void> removeDay(int dayIndex) async {
    await ensureLoaded();
    final updated = [...days.value]..removeAt(dayIndex);
    // Relabel survivors sequentially so a later addDay() can't compute a
    // "Day N" that collides with one still in the list.
    days.value = [
      for (var i = 0; i < updated.length; i++)
        TripDay(label: 'Day ${i + 1}', items: updated[i].items),
    ];
    await _persist();
  }

  /// Returns false (and does nothing) if this place is already in that day.
  static Future<bool> addItem(int dayIndex, TripItem item) async {
    await ensureLoaded();
    final day = days.value[dayIndex];
    if (day.items.any((i) => i.dedupeKey == item.dedupeKey)) return false;
    final updated = [...days.value];
    updated[dayIndex] = TripDay(label: day.label, items: [...day.items, item]);
    days.value = updated;
    await _persist();
    return true;
  }

  /// Sets (or clears, if null) the scheduled time for a place already in a
  /// day. Matched by dedupeKey since TripItem has no stable id.
  static Future<void> setItemTime(int dayIndex, TripItem item, int? scheduledMinutes) async {
    await ensureLoaded();
    final day = days.value[dayIndex];
    final updated = [...days.value];
    updated[dayIndex] = TripDay(
      label: day.label,
      items: [
        for (final i in day.items)
          if (i.dedupeKey == item.dedupeKey) i.copyWithTime(scheduledMinutes) else i,
      ],
    );
    days.value = updated;
    await _persist();
  }

  /// Sets (or clears, if null) the estimated cost for a place already in a
  /// day. Matched by dedupeKey since TripItem has no stable id.
  static Future<void> setItemCost(int dayIndex, TripItem item, double? estimatedCost) async {
    await ensureLoaded();
    final day = days.value[dayIndex];
    final updated = [...days.value];
    updated[dayIndex] = TripDay(
      label: day.label,
      items: [
        for (final i in day.items)
          if (i.dedupeKey == item.dedupeKey) i.copyWithCost(estimatedCost) else i,
      ],
    );
    days.value = updated;
    await _persist();
  }

  static Future<void> removeItem(int dayIndex, TripItem item) async {
    await ensureLoaded();
    final day = days.value[dayIndex];
    final updated = [...days.value];
    updated[dayIndex] = TripDay(
      label: day.label,
      items: day.items.where((i) => i.dedupeKey != item.dedupeKey).toList(),
    );
    days.value = updated;
    await _persist();
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      days.value.map((d) => json.encode(d.toJson())).toList(),
    );
  }

  @visibleForTesting
  static void resetForTesting() {
    _loaded = false;
    days.value = [];
  }
}
