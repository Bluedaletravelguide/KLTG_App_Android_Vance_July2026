import 'dart:io';

/// Platform-specific AdMob unit IDs. The Android banner unit must not be
/// reused on iOS — it belongs to a different AdMob platform entry and serves
/// zero ads there.
class AdConfig {
  static String get bannerAdUnitId {
    if (Platform.isIOS) {
      // TODO: replace with the real iOS banner unit before App Store release.
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return const String.fromEnvironment(
      'ADMOB_BANNER_ID',
      defaultValue: 'ca-app-pub-7002644831588730/4427349537',
    );
  }
}
