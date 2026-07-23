import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/home_page_v2.dart';

class AccentColorService {
  static const _prefsKey = 'app_accent_preset';

  static Future<AccentPreset> loadSavedAccentPreset() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefsKey);
    return AccentPreset.values.firstWhere(
      (p) => p.name == value,
      orElse: () => AccentPreset.blue,
    );
  }

  static Future<void> saveAccentPreset(AccentPreset preset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, preset.name);
  }
}
