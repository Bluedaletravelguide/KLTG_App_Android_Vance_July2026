import 'package:flutter/material.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import 'package:kltheguide/models/listing_item.dart';
import 'package:kltheguide/services/api_service.dart';
import 'package:kltheguide/widgets/api_future_view.dart';
import 'package:kltheguide/widgets/listing_card.dart';
import 'generated/l10n.dart';

class Stay extends StatefulWidget {
  const Stay({super.key});

  @override
  _StayState createState() => _StayState();
}

class _StayState extends State<Stay> {
  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          backgroundColor: palette.background,
          elevation: 0,
          iconTheme: IconThemeData(color: palette.accent),
          title: Text(
            S.of(context).placesToStay,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: palette.textPrimary,
            ),
          ),
          actions: [AppBarMore(iconColor: palette.accent)],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: palette.card,
              child: TabBar(
                isScrollable: true,
                indicatorColor: palette.accent,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: palette.textPrimary,
                unselectedLabelColor: palette.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: S.of(context).topPlacesToStay),
                  Tab(text: S.of(context).hotels),
                  Tab(text: S.of(context).budgetHotels),
                  Tab(text: S.of(context).backpackersLodge),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          color: palette.background,
          child: TabBarView(
            children: [
              _StayTab(action: 'appStay_top', palette: palette),
              _StayTab(action: 'appStay_h', palette: palette),
              _StayTab(action: 'appStay_bh', palette: palette),
              _StayTab(action: 'appStay_bks', palette: palette),
            ],
          ),
        ),
      ),
    );
  }
}

class _StayTab extends StatelessWidget {
  final String action;
  final HomePalette palette;
  const _StayTab({required this.action, required this.palette});

  @override
  Widget build(BuildContext context) {
    return ApiFutureView<List<Map<String, dynamic>>>(
      load: () => fetchList(action),
      isEmpty: (data) => data.isEmpty,
      builder: (context, data) {
        final items = data
            .map((e) => ListingItem(
                  title: field(e, 'title'),
                  imageUrl: field(e, 'image'),
                  description: field(e, 'content'),
                  address: field(e, 'location'),
                  mapsUrl: field(e, 'locationurl'),
                  contact: field(e, 'phone'),
                  website: field(e, 'website'),
                ))
            .toList();
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListingCard.fromItem(items[index], category: 'Stay'),
          ),
        );
      },
    );
  }
}

