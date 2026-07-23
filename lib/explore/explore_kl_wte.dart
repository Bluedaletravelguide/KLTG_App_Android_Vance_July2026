// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import 'package:kltheguide/services/url_service.dart';
import 'package:kltheguide/services/api_service.dart';
import 'package:kltheguide/widgets/api_future_view.dart';
import '../generated/l10n.dart';

class _WTE_Tab extends StatelessWidget {
  final String action;
  final HomePalette palette;
  const _WTE_Tab({required this.action, required this.palette});
  @override
  Widget build(BuildContext context) {
    return ApiFutureView<List<Map<String, dynamic>>>(
      load: () => fetchList(action),
      isEmpty: (data) => data.isEmpty,
      builder: (context, data) {
        final items = data.map((e) => ItemData5(field(e, 'title'), field(e, 'image'), field(e, 'location'), field(e, 'hours'), field(e, 'phone'))).toList();
        return MyList5(items: items, palette: palette);
      },
    );
  }
}


class ExploreKL_WTE2 extends StatefulWidget {
  const ExploreKL_WTE2({super.key});

  @override
  _ExploreKL_WTE2State createState() => _ExploreKL_WTE2State();
}

class _ExploreKL_WTE2State extends State<ExploreKL_WTE2> {
  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          backgroundColor: palette.background,
          elevation: 0,
          iconTheme: IconThemeData(color: palette.accent),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: palette.card,
              child: TabBar(
                indicatorColor: palette.accent,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: S.of(context).streetFood),
                  Tab(text: S.of(context).cafes),
                  Tab(text: S.of(context).restaurants),
                ],
                labelColor: palette.textPrimary,
                unselectedLabelColor: palette.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          title: Text(
            S.of(context).whatToEat,
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
          child: TabBarView(
            children: [
              _WTE_Tab(action: 'appExploreKL_WTE_SF', palette: palette),
              _WTE_Tab(action: 'appExploreKL_WTE_C', palette: palette),
              _WTE_Tab(action: 'appExploreKL_WTE_R', palette: palette),
            ],
          ),
        ),
      ),
    );
  }
}

class MyList5 extends StatelessWidget {
  final List<ItemData5> items;
  final HomePalette palette;

  const MyList5({super.key, required this.items, required this.palette});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
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
                      if (items[index].hours.isNotEmpty) ...[
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
                      ],
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
    );
  }
}

class ItemData5 {
  final String text;
  final String imageUrl;
  final String location;
  final String hours;
  final String contact;

  ItemData5(this.text, this.imageUrl, this.location, this.hours, this.contact);
}
