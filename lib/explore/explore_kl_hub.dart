// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import '../generated/l10n.dart';

class ExploreKL extends StatelessWidget {
  const ExploreKL({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    final List<Map<String, dynamic>> dataList = [
      {
        "name": S.of(context).whatToDo,
        "image": "https://www.kltheguide.com.my/assets/img/explorekl/wtd.webp"
      },
      {
        "name": S.of(context).historicalSites,
        "image": "https://www.kltheguide.com.my/assets/img/explorekl/hs.webp"
      },
      {
        "name": S.of(context).placesOfWorship,
        "image": "https://www.kltheguide.com.my/assets/img/explorekl/pwor.webp"
      },
      {
        "name": S.of(context).whatToEat,
        "image": "https://www.kltheguide.com.my/assets/img/explorekl/wte.webp"
      },
      {
        "name": S.of(context).nightLife,
        "image": "https://www.kltheguide.com.my/assets/img/explorekl/nl.webp"
      },
      {
        "name": S.of(context).kl4Kids,
        "image":
            "https://www.kltheguide.com.my/assets/img/explorekl/kl4kids.webp"
      },
      {
        "name": S.of(context).sightseeing,
        "image": "https://www.kltheguide.com.my/assets/img/explorekl/ss.webp"
      },
      {
        "name": S.of(context).parks,
        "image": "https://www.kltheguide.com.my/assets/img/explorekl/parks.jpg"
      },
    ];

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.accent),
        title: Text(
          S.of(context).exploreKL,
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
        actions: [AppBarMore(iconColor: palette.accent)],
      ),
      body: Container(
        color: palette.background,
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            final item = dataList[index];
            return _ExploreKLGridTile(
                name: item["name"], image: item["image"], index: index, palette: palette);
          },
        ),
      ),
    );
  }
}

class _ExploreKLGridTile extends StatelessWidget {
  final String name;
  final String image;
  final int index;
  final HomePalette palette;

  const _ExploreKLGridTile({
    required this.name,
    required this.image,
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
          Navigator.pushNamed(context, '/explorekl-$index',
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
