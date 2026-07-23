class ListingItem {
  final String title;
  final String imageUrl;
  final String description;
  final String address;
  final String mapsUrl;
  final String hours;
  final String contact;
  final String website;

  const ListingItem({
    required this.title,
    required this.imageUrl,
    this.description = '',
    this.address = '',
    this.mapsUrl = '',
    this.hours = '',
    this.contact = '',
    this.website = '',
  });
}
