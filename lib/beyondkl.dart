import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/models/content_item.dart';
import 'package:kltheguide/services/api_service.dart';
import 'package:kltheguide/widgets/api_future_view.dart';
import 'package:kltheguide/services/url_service.dart';

import 'generated/l10n.dart';

class CardListWidget extends StatelessWidget {
  final List<ContentItem> data;
  final HomePalette palette;

  const CardListWidget({super.key, required this.data, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.background,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: palette.card,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (item.mapsUrl.isNotEmpty) {
                    UrlService.launchURL(item.mapsUrl);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image with overlay gradient
                      Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            height: 220,
                            width: double.infinity,
                            memCacheHeight: 660,
                            placeholder: (context, url) => Container(
                              height: 220,
                              color: palette.card,
                              child: Center(
                                child: CircularProgressIndicator(color: palette.accent),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 220,
                              color: palette.card,
                              child: const Icon(Icons.error, size: 50),
                            ),
                          ),
                          if (item.mapsUrl.isNotEmpty)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: palette.accent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'View Map',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Content Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title with icon
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: palette.accent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.place,
                                    color: palette.accent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: palette.textPrimary,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Content/Description
                            if (item.description.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: palette.accent.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: palette.textSecondary,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item.description.replaceAll('\\n', '\n'),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: palette.textSecondary,
                                          height: 1.5,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Location Button (if location exists)
                            if (item.mapsUrl.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: Material(
                                  color: palette.accent,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () => UrlService.launchURL(item.mapsUrl),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.map_outlined,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'View on Map',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

class BeyondKL extends StatelessWidget {
  final List<Map<String, dynamic>> dataList = [
    {
      "name": S.current.islands,
      "image":
          "https://www.kltheguide.com.my/assets/img/beyondkl/ISLAND-01.jpg",
      "icon": Icons.beach_access,
    },
    {
      "name": S.current.hillStation,
      "image":
          "https://www.kltheguide.com.my/assets/img/beyondkl/HILL-STATION-01.jpg",
      "icon": Icons.landscape,
    },
    {
      "name": S.current.waterfall,
      "image":
          "https://www.kltheguide.com.my/assets/img/beyondkl/WATERFALL-01.jpg",
      "icon": Icons.water,
    },
    {
      "name": S.current.hiking,
      "image": "https://www.kltheguide.com.my/assets/img/beyondkl/HIKING.jpg",
      "icon": Icons.hiking,
    },
    {
      "name": S.current.extremeSports,
      "image":
          "https://www.kltheguide.com.my/assets/img/beyondkl/EXTREME-SPORT-2.webp",
      "icon": Icons.sports_motorsports,
    },
  ];

  BeyondKL({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.accent),
        title: Text(
          S.of(context).beyondKL,
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
      ),
      body: Container(
        color: palette.background,
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            final item = dataList[index];
            return _BeyondKLGridTile(
              name: item["name"],
              image: item["image"],
              icon: item["icon"],
              index: index,
              palette: palette,
            );
          },
        ),
      ),
    );
  }
}

class _BeyondKLGridTile extends StatelessWidget {
  final String name;
  final String image;
  final IconData icon;
  final int index;
  final HomePalette palette;

  const _BeyondKLGridTile({
    required this.name,
    required this.image,
    required this.icon,
    required this.index,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/beyondkl-$index',
              arguments: {'index': index});
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              memCacheWidth: 400,
              placeholder: (context, url) => Container(
                color: palette.card,
                child: Center(
                  child: CircularProgressIndicator(color: palette.accent),
                ),
              ),
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
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: palette.accent, size: 18),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  shadows: [
                    Shadow(offset: Offset(0, 1), blurRadius: 3.0, color: Colors.black45),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeyondKLPage extends StatelessWidget {
  final String action;
  final String title;
  const _BeyondKLPage({required this.action, required this.title});

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
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
      ),
      body: ApiFutureView<List<Map<String, dynamic>>>(
        load: () => fetchList(action),
        isEmpty: (data) => data.isEmpty,
        builder: (context, data) {
          final items = data
              .map((e) => ContentItem(
                    title: field(e, 'title'),
                    description: field(e, 'content'),
                    imageUrl: field(e, 'image'),
                    mapsUrl: field(e, 'locationurl').isNotEmpty
                        ? field(e, 'locationurl')
                        : field(e, 'location'),
                  ))
              .toList();
          return CardListWidget(data: items, palette: palette);
        },
      ),
    );
  }
}

class BeyondKL_I extends StatelessWidget {
  const BeyondKL_I({super.key});

  @override
  Widget build(BuildContext context) => _BeyondKLPage(
        action: 'appBeyondKL_i',
        title: S.of(context).islands,
      );
}

class BeyondKL_HS extends StatelessWidget {
  const BeyondKL_HS({super.key});

  @override
  Widget build(BuildContext context) => _BeyondKLPage(
        action: 'appBeyondKL_hs',
        title: S.of(context).hillStation,
      );
}

class BeyondKL_W extends StatelessWidget {
  const BeyondKL_W({super.key});

  @override
  Widget build(BuildContext context) => _BeyondKLPage(
        action: 'appBeyondKL_w',
        title: S.of(context).waterfall,
      );
}

class BeyondKL_H extends StatelessWidget {
  const BeyondKL_H({super.key});

  @override
  Widget build(BuildContext context) => _BeyondKLPage(
        action: 'appBeyondKL_h',
        title: S.of(context).hiking,
      );
}

class BeyondKL_ES extends StatelessWidget {
  const BeyondKL_ES({super.key});

  @override
  Widget build(BuildContext context) => _BeyondKLPage(
        action: 'appBeyondKL_es',
        title: S.of(context).extremeSports,
      );
}
