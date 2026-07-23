class ContentItem {
  final String title;
  final String imageUrl;
  final String description;
  final String description2;
  final String address;
  final String mapsUrl;
  final String hours;
  final String contact;
  final String website;

  const ContentItem({
    required this.title,
    required this.imageUrl,
    this.description = '',
    this.description2 = '',
    this.address = '',
    this.mapsUrl = '',
    this.hours = '',
    this.contact = '',
    this.website = '',
  });
}
