import 'package:flutter/material.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import 'package:kltheguide/models/listing_item.dart';
import 'package:kltheguide/services/api_service.dart';
import 'package:kltheguide/widgets/api_future_view.dart';
import 'package:kltheguide/widgets/listing_card.dart';
import 'generated/l10n.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  _ShopState createState() => _ShopState();
}

class _ShopState extends State<Shop> {
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
          S.of(context).placesToShop,
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
        load: () => fetchList('appShop'),
        isEmpty: (data) => data.isEmpty,
        builder: (context, data) {
          final items = data
              .map((e) => ListingItem(
                    title: field(e, 'title'),
                    imageUrl: field(e, 'image'),
                    address: field(e, 'location'),
                    hours: field(e, 'hours'),
                    website: field(e, 'website'),
                  ))
              .toList();
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: items.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ListingCard.fromItem(items[index], category: 'Shop'),
            ),
          );
        },
      ),
    );
  }
}

