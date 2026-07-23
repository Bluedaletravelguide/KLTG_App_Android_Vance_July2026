import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _promoPopupsKey = 'show_promo_popups';
  static const _pushNotificationsKey = 'push_notifications_enabled';

  static Future<bool> getShowPromoPopups() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_promoPopupsKey) ?? true;
  }

  static Future<void> setShowPromoPopups(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promoPopupsKey, value);
  }

  static Future<bool> getPushNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushNotificationsKey) ?? true;
  }

  static Future<void> setPushNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushNotificationsKey, value);
  }
}
