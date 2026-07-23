// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import 'package:kltheguide/services/url_service.dart';
import 'package:kltheguide/services/api_service.dart';
import 'package:kltheguide/widgets/api_future_view.dart';
import '../generated/l10n.dart';

import 'package:kltheguide/models/content_item.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          if (item.address != '') {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailPage(
                              title: item.title,
                              image: item.imageUrl,
                              content: item.description,
                              content2: item.description2,
                              location: item.address,
                              locationurl: item.mapsUrl,
                              hours: item.hours.replaceAll('/', '\n'),
                              phone: item.contact.replaceAll('/', '\n'),
                              website: item.website,
                            )));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  color: palette.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                          memCacheHeight: 400,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: palette.card,
                            child: Center(
                              child: CircularProgressIndicator(color: palette.accent),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: palette.card,
                            child: const Icon(Icons.error, size: 50),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: palette.textPrimary,
                              ),
                            ),
                            if (item.description != '')
                              const SizedBox(height: 12.0),
                            if (item.description != '')
                              Text(
                                item.description.replaceAll('\\n', '\n'),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: palette.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                color: palette.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                        memCacheHeight: 400,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: palette.card,
                          child: Center(
                            child: CircularProgressIndicator(color: palette.accent),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: palette.card,
                          child: const Icon(Icons.error, size: 50),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            item.description.replaceAll('\\n', '\n'),
                            style: TextStyle(
                              fontSize: 15,
                              color: palette.textSecondary,
                              height: 1.4,
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
        },
      ),
    );
  }
}


class DetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String content2;
  final String image;
  final String location;
  final String locationurl;
  final String hours;
  final String phone;
  final String website;

  const DetailPage({
    super.key,
    required this.location,
    required this.locationurl,
    required this.hours,
    required this.phone,
    required this.title,
    required this.content,
    required this.content2,
    required this.image,
    required this.website,
  });

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
          S.of(context).details,
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
        actions: [AppBarMore(iconColor: palette.accent)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
              placeholder: (context, url) => Container(
                height: 250,
                color: palette.card,
                child: Center(child: CircularProgressIndicator(color: palette.accent)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 250,
                color: palette.card,
                child: const Icon(Icons.error, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: palette.textPrimary,
                    ),
                  ),
                  if (content != '') const SizedBox(height: 16.0),
                  if (content != '')
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: palette.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  if (content2 != '') const SizedBox(height: 12.0),
                  if (content2 != '')
                    Text(
                      content2,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: palette.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  if (location != '' ||
                      phone != '' ||
                      hours != '' ||
                      website != '')
                    const SizedBox(height: 20.0),
                  if (location != '')
                    _buildInfoCard(
                      icon: Icons.location_on,
                      label: S.of(context).location,
                      value: location,
                      onTap: () => UrlService.launchURL(locationurl),
                      isClickable: true,
                      palette: palette,
                    ),
                  if (phone != '')
                    _buildInfoCard(
                      icon: Icons.phone,
                      label: S.of(context).contact,
                      value: phone,
                      onTap: () => UrlService.launchURL('tel:$phone'),
                      isClickable: true,
                      palette: palette,
                    ),
                  if (hours != '')
                    _buildInfoCard(
                      icon: Icons.access_time,
                      label: 'Hours',
                      value: hours,
                      onTap: null,
                      isClickable: false,
                      palette: palette,
                    ),
                  if (website != '')
                    _buildInfoCard(
                      icon: Icons.language,
                      label: 'Website',
                      value: website,
                      onTap: () => UrlService.launchURL(website),
                      isClickable: true,
                      palette: palette,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback? onTap,
    required bool isClickable,
    required HomePalette palette,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: palette.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        color: isClickable ? palette.accent : palette.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (isClickable)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: palette.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreKL_WTD extends StatefulWidget {
  const ExploreKL_WTD({super.key});
  @override
  State<ExploreKL_WTD> createState() => _ExploreKL_WTDState();
}
class _ExploreKL_WTDState extends State<ExploreKL_WTD> {
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
          S.of(context).whatToDo,
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
        actions: [AppBarMore(iconColor: palette.accent)],
      ),
      body: ApiFutureView<List<Map<String, dynamic>>>(
        load: () => fetchList('appExploreKL_WTD'),
        isEmpty: (data) => data.isEmpty,
        builder: (context, data) {
          final items = data.map((e) => ContentItem(title:field(e,'title'),description:field(e,'content'),description2:'',imageUrl:field(e,'image'),address:field(e,'location'),mapsUrl:field(e,'locationurl'),hours:field(e,'hours'),contact:field(e,'phone'),website:field(e,'website'))).toList();
          return CardListWidget(data: items, palette: palette);
        },
      ),
    );
  }
}
