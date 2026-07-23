import 'package:kltheguide/models/listing_item.dart';

/// A place saved into the trip planner. Denormalized (copies the listing's
/// fields rather than storing a reference) because listings have no stable
/// id to reference — same tradeoff the existing blog bookmarks feature makes.
class TripItem {
  final String title;
  final String imageUrl;
  final String description;
  final String address;
  final String mapsUrl;
  final String hours;
  final String contact;
  final String website;
  final String category;
  // Minutes since midnight (0-1439). Null means the place hasn't been
  // scheduled to a specific time yet — it's just "sometime this day".
  final int? scheduledMinutes;
  // Estimated cost in MYR (the app's home currency). Null means no budget
  // has been entered for this place yet.
  final double? estimatedCost;

  const TripItem({
    required this.title,
    required this.imageUrl,
    required this.category,
    this.description = '',
    this.address = '',
    this.mapsUrl = '',
    this.hours = '',
    this.contact = '',
    this.website = '',
    this.scheduledMinutes,
    this.estimatedCost,
  });

  TripItem copyWithTime(int? scheduledMinutes) => TripItem(
        title: title,
        imageUrl: imageUrl,
        category: category,
        description: description,
        address: address,
        mapsUrl: mapsUrl,
        hours: hours,
        contact: contact,
        website: website,
        scheduledMinutes: scheduledMinutes,
        estimatedCost: estimatedCost,
      );

  TripItem copyWithCost(double? estimatedCost) => TripItem(
        title: title,
        imageUrl: imageUrl,
        category: category,
        description: description,
        address: address,
        mapsUrl: mapsUrl,
        hours: hours,
        contact: contact,
        website: website,
        scheduledMinutes: scheduledMinutes,
        estimatedCost: estimatedCost,
      );

  factory TripItem.fromListingItem(ListingItem item, {required String category}) {
    return TripItem(
      title: item.title,
      imageUrl: item.imageUrl,
      description: item.description,
      address: item.address,
      mapsUrl: item.mapsUrl,
      hours: item.hours,
      contact: item.contact,
      website: item.website,
      category: category,
    );
  }

  /// Identifies "the same place" for dedupe purposes — title scoped to
  /// category, since listings have no stable id to key off of instead.
  String get dedupeKey => '$category|$title';

  Map<String, dynamic> toJson() => {
        'title': title,
        'imageUrl': imageUrl,
        'description': description,
        'address': address,
        'mapsUrl': mapsUrl,
        'hours': hours,
        'contact': contact,
        'website': website,
        'category': category,
        'scheduledMinutes': scheduledMinutes,
        'estimatedCost': estimatedCost,
      };

  factory TripItem.fromJson(Map<String, dynamic> json) => TripItem(
        title: (json['title'] ?? '').toString(),
        imageUrl: (json['imageUrl'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        address: (json['address'] ?? '').toString(),
        mapsUrl: (json['mapsUrl'] ?? '').toString(),
        hours: (json['hours'] ?? '').toString(),
        contact: (json['contact'] ?? '').toString(),
        website: (json['website'] ?? '').toString(),
        category: (json['category'] ?? '').toString(),
        scheduledMinutes: json['scheduledMinutes'] as int?,
        estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      );
}
