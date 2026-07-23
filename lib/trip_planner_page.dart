import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/models/trip_day.dart';
import 'package:kltheguide/models/trip_item.dart';
import 'package:kltheguide/services/trip_planner_service.dart';
import 'package:kltheguide/services/url_service.dart';
import 'package:kltheguide/widgets/state_views.dart';

// Google's documented Maps URL API (not a guessed/fabricated link) — accepts
// plain place names or addresses for origin/destination, no geocoding needed.
String directionsUrl(TripItem from, TripItem to) {
  final origin = from.address.isNotEmpty ? from.address : from.title;
  final destination = to.address.isNotEmpty ? to.address : to.title;
  final params = {
    'api': '1',
    'origin': origin,
    'destination': destination,
  };
  return Uri.https('www.google.com', '/maps/dir/', params).toString();
}

String formatScheduledTime(int minutes) {
  final hour24 = minutes ~/ 60;
  final minute = minutes % 60;
  final period = hour24 < 12 ? 'AM' : 'PM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return '$hour12:${minute.toString().padLeft(2, '0')} $period';
}

String _buildShareText(List<TripDay> days) {
  final buffer = StringBuffer('My Trip — KL The Guide\n');
  for (final day in days) {
    buffer.writeln();
    buffer.writeln(day.label);
    if (day.items.isEmpty) {
      buffer.writeln('(no places added yet)');
      continue;
    }
    for (final item in day.itemsInScheduleOrder) {
      final time = item.scheduledMinutes != null
          ? '${formatScheduledTime(item.scheduledMinutes!)} — '
          : '';
      buffer.writeln('$time${item.title} (${item.category})');
    }
  }
  return buffer.toString().trim();
}

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({super.key});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  @override
  void initState() {
    super.initState();
    TripPlannerService.ensureLoaded();
  }

  Future<void> _confirmRemoveDay(int dayIndex, TripDay day, HomePalette palette) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.card,
        title: Text('Remove ${day.label}?', style: TextStyle(color: palette.textPrimary)),
        content: Text(
          day.items.isEmpty
              ? 'This day has no places added.'
              : 'This will remove ${day.items.length} place${day.items.length == 1 ? '' : 's'} from your trip.',
          style: TextStyle(color: palette.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Remove', style: TextStyle(color: palette.accent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await TripPlannerService.removeDay(dayIndex);
    }
  }

  Future<void> _pickTime(BuildContext context, int dayIndex, TripItem item) async {
    final initial = item.scheduledMinutes != null
        ? TimeOfDay(hour: item.scheduledMinutes! ~/ 60, minute: item.scheduledMinutes! % 60)
        : TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    await TripPlannerService.setItemTime(dayIndex, item, picked.hour * 60 + picked.minute);
  }

  Future<void> _pickCost(BuildContext context, int dayIndex, TripItem item) async {
    final palette = HomePalette.of(context);
    final controller = TextEditingController(
      text: item.estimatedCost != null ? item.estimatedCost!.toStringAsFixed(2) : '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.card,
        title: Text('Estimated cost', style: TextStyle(color: palette.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: palette.textPrimary),
          decoration: const InputDecoration(prefixText: 'RM '),
        ),
        actions: [
          if (item.estimatedCost != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop('clear'),
              child: Text('Clear', style: TextStyle(color: palette.textSecondary)),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text('Save', style: TextStyle(color: palette.accent)),
          ),
        ],
      ),
    );
    if (result == null) return;
    if (result == 'clear') {
      await TripPlannerService.setItemCost(dayIndex, item, null);
      return;
    }
    await TripPlannerService.setItemCost(dayIndex, item, double.tryParse(result));
  }

  void _shareTrip(List<TripDay> days) {
    final text = _buildShareText(days);
    SharePlus.instance.share(ShareParams(text: text, subject: 'My Trip Itinerary'));
  }

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
          'My Trip',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
        actions: [
          ValueListenableBuilder<List<TripDay>>(
            valueListenable: TripPlannerService.days,
            builder: (context, days, _) => IconButton(
              tooltip: 'Share Trip',
              icon: Icon(Icons.ios_share, color: palette.accent),
              onPressed: days.any((d) => d.items.isNotEmpty) ? () => _shareTrip(days) : null,
            ),
          ),
          IconButton(
            tooltip: 'Add Day',
            icon: Icon(Icons.add, color: palette.accent),
            onPressed: () => TripPlannerService.addDay(),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<TripDay>>(
        valueListenable: TripPlannerService.days,
        builder: (context, days, _) {
          if (days.isEmpty) {
            return EmptyStateView(
              icon: Icons.card_travel,
              message: 'No trip planned yet — tap Add to Trip on any listing.',
            );
          }
          final tripTotal = days.fold(0.0, (sum, d) => sum + d.totalCost);
          return Column(
            children: [
              if (tripTotal > 0)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: palette.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payments_outlined, size: 18, color: palette.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Estimated trip total',
                        style: TextStyle(fontSize: 13.5, color: palette.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        'RM ${tripTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: palette.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, dayIndex) {
              final day = days[dayIndex];
              final scheduled =
                  day.items.where((i) => i.scheduledMinutes != null).toList()
                    ..sort((a, b) => a.scheduledMinutes!.compareTo(b.scheduledMinutes!));
              final unscheduled = day.items.where((i) => i.scheduledMinutes == null).toList();
              return Material(
                color: palette.card,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  day.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: palette.textPrimary,
                                  ),
                                ),
                                if (day.totalCost > 0) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '· RM ${day.totalCost.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: palette.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove Day',
                            icon: Icon(Icons.delete_outline, color: palette.textSecondary),
                            onPressed: () => _confirmRemoveDay(dayIndex, day, palette),
                          ),
                        ],
                      ),
                    ),
                    if (day.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          'No places added to this day yet.',
                          style: TextStyle(color: palette.textSecondary),
                        ),
                      )
                    else ...[
                      for (var i = 0; i < scheduled.length; i++) ...[
                        _TripItemRow(
                          item: scheduled[i],
                          palette: palette,
                          onRemove: () => TripPlannerService.removeItem(dayIndex, scheduled[i]),
                          onSetTime: () => _pickTime(context, dayIndex, scheduled[i]),
                          onClearTime: () =>
                              TripPlannerService.setItemTime(dayIndex, scheduled[i], null),
                          onSetCost: () => _pickCost(context, dayIndex, scheduled[i]),
                        ),
                        if (i != scheduled.length - 1)
                          _DirectionsConnector(
                            palette: palette,
                            onTap: () => UrlService.launchURL(
                                directionsUrl(scheduled[i], scheduled[i + 1])),
                          ),
                      ],
                      if (scheduled.isNotEmpty && unscheduled.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: Text(
                            'UNSCHEDULED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: palette.textSecondary,
                            ),
                          ),
                        ),
                      for (final item in unscheduled)
                        _TripItemRow(
                          item: item,
                          palette: palette,
                          onRemove: () => TripPlannerService.removeItem(dayIndex, item),
                          onSetTime: () => _pickTime(context, dayIndex, item),
                          onClearTime: () => TripPlannerService.setItemTime(dayIndex, item, null),
                          onSetCost: () => _pickCost(context, dayIndex, item),
                        ),
                    ],
                    const SizedBox(height: 4),
                  ],
                ),
              );
            },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DirectionsConnector extends StatelessWidget {
  final HomePalette palette;
  final VoidCallback onTap;

  const _DirectionsConnector({required this.palette, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 72, bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.turn_right_rounded, size: 16, color: palette.accent),
                const SizedBox(width: 6),
                Text(
                  'Directions',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: palette.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TripItemRow extends StatelessWidget {
  final TripItem item;
  final HomePalette palette;
  final VoidCallback onRemove;
  final VoidCallback onSetTime;
  final VoidCallback onClearTime;
  final VoidCallback onSetCost;

  const _TripItemRow({
    required this.item,
    required this.palette,
    required this.onRemove,
    required this.onSetTime,
    required this.onClearTime,
    required this.onSetCost,
  });

  @override
  Widget build(BuildContext context) {
    final hasTime = item.scheduledMinutes != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Tooltip(
            message: hasTime ? 'Tap to change time · hold to clear' : 'Tap to set a time',
            child: Semantics(
              button: true,
              label: hasTime
                  ? 'Scheduled for ${formatScheduledTime(item.scheduledMinutes!)}'
                  : 'No time set',
              child: GestureDetector(
                onTap: onSetTime,
                onLongPress: hasTime ? onClearTime : null,
                child: Container(
                  width: 62,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hasTime ? palette.accent.withValues(alpha: 0.12) : palette.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: hasTime
                      ? Text(
                          formatScheduledTime(item.scheduledMinutes!),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: palette.accent,
                          ),
                        )
                      : Icon(Icons.add_alarm_outlined, size: 18, color: palette.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.imageUrl.isEmpty
                ? Container(
                    width: 52,
                    height: 52,
                    color: palette.background,
                    child: const Icon(Icons.image_not_supported_outlined),
                  )
                : CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    memCacheWidth: 156,
                    memCacheHeight: 156,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600, color: palette.textPrimary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      item.category,
                      style: TextStyle(fontSize: 12.5, color: palette.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onSetCost,
                      child: Text(
                        item.estimatedCost != null
                            ? 'RM ${item.estimatedCost!.toStringAsFixed(2)}'
                            : '+ Add cost',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: palette.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: Icon(Icons.close, size: 20, color: palette.textSecondary),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
