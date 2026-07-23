import 'package:flutter/material.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/widgets/app_bar_more.dart';
import 'package:kltheguide/models/listing_item.dart';
import 'package:kltheguide/services/api_service.dart';
import 'package:kltheguide/widgets/api_future_view.dart';
import 'package:kltheguide/widgets/listing_card.dart';
import 'generated/l10n.dart';

class MedicalT extends StatefulWidget {
  const MedicalT({super.key});

  @override
  _MedicalTState createState() => _MedicalTState();
}

class _MedicalTState extends State<MedicalT> {
  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return DefaultTabController(
      length: 5,
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
                isScrollable: true,
                indicatorColor: palette.accent,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.local_hospital, size: 18),
                        const SizedBox(width: 6),
                        Text(S.of(context).healthcare),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.medical_services, size: 18),
                        const SizedBox(width: 6),
                        Text(S.of(context).dental),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.face, size: 18),
                        const SizedBox(width: 6),
                        Text(S.of(context).dermatologist),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.visibility, size: 18),
                        const SizedBox(width: 6),
                        Text(S.of(context).ophthalmologist),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.healing, size: 18),
                        const SizedBox(width: 6),
                        Text(S.of(context).plasticSurgery),
                      ],
                    ),
                  ),
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
            S.of(context).medicalTourism,
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
              _MedicalTab(action: 'appMedicalT_hc', palette: palette),
              _MedicalTab(action: 'appMedicalT_dtl', palette: palette),
              _MedicalTab(action: 'appMedicalT_der', palette: palette),
              _MedicalTab(action: 'appMedicalT_oph', palette: palette),
              _MedicalTab(action: 'appMedicalT_ps', palette: palette),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicalTab extends StatelessWidget {
  final String action;
  final HomePalette palette;
  const _MedicalTab({required this.action, required this.palette});

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
                  address: field(e, 'location'),
                  hours: field(e, 'hours'),
                  mapsUrl: field(e, 'locationurl'),
                ))
            .toList();
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: items.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListingCard.fromItem(items[index], category: 'Medical Tourism'),
          ),
        );
      },
    );
  }
}
