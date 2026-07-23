import 'package:flutter/widgets.dart';

/// Single source of truth for every language the app supports.
///
/// Backed by `Locale.fromSubtags(languageCode: ...)` in
/// `generated/l10n.dart`'s `supportedLocales` — keep the `code`s here in
/// sync with the `.arb` files under `lib/l10n/`.
class AppLanguage {
  final String code;
  final String englishName;
  final String nativeName;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.flag,
  });

  Locale get locale => Locale(code);
}

const List<AppLanguage> kAppLanguages = [
  AppLanguage(code: 'en', englishName: 'English', nativeName: 'English', flag: '🇬🇧'),
  AppLanguage(code: 'ms', englishName: 'Bahasa Malaysia', nativeName: 'Bahasa Malaysia', flag: '🇲🇾'),
  AppLanguage(code: 'zh', englishName: 'Mandarin', nativeName: '中文', flag: '🇨🇳'),
  AppLanguage(code: 'ta', englishName: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
  AppLanguage(code: 'hi', englishName: 'Hindi', nativeName: 'हिंदी', flag: '🇮🇳'),
  AppLanguage(code: 'th', englishName: 'Thai', nativeName: 'ไทย', flag: '🇹🇭'),
  AppLanguage(code: 'fil', englishName: 'Tagalog', nativeName: 'Filipino', flag: '🇵🇭'),
  AppLanguage(code: 'id', englishName: 'Bahasa Indonesia', nativeName: 'Bahasa Indonesia', flag: '🇮🇩'),
  AppLanguage(code: 'es', englishName: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
  AppLanguage(code: 'pt', englishName: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
  AppLanguage(code: 'fr', englishName: 'French', nativeName: 'Français', flag: '🇫🇷'),
  AppLanguage(code: 'ru', englishName: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
];

AppLanguage languageForCode(String? code) {
  return kAppLanguages.firstWhere(
    (lang) => lang.code == code,
    orElse: () => kAppLanguages.first,
  );
}
