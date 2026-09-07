import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kltheguide/theme/app_icons.dart';
import 'generated/l10n.dart';
import 'bookmarks_page.dart';
import 'camera_scanner_page.dart';
import 'travel_buddy_page.dart';
import 'contact_us.dart';
import 'notification_inbox_page.dart';
import 'search_page.dart';
import 'services/api_service.dart';
import 'services/url_service.dart';
import 'services/weather_service.dart';
import 'travel_tools_page.dart';
import 'trip_planner_page.dart';
import 'widgets/quick_access_tile.dart';

// Redesigned Home tab (magazine-style greeting + weather + highlight cards).
// Kept alongside the classic `HomeScreen` in home_page.dart — see the
// "Home Design" toggle in Settings, which lets users switch back instantly.
class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> {
  Map<String, dynamic> _siteInfo = {};
  WeatherInfo? _weather;
  bool _weatherFailed = false;

  static const List<String> _highlightsKeys = [
    'glance',
    'getaround',
    'traveltips'
  ];
  static const List<String> _recommendationsKeys = [
    'explorekl',
    'shop',
    'stay',
    'spa',
    'medical',
    'beyondkl',
  ];

  // appHomeHighlights/appHomeRecommendations' backing DB tables don't exist
  // on the live server (never migrated), so these card images are hardcoded
  // from kltheguide.com.my's own homepage rather than fetched.
  static const Map<String, dynamic> _highlightsImages = {
    'glance':
        'https://new.kltheguide.com.my/assets/img/highlights/kl@aglance.jpg',
    'getaround':
        'https://new.kltheguide.com.my/assets/img/highlights/gettingaroundkl.jpg',
    'traveltips':
        'https://new.kltheguide.com.my/assets/img/highlights/traveltips.jpg',
  };
  static const Map<String, dynamic> _recommendationsImages = {
    'explorekl':
        'https://new.kltheguide.com.my/assets/img/recommendation/ExploringKL.jpg',
    'shop':
        'https://new.kltheguide.com.my/assets/img/recommendation/ShopLikeLocal.jpg',
    'stay':
        'https://new.kltheguide.com.my/assets/img/recommendation/PlaceToStay.jpg',
    'spa':
        'https://new.kltheguide.com.my/assets/img/recommendation/SpaTime.jpg',
    'medical':
        'https://new.kltheguide.com.my/assets/img/recommendation/MedicalTourism.jpg',
    'beyondkl':
        'https://new.kltheguide.com.my/assets/img/recommendation/BeyondKL.jpg',
  };

  @override
  void initState() {
    super.initState();
    fetchSiteInfo().then((info) {
      if (mounted) setState(() => _siteInfo = info);
    }).catchError((_) {});
    WeatherService.fetchKLWeather().then((w) {
      if (mounted) setState(() => _weather = w);
    }).catchError((_) {
      if (mounted) setState(() => _weatherFailed = true);
    });
  }

  void _launchSocial(String key, {String Function(String)? transform}) {
    final raw = field(_siteInfo, key);
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Link unavailable, please try again later.')),
      );
      return;
    }
    UrlService.launchURL(transform != null ? transform(raw) : raw);
  }

  void _openHighlight(int index, List<String> titles) {
    Navigator.pushNamed(context, '/highlights-$index',
        arguments: {'index': index, 'titles': titles});
  }

  void _openRecommendation(int index, List<String> titles) {
    Navigator.pushNamed(context, '/rmd-$index',
        arguments: {'index': index, 'titles': titles});
  }

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    final titlesHighlights = [
      S.of(context).klAtAGlance,
      S.of(context).gettingAroundKL,
      S.of(context).travelTips,
    ];
    final titlesRmd = [
      S.of(context).exploreKL,
      S.of(context).shopLikeLocals,
      S.of(context).placesToStay,
      S.of(context).spaTime,
      S.of(context).medicalTourism,
      S.of(context).beyondKL,
    ];
    final highlightImages =
        _highlightsKeys.map((k) => field(_highlightsImages, k)).toList();
    final rmdImages = _recommendationsKeys
        .map((k) => field(_recommendationsImages, k))
        .toList();

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingHeader(palette),
                const SizedBox(height: 24),
                _buildQuickAccess(palette),
                const SizedBox(height: 30),
                _buildSectionTitle(S.of(context).klHighlights, palette),
                const SizedBox(height: 14),
                _buildHighlightsGrid(
                    highlightImages, titlesHighlights, palette),
                const SizedBox(height: 30),
                _buildSectionTitle(S.of(context).recommendations, palette),
                const SizedBox(height: 14),
                _buildRecommendationsRow(rmdImages, titlesRmd, palette),
                const SizedBox(height: 30),
                _buildSectionTitle('Stay Connected', palette),
                const SizedBox(height: 14),
                _buildStayConnected(palette),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: kBottomNavigationBarHeight + 20,
            child: FloatingActionButton(
              heroTag: 'home-v2-chat-fab',
              elevation: 3,
              tooltip: 'KL Buddy',
              backgroundColor: palette.accent,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TravelBuddyPage()),
                );
              },
              child: const Icon(Icons.forum_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader(HomePalette palette) {
    // Greeting gets the full row width to itself so it never has to fight
    // the quick-action buttons for space and wrap awkwardly; the scan and
    // weather chips sit on their own row underneath.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Text(
          'Discover Kuala Lumpur today',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 14,
            color: palette.textSecondary,
          ),
        ),
        const SizedBox(height: 18),
        _buildSearchBar(palette),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildScanButton(palette),
            const SizedBox(width: 10),
            _buildWeatherCard(palette),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(HomePalette palette) {
    // A tappable "fake" search bar, not a real text field — matches the
    // pattern used by Maps/Airbnb: opens SearchPage with its own field
    // already focused, and Hero-flies into that page's real search bar so
    // the transition reads as one continuous element rather than a new page.
    return Hero(
      tag: 'home-search-bar',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchPage()),
          ),
          child: Semantics(
            button: true,
            label: 'Search shops, stays, spas, medical tourism, and Beyond KL',
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: palette.textSecondary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search shops, stays, spas…',
                      style: TextStyle(
                          color: palette.textSecondary, fontSize: 14.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton(HomePalette palette) {
    return Tooltip(
      message: 'Scan a landmark',
      child: Material(
        color: palette.card,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CameraScannerPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                Icon(Icons.camera_alt_rounded, color: palette.accent, size: 21),
          ),
        ),
      ),
    );
  }

  void _showForecastSheet(HomePalette palette) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: palette.card,
      builder: (_) => _ForecastSheet(palette: palette),
    );
  }

  Widget _buildWeatherCard(HomePalette palette) {
    final weather = _weather;
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showForecastSheet(palette),
        child: Semantics(
          button: true,
          label: 'Weather, view 6-day forecast',
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(weather?.icon ?? Icons.wb_cloudy_outlined,
                    color: palette.accent, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kuala Lumpur',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: palette.textPrimary,
                        ),
                      ),
                      Text(
                        weather != null
                            ? '${weather.temperatureC.round()}°C, ${weather.description}'
                            : (_weatherFailed ? 'Unavailable' : 'Loading…'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11.5, color: palette.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text, HomePalette palette) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Raleway',
        fontSize: 21,
        fontWeight: FontWeight.w800,
        color: palette.textPrimary,
      ),
    );
  }

  Widget _buildHighlightsGrid(
      List<String> images, List<String> titles, HomePalette palette) {
    // Defensive fallback: if the backend ever returns a different item
    // count, degrade to a simple stacked list instead of an index error.
    if (images.length < 3 || titles.length < 3) {
      return Column(
        children: [
          for (int i = 0; i < images.length; i++) ...[
            if (i != 0) const SizedBox(height: 12),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: _HighlightTile(
                imageUrl: images[i],
                title: titles.length > i ? titles[i] : '',
                titleFontSize: 16,
                palette: palette,
                onTap: () => _openHighlight(i, titles),
              ),
            ),
          ],
        ],
      );
    }
    return SizedBox(
      height: 280,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: _HighlightTile(
              imageUrl: images[0],
              title: titles[0],
              titleFontSize: 19,
              palette: palette,
              onTap: () => _openHighlight(0, titles),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Expanded(
                  child: _HighlightTile(
                    imageUrl: images[1],
                    title: titles[1],
                    titleFontSize: 14,
                    palette: palette,
                    onTap: () => _openHighlight(1, titles),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _HighlightTile(
                    imageUrl: images[2],
                    title: titles[2],
                    titleFontSize: 14,
                    palette: palette,
                    onTap: () => _openHighlight(2, titles),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsRow(
      List<String> images, List<String> titles, HomePalette palette) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 200,
            child: _HighlightTile(
              imageUrl: images[index],
              title: titles[index],
              titleFontSize: 15,
              palette: palette,
              onTap: () => _openRecommendation(index, titles),
            ),
          );
        },
      ),
    );
  }

  // Frequently-used features get a first-class spot on Home instead of being
  // buried in the shared ⋮ menu — Home is always one tap away via the
  // bottom nav, so this costs nothing extra for the common case.
  Widget _buildQuickAccess(HomePalette palette) {
    final actions = <(IconData, String, VoidCallback)>[
      (
        Icons.card_travel,
        'My Trip',
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TripPlannerPage()),
            ),
      ),
      (
        Icons.bookmark_outline,
        'Bookmarks',
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookmarkPage()),
            ),
      ),
      (
        Icons.explore_outlined,
        'Travel Tools',
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TravelToolsPage()),
            ),
      ),
      (
        Icons.notifications_none_rounded,
        'Notifications',
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationInboxPage()),
            ),
      ),
    ];
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(
            child: QuickAccessTile(
              icon: actions[i].$1,
              label: actions[i].$2,
              palette: palette,
              onTap: actions[i].$3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStayConnected(HomePalette palette) {
    final actions = <(IconData, String, VoidCallback)>[
      (
        MyFlutterApp.instagram_1,
        'Follow us on Instagram',
        () => _launchSocial('instagram_url'),
      ),
      (
        MyFlutterApp.whatsapp,
        'Message us on WhatsApp',
        () => _launchSocial('whatsapp', transform: whatsappUri),
      ),
      (
        Icons.support_agent_rounded,
        'Contact Support',
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContactUsPage()),
            ),
      ),
    ];
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(
            child: QuickAccessTile(
              icon: actions[i].$1,
              label: actions[i].$2,
              palette: palette,
              onTap: actions[i].$3,
            ),
          ),
        ],
      ],
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;
  final HomePalette palette;
  final double titleFontSize;

  const _HighlightTile({
    required this.imageUrl,
    required this.title,
    required this.onTap,
    required this.palette,
    this.titleFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: palette.card),
              errorWidget: (context, url, error) => Container(
                color: palette.card,
                child: Icon(Icons.image_not_supported_outlined,
                    color: palette.textSecondary),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.78)
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: palette.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Read More',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastSheet extends StatefulWidget {
  final HomePalette palette;

  const _ForecastSheet({required this.palette});

  @override
  State<_ForecastSheet> createState() => _ForecastSheetState();
}

class _ForecastSheetState extends State<_ForecastSheet> {
  List<DailyForecast>? _forecast;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    WeatherService.fetchKLForecast().then((forecast) {
      if (mounted) setState(() => _forecast = forecast);
    }).catchError((_) {
      if (mounted) setState(() => _error = true);
    });
  }

  String _weekday(DateTime date) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '6-Day Forecast · Kuala Lumpur',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (_error)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Could not load the forecast. Try again later.',
                  style: TextStyle(color: palette.textSecondary),
                ),
              )
            else if (_forecast == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                    child: CircularProgressIndicator(color: palette.accent)),
              )
            else
              for (final day in _forecast!)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          _weekday(day.date),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                      Icon(day.icon, color: palette.accent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          day.description,
                          style: TextStyle(
                              color: palette.textSecondary, fontSize: 13.5),
                        ),
                      ),
                      Text(
                        '${day.maxC.round()}° / ${day.minC.round()}°',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// User-selectable accent color for HomePalette (see Settings > Appearance).
// Blue is the default; Coral is the original hue the cream/coral redesign
// shipped with. Each preset carries a light- and dark-mode variant so it
// keeps the same lightness/contrast relationship the original coral did.
enum AccentPreset {
  blue,
  coral,
  green,
  purple,
  teal;

  String get label => switch (this) {
        AccentPreset.blue => 'Blue',
        AccentPreset.coral => 'Coral',
        AccentPreset.green => 'Green',
        AccentPreset.purple => 'Purple',
        AccentPreset.teal => 'Teal',
      };

  Color get lightAccent => switch (this) {
        AccentPreset.blue => const Color(0xFF3B6FE0),
        AccentPreset.coral => const Color(0xFFE07856),
        AccentPreset.green => const Color(0xFF3F9D63),
        AccentPreset.purple => const Color(0xFF8B5FBF),
        AccentPreset.teal => const Color(0xFF2E9C9C),
      };

  Color get darkAccent => switch (this) {
        AccentPreset.blue => const Color(0xFF6FA0F0),
        AccentPreset.coral => const Color(0xFFE8836F),
        AccentPreset.green => const Color(0xFF6BC28A),
        AccentPreset.purple => const Color(0xFFAB85D9),
        AccentPreset.teal => const Color(0xFF5DC2C2),
      };
}

// Exposes the app-wide accent preset (set via Settings > Appearance) to
// every screen that reads `HomePalette.of(context)`. Lives above
// `MaterialApp` in main.dart's `_MyAppState.build()`.
class AccentScope extends InheritedWidget {
  final AccentPreset preset;

  const AccentScope({super.key, required this.preset, required super.child});

  static AccentPreset of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AccentScope>();
    return scope?.preset ?? AccentPreset.blue;
  }

  @override
  bool updateShouldNotify(AccentScope oldWidget) => oldWidget.preset != preset;
}

class HomePalette {
  final Color background;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  const HomePalette({
    required this.background,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
  });

  factory HomePalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preset = AccentScope.of(context);
    final accent = isDark ? preset.darkAccent : preset.lightAccent;

    if (isDark) {
      return HomePalette(
        background: const Color(0xFF1C1A17),
        card: const Color(0xFF2A2622),
        textPrimary: const Color(0xFFF5EFE6),
        textSecondary: const Color(0xFFBBB2A4),
        accent: accent,
      );
    }
    return HomePalette(
      background: const Color(0xFFF8F3EA),
      card: Colors.white,
      textPrimary: const Color(0xFF2B2420),
      textSecondary: const Color(0xFF7A7168),
      accent: accent,
    );
  }
}
