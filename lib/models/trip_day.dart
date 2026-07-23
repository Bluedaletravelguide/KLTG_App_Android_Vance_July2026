import 'package:kltheguide/models/trip_item.dart';

/// One day of the single running itinerary. Labels are always "Day N" —
/// there's no free-form rename UI, so TripPlannerService can safely
/// renumber survivors after a deletion without colliding with user text.
class TripDay {
  final String label;
  final List<TripItem> items;

  TripDay({required this.label, List<TripItem>? items}) : items = items ?? const [];

  /// Items with a scheduled time, earliest first, followed by unscheduled
  /// items in the order they were added — the display order used by both
  /// TripPlannerPage and the shared/exported itinerary text.
  List<TripItem> get itemsInScheduleOrder {
    final scheduled = items.where((i) => i.scheduledMinutes != null).toList()
      ..sort((a, b) => a.scheduledMinutes!.compareTo(b.scheduledMinutes!));
    final unscheduled = items.where((i) => i.scheduledMinutes == null).toList();
    return [...scheduled, ...unscheduled];
  }

  /// Sum of items' estimatedCost (MYR), ignoring places with no cost entered.
  double get totalCost =>
      items.fold(0.0, (sum, i) => sum + (i.estimatedCost ?? 0));

  Map<String, dynamic> toJson() => {
        'label': label,
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory TripDay.fromJson(Map<String, dynamic> json) => TripDay(
        label: (json['label'] ?? '').toString(),
        items: (json['items'] as List? ?? [])
            .map((e) => TripItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}
