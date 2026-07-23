// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import 'package:kltheguide/services/url_service.dart';
import 'package:kltheguide/services/api_service.dart';
import 'package:kltheguide/widgets/api_future_view.dart';
import '../generated/l10n.dart';


class ExploreKL_P2 extends StatefulWidget {
  const ExploreKL_P2({super.key});
  @override
  _ExploreKL_P2State createState() => _ExploreKL_P2State();
}
class _ExploreKL_P2State extends State<ExploreKL_P2> {
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
          S.of(context).parks,
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
        load: () => fetchList('appExploreKL_P'),
        isEmpty: (data) => data.isEmpty,
        builder: (context, data) {
          final items = data.map((e) => ItemData7(field(e,'title'),field(e,'image'),field(e,'location'),field(e,'hours'),field(e,'phone'))).toList();
          return MyList7(items: items, palette: palette);
        },
      ),
    );
  }
}
class ItemData7 {
  final String text;
  final String imageUrl;
  final String location;
  final String hours;
  final String contact;

  ItemData7(this.text, this.imageUrl, this.location, this.hours, this.contact);
}

class MyList7 extends StatelessWidget {
  final List<ItemData7> items;
  final HomePalette palette;

  const MyList7({super.key, required this.items, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.background,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              color: palette.card,
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: items[index].imageUrl,
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                      memCacheHeight: 600,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: palette.card,
                        child: Center(child: CircularProgressIndicator(color: palette.accent)),
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
                          items[index].text,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                              color: palette.accent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${S.of(context).location}: ${items[index].location}',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: palette.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: palette.accent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${S.of(context).operatingHours}: ${items[index].hours}',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: palette.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (items[index].contact.isNotEmpty) ...[
                          const SizedBox(height: 10.0),
                          InkWell(
                            onTap: () =>
                                UrlService.launchURL('tel:${items[index].contact}'),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 18,
                                  color: palette.accent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${S.of(context).contact}: ${items[index].contact}',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: palette.accent,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
