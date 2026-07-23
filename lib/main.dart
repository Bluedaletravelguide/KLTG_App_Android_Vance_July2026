// ignore_for_file: constant_identifier_names
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kltheguide/app_routes.dart';
import 'package:kltheguide/blog_page.dart';
import 'package:kltheguide/ebook_page.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/models/image_data.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:kltheguide/voucher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:kltheguide/maps_page.dart';
import 'package:kltheguide/onboarding_page.dart';
import 'package:kltheguide/services/notification_inbox_service.dart';
import 'package:kltheguide/services/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/theme/app_theme.dart';
import 'package:kltheguide/services/url_service.dart';
import 'package:kltheguide/services/locale_service.dart';
import 'package:kltheguide/services/theme_service.dart';
import 'package:kltheguide/services/accent_color_service.dart';
import 'package:kltheguide/services/preferences_service.dart';
import 'package:kltheguide/services/ad_config.dart';
import 'package:kltheguide/settings_page.dart';


// From the OneSignal dashboard (Settings > Keys & IDs). This is a public
// identifier, safe to compile into the app — not a secret.
const String kOneSignalAppId = '2a0a2a6c-040b-49ae-967a-4ddf232ce7c8';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;

  OneSignal.initialize(kOneSignalAppId);
  if (await PreferencesService.getPushNotificationsEnabled()) {
    OneSignal.Notifications.requestPermission(true);
  } else {
    OneSignal.User.pushSubscription.optOut();
  }
  // Records notifications locally for the in-app Notifications inbox.
  // OneSignal has no API to retrieve ones delivered while fully closed, so
  // this only captures what arrives while the app can observe it.
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    final n = event.notification;
    NotificationInboxService.add(n.title ?? '', n.body ?? '');
  });
  OneSignal.Notifications.addClickListener((event) {
    final n = event.notification;
    NotificationInboxService.add(n.title ?? '', n.body ?? '');
  });

  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  final savedLocale = await LocaleService.loadSavedLocale();
  final savedThemeMode = await ThemeService.loadSavedThemeMode();
  final savedAccentPreset = await AccentColorService.loadSavedAccentPreset();
  final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();

  runApp(MyApp(
    initialLocale: savedLocale,
    initialThemeMode: savedThemeMode,
    initialAccentPreset: savedAccentPreset,
    showOnboarding: !hasSeenOnboarding,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.initialLocale,
    this.initialThemeMode,
    this.initialAccentPreset,
    this.showOnboarding = false,
  });

  final Locale? initialLocale;
  final ThemeMode? initialThemeMode;
  final AccentPreset? initialAccentPreset;
  final bool showOnboarding;

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }

  static void setThemeMode(BuildContext context, ThemeMode newMode) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeThemeMode(newMode);
  }

  static ThemeMode themeModeOf(BuildContext context) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    return state?._themeMode ?? ThemeMode.system;
  }

  static void setAccentColor(BuildContext context, AccentPreset preset) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeAccentColor(preset);
  }

  static AccentPreset accentColorOf(BuildContext context) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    return state?._accentPreset ?? AccentPreset.blue;
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;
  AccentPreset _accentPreset = AccentPreset.blue;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _themeMode = widget.initialThemeMode ?? ThemeMode.system;
    _accentPreset = widget.initialAccentPreset ?? AccentPreset.blue;
  }

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    LocaleService.saveLocale(locale);
  }

  void changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    ThemeService.saveThemeMode(mode);
  }

  void changeAccentColor(AccentPreset preset) {
    setState(() {
      _accentPreset = preset;
    });
    AccentColorService.saveAccentPreset(preset);
  }

  @override
  Widget build(BuildContext context) {
    return AccentScope(
      preset: _accentPreset,
      child: MaterialApp(
        title: 'KL The Guide',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        locale: _locale,
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: widget.showOnboarding
            ? const OnboardingPage()
            : const MyHomePage(title: 'Home'),
        routes: appRoutes,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int currentPageIndex = 0;

  final String desiredVersion = '1.5.0';

  late BannerAd _bannerAd;
  DateTime? currentBackPressTime;
  bool isDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );

    _bannerAd.load();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersionAndShowDialog();
      if (!isDialogShown) {
        fetchDataFromApi();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowVoucherPopup();
    });
  }

  Future<void> _checkAndShowVoucherPopup() async {
    try {
      if (!await PreferencesService.getShowPromoPopups()) return;

      final vouchers = await fetchVouchers();
      final currentIds = vouchers.map((v) => v.voucher).toSet();

      final prefs = await SharedPreferences.getInstance();
      final seenIds = (prefs.getStringList('seen_voucher_ids') ?? []).toSet();
      final hasNewVoucher = currentIds.difference(seenIds).isNotEmpty;

      await prefs.setStringList('seen_voucher_ids', currentIds.toList());

      // Only pop up if we've checked before (skip the very first launch) and
      // a voucher genuinely wasn't in the last-seen set.
      if (hasNewVoucher && seenIds.isNotEmpty && mounted) {
        _showVoucherPopup();
      }
    } catch (_) {
      // Couldn't verify vouchers right now; skip the popup rather than
      // risk showing it (or not) incorrectly.
    }
  }

  void _showVoucherPopup() {
    final palette = HomePalette.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: palette.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_offer,
                  color: palette.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'New Vouchers Available!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'New vouchers have been added. Check them out!',
            style: TextStyle(fontSize: 15, color: palette.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: palette.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToVoucherScreen();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('View'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToVoucherScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VoucherScreen()),
    );
  }

  Future<void> _checkVersionAndShowDialog() async {
    if (Platform.isAndroid) {
      try {
        AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
        if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
          if (updateInfo.immediateUpdateAllowed) {
            InAppUpdate.performImmediateUpdate();
          } else if (updateInfo.flexibleUpdateAllowed) {
            InAppUpdate.startFlexibleUpdate().then((_) {
              InAppUpdate.completeFlexibleUpdate();
            });
          }
        }
      } catch (e) {
        print("Error checking for updates: $e");
      }
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final currentBuildNumber = packageInfo.buildNumber;

    final desiredVersionAndBuild = await _fetchDesiredVersionAndBuild();
    final String desiredVersion = desiredVersionAndBuild['version']!;
    final String desiredBuildNumber = desiredVersionAndBuild['buildNumber']!;

    if (_isUpdateRequired(currentVersion, desiredVersion, currentBuildNumber,
        desiredBuildNumber)) {
      _showUpdateDialog(context);
    }
  }

  Map<String, dynamic>? _adsSettingsCache;

  Future<Map<String, dynamic>> _fetchAdsSettings() async {
    if (_adsSettingsCache != null) return _adsSettingsCache!;
    final response = await http
        .post(
          Uri.parse('https://www.kltheguide.com.my/admin/functions.php'),
          body: {'appAdsSettings': 'appAdsSettings'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch app ads settings');
    }
    _adsSettingsCache = json.decode(response.body);
    return _adsSettingsCache!;
  }

  Future<Map<String, String>> _fetchDesiredVersionAndBuild() async {
    final jsonData = await _fetchAdsSettings();
    return {
      'version': jsonData['desiredVersion'],
      'buildNumber': jsonData['desiredBuildNumber'],
    };
  }

  bool _isUpdateRequired(String currentVersion, String desiredVersion,
      String currentBuildNumber, String desiredBuildNumber) {
    List<int> currentVersionParts =
        currentVersion.split('.').map(int.parse).toList();
    List<int> desiredVersionParts =
        desiredVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < currentVersionParts.length; i++) {
      if (currentVersionParts[i] < desiredVersionParts[i]) {
        return true;
      } else if (currentVersionParts[i] > desiredVersionParts[i]) {
        return false;
      }
    }

    return int.parse(currentBuildNumber) < int.parse(desiredBuildNumber);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      currentBackPressTime = null;
    }
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.system_update,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Update Required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            'A new version of the app is available. Please update to enjoy new features of the app.',
            style: TextStyle(fontSize: 15),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Update Later',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                UrlService.launchURL(
                    'https://play.google.com/store/apps/details?id=my.com.kltheguide&hl=en&gl=US');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Update Now'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Press back again to exit'),
            ],
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return false;
    }
    return true;
  }

  Future<List<ImageData>> fetchImageUrls() async {
    try {
      final response = await http
          .post(
            Uri.parse('https://www.kltheguide.com.my/admin/functions.php'),
            body: {'appAdsURL': 'appAdsURL'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<ImageData> imageUrls = jsonData.map((item) {
          return ImageData(
            imageUrl: item['imageURL'] as String,
            actionUrl: item['URL'] as String,
          );
        }).toList();

        return imageUrls;
      } else {
        throw Exception('Failed to load image URLs from the API');
      }
    } catch (e) {
      print('Error fetching image URLs: $e');
      return [];
    }
  }

  Future<void> fetchDataFromApi() async {
    try {
      if (!await PreferencesService.getShowPromoPopups()) return;

      final jsonData = await _fetchAdsSettings();
      var admobrandomswitch = jsonData['admobrandomswitch'];
      print(isDialogShown);
      int? switch2 = int.parse(admobrandomswitch);

      int delayInSeconds = 30;

      final Random random = Random();

      if (switch2 == 1) {
        if (random.nextInt(5) == 1) {
          if (isDialogShown) {
            _showWelcomeDialog(delayInSeconds);
          } else {
            _showWelcomeDialog(0);
            isDialogShown = true;
          }
        } else {
          final List<ImageData> imageDatas = await fetchImageUrls();
          if (imageDatas.isNotEmpty) {
            final randomImageData =
                imageDatas[random.nextInt(imageDatas.length)];
            if (isDialogShown) {
              _showRandomPopup(delayInSeconds, randomImageData);
            } else {
              _showRandomPopup(0, randomImageData);
              isDialogShown = true;
            }
          }
        }
      } else {
        final List<ImageData> imageDatas = await fetchImageUrls();
        if (imageDatas.isNotEmpty) {
          final randomImageData =
              imageDatas[random.nextInt(imageDatas.length)];
          if (isDialogShown) {
            _showRandomPopup(delayInSeconds, randomImageData);
          } else {
            _showRandomPopup(0, randomImageData);
            isDialogShown = true;
          }
        }
      }
    } catch (e) {
      print('Error fetching data from API: $e');
    }
  }

  void _showRandomPopup(int delayInSeconds, ImageData imageData) async {
    Future.delayed(Duration(seconds: delayInSeconds), () async {
      if (imageData.imageUrl.isNotEmpty) {
        final randomImageUrl = imageData.imageUrl;

        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return FutureBuilder<void>(
              future: Future.delayed(Duration(seconds: 0), () {}),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return PopScope(
                    canPop: false,
                    child: AlertDialog(
                      shadowColor: Colors.transparent,
                      buttonPadding: EdgeInsets.zero,
                      contentPadding: EdgeInsets.zero,
                      actionsPadding: EdgeInsets.zero,
                      insetPadding: EdgeInsets.zero,
                      actionsAlignment: MainAxisAlignment.center,
                      backgroundColor: Colors.transparent,
                      content: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GestureDetector(
                          child: Image.network(
                            randomImageUrl,
                            cacheHeight: 800, // Optimize network image
                          ),
                          onTap: () {
                            if (imageData.actionUrl.isNotEmpty) {
                              print(Uri.decodeFull(imageData.actionUrl));
                              UrlService.launchURL(
                                  Uri.decodeFull(imageData.actionUrl));
                            }
                          },
                        ),
                      ),
                      actions: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              fetchDataFromApi();
                            },
                            icon: Icon(
                              Icons.close,
                              size: 24,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        );
      }
    });
  }

  void _showWelcomeDialog(int delaySec) {
    Future.delayed(Duration(seconds: delaySec), () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              buttonPadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.zero,
              actionsAlignment: MainAxisAlignment.center,
              backgroundColor: Colors.transparent,
              content: Container(
                height: 250,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AdWidget(
                    ad: _bannerAd,
                  ),
                ),
              ),
              actions: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      fetchDataFromApi();
                    },
                    icon: Icon(
                      Icons.close,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // The classic blue "KL THE GUIDE" bar has been retired for good — every
    // tab now gets the minimal cream/coral bar (icons only, no title), since
    // each tab's own body renders its own title in the new design.
    final homePalette = HomePalette.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: homePalette.background,
          iconTheme: IconThemeData(color: homePalette.accent),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              color: homePalette.accent,
              tooltip: S.of(context).settings,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
            AppBarMore(iconColor: homePalette.accent),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            backgroundColor: homePalette.card,
            indicatorColor: homePalette.accent.withValues(alpha: 0.15),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                fontSize: 12,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: states.contains(WidgetState.selected)
                    ? homePalette.textPrimary
                    : homePalette.textSecondary,
              ),
            ),
            destinations: <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home, color: homePalette.accent),
                icon: Icon(Icons.home_outlined, color: homePalette.textSecondary),
                label: S.of(context).home,
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.article, color: homePalette.accent),
                icon: Icon(Icons.article_outlined, color: homePalette.textSecondary),
                label: S.of(context).blog,
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.map, color: homePalette.accent),
                icon: Icon(Icons.map_outlined, color: homePalette.textSecondary),
                // If you want i18n later, add a `maps` key to your ARB files; for now, literal is fine:
                label: 'Maps',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.menu_book, color: homePalette.accent),
                icon: Icon(Icons.menu_book_outlined, color: homePalette.textSecondary),
                label: S.of(context).ebook,
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.discount, color: homePalette.accent),
                icon: Icon(Icons.discount_outlined, color: homePalette.textSecondary),
                label: S.of(context).Contest,
              ),
            ],
          ),
        ),
        body: [
          const HomeScreenV2(),
          const BlogListScreen(),
          const MapsPage(),
          Ebook(),
          const VoucherScreen(),
        ][currentPageIndex],
      ),
    );
  }

}
