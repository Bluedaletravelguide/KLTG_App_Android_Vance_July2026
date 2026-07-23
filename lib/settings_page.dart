import 'package:flutter/material.dart';
import 'package:kltheguide/generated/l10n.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/l10n/app_languages.dart';
import 'package:kltheguide/language_selection_page.dart';
import 'package:kltheguide/main.dart';
import 'package:kltheguide/services/preferences_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showPromoPopups = true;
  bool _pushNotificationsEnabled = true;
  bool _loadedPrefs = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final showPromoPopups = await PreferencesService.getShowPromoPopups();
    final pushNotificationsEnabled =
        await PreferencesService.getPushNotificationsEnabled();
    if (!mounted) return;
    setState(() {
      _showPromoPopups = showPromoPopups;
      _pushNotificationsEnabled = pushNotificationsEnabled;
      _loadedPrefs = true;
    });
  }

  Widget _sectionLabel(String text, HomePalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Raleway',
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
          letterSpacing: 0.6,
          color: palette.textSecondary,
        ),
      ),
    );
  }

  Widget _accentSwatch({
    required AccentPreset preset,
    required bool selected,
    required HomePalette palette,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: preset.lightAccent,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? palette.textPrimary : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            preset.label,
            style: TextStyle(fontSize: 11.5, color: palette.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(HomePalette palette, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = languageForCode(Localizations.localeOf(context).languageCode);
    final currentThemeMode = MyApp.themeModeOf(context);
    final currentAccentPreset = MyApp.accentColorOf(context);
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.accent),
        title: Text(
          S.of(context).settings,
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _sectionLabel('GENERAL', palette),
          _sectionCard(
            palette,
            child: ListTile(
              leading: Icon(Icons.language, color: palette.accent),
              title: Text(
                S.of(context).language,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              subtitle: Text(
                '${currentLanguage.flag}  ${currentLanguage.nativeName}',
                style: TextStyle(color: palette.textSecondary),
              ),
              trailing: Icon(Icons.chevron_right, color: palette.textSecondary),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageSelectionPage()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('APPEARANCE', palette),
          _sectionCard(
            palette,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dark_mode_outlined, color: palette.accent),
                      const SizedBox(width: 12),
                      Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<ThemeMode>(
                    style: SegmentedButton.styleFrom(
                      backgroundColor: palette.background,
                      foregroundColor: palette.textPrimary,
                      selectedBackgroundColor: palette.accent,
                      selectedForegroundColor: Colors.white,
                      side: BorderSide(color: palette.accent.withValues(alpha: 0.3)),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.settings_suggest_outlined),
                      ),
                    ],
                    selected: {currentThemeMode},
                    onSelectionChanged: (selection) {
                      MyApp.setThemeMode(context, selection.first);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Accent Color',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      for (final preset in AccentPreset.values)
                        _accentSwatch(
                          preset: preset,
                          selected: preset == currentAccentPreset,
                          palette: palette,
                          onTap: () => MyApp.setAccentColor(context, preset),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('NOTIFICATIONS', palette),
          _sectionCard(
            palette,
            child: SwitchListTile(
              secondary: Icon(Icons.notifications_outlined, color: palette.accent),
              title: Text(
                'Promotional Popups',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              subtitle: Text(
                'Show ad and voucher popups on launch',
                style: TextStyle(color: palette.textSecondary),
              ),
              activeThumbColor: palette.accent,
              value: _loadedPrefs ? _showPromoPopups : true,
              onChanged: !_loadedPrefs
                  ? null
                  : (value) {
                      setState(() => _showPromoPopups = value);
                      PreferencesService.setShowPromoPopups(value);
                    },
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            palette,
            child: SwitchListTile(
              secondary: Icon(Icons.campaign_outlined, color: palette.accent),
              title: Text(
                'Push Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              subtitle: Text(
                'Get alerts for new vouchers, events, and updates',
                style: TextStyle(color: palette.textSecondary),
              ),
              activeThumbColor: palette.accent,
              value: _loadedPrefs ? _pushNotificationsEnabled : true,
              onChanged: !_loadedPrefs
                  ? null
                  : (value) {
                      setState(() => _pushNotificationsEnabled = value);
                      PreferencesService.setPushNotificationsEnabled(value);
                      if (value) {
                        OneSignal.Notifications.requestPermission(true);
                        OneSignal.User.pushSubscription.optIn();
                      } else {
                        OneSignal.User.pushSubscription.optOut();
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
