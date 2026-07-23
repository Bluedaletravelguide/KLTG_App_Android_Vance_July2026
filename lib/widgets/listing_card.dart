import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kltheguide/generated/l10n.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/models/listing_item.dart';
import 'package:kltheguide/models/trip_day.dart';
import 'package:kltheguide/models/trip_item.dart';
import 'package:kltheguide/services/trip_planner_service.dart';
import 'package:kltheguide/services/url_service.dart';
import 'package:kltheguide/widgets/info_row.dart';
import 'package:kltheguide/widgets/listing_image.dart';

/// A single capability-complete listing card: image, title, optional
/// description/address/hours, and one action button per non-empty contact
/// method (maps/phone/website) — a listing with no website, say, simply
/// has no website button instead of one that does nothing when tapped.
class ListingCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String? description;
  final String? address;
  final String? hours;
  final String? phone;
  final String? website;
  final String? mapsUrl;
  final VoidCallback? onTap;
  // When set, shows an "Add to Trip" action and enables the whole
  // add-to-itinerary flow below. Null (the default) hides the button
  // entirely, so call sites opt in per-page.
  final String? category;

  const ListingCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.description,
    this.address,
    this.hours,
    this.phone,
    this.website,
    this.mapsUrl,
    this.onTap,
    this.category,
  });

  factory ListingCard.fromItem(
    ListingItem item, {
    Key? key,
    VoidCallback? onTap,
    String? category,
  }) {
    return ListingCard(
      key: key,
      title: item.title,
      imageUrl: item.imageUrl,
      description: item.description,
      address: item.address,
      hours: item.hours,
      phone: item.contact,
      website: item.website,
      mapsUrl: item.mapsUrl,
      onTap: onTap,
      category: category,
    );
  }

  Future<void> _addToTrip(BuildContext context) async {
    final tripItem = TripItem(
      title: title,
      imageUrl: imageUrl,
      description: description ?? '',
      address: address ?? '',
      mapsUrl: mapsUrl ?? '',
      hours: hours ?? '',
      contact: phone ?? '',
      website: website ?? '',
      category: category!,
    );

    await TripPlannerService.ensureLoaded();
    final existing = TripPlannerService.days.value;

    int dayIndex;
    if (existing.isEmpty) {
      await TripPlannerService.addDay();
      dayIndex = 0;
    } else {
      if (!context.mounted) return;
      final choice = await showModalBottomSheet<_TripDayChoice>(
        context: context,
        backgroundColor: HomePalette.of(context).card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _AddToTripSheet(days: existing),
      );
      if (choice == null) return;
      if (choice.isNewDay) {
        await TripPlannerService.addDay();
        dayIndex = TripPlannerService.days.value.length - 1;
      } else {
        dayIndex = choice.dayIndex!;
      }
    }

    final added = await TripPlannerService.addItem(dayIndex, tripItem);
    final label = TripPlannerService.days.value[dayIndex].label;
    if (!context.mounted) return;
    final palette = HomePalette.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(added ? 'Added to $label' : 'Already in $label'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.accent,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _share() {
    final parts = <String>[title];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (mapsUrl != null && mapsUrl!.isNotEmpty) parts.add(mapsUrl!);
    SharePlus.instance.share(ShareParams(text: parts.join('\n')));
  }

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    final hasMaps = mapsUrl != null && mapsUrl!.isNotEmpty;
    final hasPhone = phone != null && phone!.isNotEmpty;
    final hasWebsite = website != null && website!.isNotEmpty;

    final actions = <Widget>[
      if (hasMaps)
        _ActionButton(
          icon: Icons.map_outlined,
          label: S.of(context).maps,
          filled: true,
          palette: palette,
          onTap: () => UrlService.launchURL(mapsUrl!),
        ),
      if (hasPhone)
        _ActionButton(
          icon: Icons.phone_outlined,
          label: S.of(context).phone,
          filled: !hasMaps,
          palette: palette,
          onTap: () => UrlService.launchURL('tel:$phone'),
        ),
      if (hasWebsite)
        _ActionButton(
          icon: Icons.language_outlined,
          label: S.of(context).website,
          filled: !hasMaps && !hasPhone,
          palette: palette,
          onTap: () => UrlService.launchURL(website!),
        ),
      if (category != null)
        _ActionButton(
          icon: Icons.card_travel,
          label: 'Add to Trip',
          filled: !hasMaps && !hasPhone && !hasWebsite,
          palette: palette,
          onTap: () => _addToTrip(context),
        ),
    ];

    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ListingImage(imageUrl: imageUrl, height: 200),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Tooltip(
                    message: 'Share this place',
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _share,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.share_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: palette.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (description != null && description!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: palette.accent.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 20, color: palette.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: palette.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (address != null && address!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    InfoRow(
                      icon: Icons.location_on_outlined,
                      iconColor: palette.accent,
                      iconBackground: false,
                      label: S.of(context).location,
                      value: address!,
                    ),
                  ],
                  if (hours != null && hours!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    InfoRow(
                      icon: Icons.access_time_outlined,
                      iconColor: palette.accent,
                      iconBackground: false,
                      label: S.of(context).operatingHours,
                      value: hours!,
                    ),
                  ],
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        for (int i = 0; i < actions.length; i++) ...[
                          if (i != 0) const SizedBox(width: 10),
                          Expanded(child: actions[i]),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final HomePalette palette;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? palette.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: filled
              ? null
              : BoxDecoration(
                  border: Border.all(color: palette.accent, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: filled ? Colors.white : palette.accent),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.white : palette.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripDayChoice {
  final bool isNewDay;
  final int? dayIndex;

  const _TripDayChoice.day(this.dayIndex) : isNewDay = false;
  const _TripDayChoice.newDay()
      : isNewDay = true,
        dayIndex = null;
}

class _AddToTripSheet extends StatelessWidget {
  final List<TripDay> days;

  const _AddToTripSheet({required this.days});

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            'Add to which day?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < days.length; i++)
            ListTile(
              leading: Icon(Icons.calendar_today_outlined, color: palette.accent),
              title: Text(days[i].label, style: TextStyle(color: palette.textPrimary)),
              subtitle: Text(
                '${days[i].items.length} place${days[i].items.length == 1 ? '' : 's'}',
                style: TextStyle(color: palette.textSecondary),
              ),
              onTap: () => Navigator.of(context).pop(_TripDayChoice.day(i)),
            ),
          ListTile(
            leading: Icon(Icons.add, color: palette.accent),
            title: Text('New Day', style: TextStyle(color: palette.textPrimary)),
            onTap: () => Navigator.of(context).pop(const _TripDayChoice.newDay()),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
