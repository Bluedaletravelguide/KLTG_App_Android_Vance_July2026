import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kltheguide/home_page_v2.dart';

class ListingImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final Color? progressColor;

  const ListingImage({
    super.key,
    required this.imageUrl,
    this.height = 220,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    final color = progressColor ?? palette.accent;
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
      memCacheHeight: (height * 3).round(),
      placeholder: (context, url) => Container(
        height: height,
        color: palette.card,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        color: palette.card,
        child: Icon(Icons.error, size: 50, color: palette.textSecondary),
      ),
    );
  }
}
