import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import 'package:kltheguide/services/url_service.dart';
import 'generated/l10n.dart';
import 'services/api_service.dart';

AppBar _subPageAppBar({
  required BuildContext context,
  required String title,
  required HomePalette palette,
}) {
  return AppBar(
    backgroundColor: palette.background,
    elevation: 0,
    iconTheme: IconThemeData(color: palette.accent),
    title: Text(
      title,
      style: TextStyle(
        fontFamily: 'Raleway',
        fontWeight: FontWeight.w800,
        fontSize: 20,
        color: palette.textPrimary,
      ),
    ),
    actions: [AppBarMore(iconColor: palette.accent)],
  );
}

// ============ GLANCE PAGE ============
class GlancePage extends StatelessWidget {
  const GlancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _subPageAppBar(
        context: context,
        title: S.of(context).klAtAGlance,
        palette: palette,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Image with Overlay
            Stack(
              children: [
                CachedNetworkImage(
                  // The old hardcoded URL 404s — the file no longer exists
                  // on the live server. Replaced with the same hero image
                  // new.kltheguide.com.my uses for this page's own card.
                  imageUrl:
                      'https://new.kltheguide.com.my/assets/img/highlights/kl@aglance.jpg',
                  fit: BoxFit.cover,
                  height: 250,
                  width: double.infinity,
                  memCacheHeight: 750,
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: palette.card,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Text(
                    S.of(context).klAtAGlance,
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).klDescription1,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          S.of(context).klDescription2,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
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

// ============ GET AROUND PAGE ============
// appHighlightsTransport's backing DB table doesn't exist on the live
// server (never migrated), so these images are hardcoded from
// kltheguide.com.my's own Getting Around KL page rather than fetched.
const Map<String, dynamic> _transportImages = {
  'lrt': 'https://new.kltheguide.com.my/asset-backups/opt/LRT_Logo.jpg',
  'mrt': 'https://new.kltheguide.com.my/asset-backups/opt/MRT_Logo.jpg',
  'ktm': 'https://new.kltheguide.com.my/asset-backups/opt/KTM_Logo.jpg',
  'monorail': 'https://new.kltheguide.com.my/asset-backups/opt/Monorai_Logo.jpg',
  'bus': 'https://new.kltheguide.com.my/asset-backups/opt/RapidKL_Logo.jpg',
};

class GetAround extends StatelessWidget {
  const GetAround({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _subPageAppBar(
        context: context,
        title: S.of(context).gettingAroundKL,
        palette: palette,
      ),
      body: MyList(context: context, images: _transportImages, palette: palette),
    );
  }
}

class MyList extends StatelessWidget {
  final BuildContext context;
  final Map<String, dynamic> images;
  final HomePalette palette;

  const MyList({
    super.key,
    required this.context,
    required this.images,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final List<ItemData> items = [
      ItemData(
        S.of(this.context).lrtTitle,
        field(images, 'lrt'),
        S.of(this.context).lrtDescription,
      ),
      ItemData(
        S.of(this.context).mrtTitle,
        field(images, 'mrt'),
        S.of(this.context).mrtDescription,
      ),
      ItemData(
        S.of(this.context).ktmKomuterTitle,
        field(images, 'ktm'),
        S.of(this.context).ktmKomuterDescription,
      ),
      ItemData(
        S.of(this.context).klMonorailTitle,
        field(images, 'monorail'),
        S.of(this.context).klMonorailDescription,
      ),
      ItemData(
        S.of(this.context).rapidKLBusTitle,
        field(images, 'bus'),
        S.of(this.context).rapidKLBusDescription,
      ),
    ];

    return Container(
      color: palette.background,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Card(
                  color: palette.card,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image with badge
                      Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: items[index].imageUrl,
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                            memCacheHeight: 600,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: palette.card,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    palette.accent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: palette.accent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.directions_transit_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Option ${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[index].text,
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                color: palette.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              items[index].content,
                              style: TextStyle(
                                fontSize: 16.0,
                                height: 1.5,
                                color: palette.textSecondary,
                              ),
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
        },
      ),
    );
  }
}

class ItemData {
  final String text;
  final String imageUrl;
  final String content;

  ItemData(this.text, this.imageUrl, this.content);
}

// ============ TRAVEL TIPS PAGE ============
// appHighlightsTravelTips's backing DB table doesn't exist on the live
// server (never migrated). kltheguide.com.my's own Travel Tips page has
// since been reorganized into a different set of categories with no
// per-category images, so there's no per-topic source to pull from anymore
// — these 4 categories (matching this page's existing, already-translated
// weather/timezone/currency/visa content) link out to its current
// travel-tips.php page instead of a topic-specific one, and use an icon
// banner instead of a photo (see MyList2) rather than reusing one shared
// image across all 4 cards.
const String _travelTipsLink = 'https://new.kltheguide.com.my/travel-tips.php';
const Map<String, dynamic> _travelTips = {
  'weather': {'link': _travelTipsLink},
  'timezone': {'link': _travelTipsLink},
  'currency': {'link': _travelTipsLink},
  'visa': {'link': _travelTipsLink},
};

class TravelTips extends StatelessWidget {
  const TravelTips({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _subPageAppBar(
        context: context,
        title: S.of(context).travelTips,
        palette: palette,
      ),
      body: MyList2(tips: _travelTips, palette: palette),
    );
  }
}

class MyList2 extends StatelessWidget {
  final Map<String, dynamic> tips;
  final HomePalette palette;

  const MyList2({super.key, required this.tips, required this.palette});

  @override
  Widget build(BuildContext context) {
    final List<ItemData2> items = [
      ItemData2(
        nestedField(tips, 'weather', 'link'),
        Icons.wb_sunny_rounded,
        Colors.orange,
      ),
      ItemData2(
        nestedField(tips, 'timezone', 'link'),
        Icons.access_time_rounded,
        Colors.blue,
      ),
      ItemData2(
        nestedField(tips, 'currency', 'link'),
        Icons.payments_rounded,
        Colors.green,
      ),
      ItemData2(
        nestedField(tips, 'visa', 'link'),
        Icons.card_travel_rounded,
        Colors.purple,
      ),
    ];

    return Container(
      color: palette.background,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => UrlService.launchURL(items[index].goto),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: items[index].color.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Card(
                      color: palette.card,
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon banner — these 4 categories don't have real
                          // per-topic photos to show (see the comment above
                          // _travelTips), so a big colored icon stands in for
                          // a photo instead of a misleadingly-shared one.
                          Container(
                            height: 120,
                            width: double.infinity,
                            color: items[index].color.withValues(alpha: 0.12),
                            child: Center(
                              child: Icon(
                                items[index].icon,
                                color: items[index].color,
                                size: 56,
                              ),
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getLocalizedTitle(index, context),
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: palette.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12.0),
                                Text(
                                  _getLocalizedContent(index, context),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    height: 1.5,
                                    color: palette.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.open_in_new_rounded,
                                      color: items[index].color,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Learn More',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: items[index].color,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getLocalizedTitle(int index, BuildContext context) {
    switch (index) {
      case 0:
        return S.of(context).weatherTitle;
      case 1:
        return S.of(context).timeZoneTitle;
      case 2:
        return S.of(context).currencyTitle;
      case 3:
        return S.of(context).visaAndPassportTitle;
      default:
        return '';
    }
  }

  String _getLocalizedContent(int index, BuildContext context) {
    switch (index) {
      case 0:
        return S.of(context).weatherDescription;
      case 1:
        return S.of(context).timeZoneDescription;
      case 2:
        return S.of(context).currencyDescription;
      case 3:
        return S.of(context).visaAndPassportDescription;
      default:
        return '';
    }
  }
}

class ItemData2 {
  final String goto;
  final IconData icon;
  final Color color;

  ItemData2(this.goto, this.icon, this.color);
}
