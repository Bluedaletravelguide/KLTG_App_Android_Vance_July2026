import 'package:shared_preferences/shared_preferences.dart';

/// Most-recent-first list of past search queries, shown as tappable chips
/// on SearchPage before the user types anything. Capped and deduped so it
/// stays a quick-repeat list rather than a full history log.
class RecentSearchesService {
  static const _key = 'recent_searches';
  static const _maxEntries = 8;

  static Future<List<String>> getRecent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? <String>[];
  }

  static Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? <String>[];
    final updated = [
      trimmed,
      ...existing.where((e) => e.toLowerCase() != trimmed.toLowerCase()),
    ].take(_maxEntries).toList();
    await prefs.setStringList(_key, updated);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
