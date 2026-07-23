import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the first-run walkthrough (OnboardingPage) has been shown,
/// so it only ever appears once per install.
class OnboardingService {
  static const _key = 'has_seen_onboarding';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
