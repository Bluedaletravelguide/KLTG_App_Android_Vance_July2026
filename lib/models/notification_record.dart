class NotificationRecord {
  final String title;
  final String body;
  final DateTime receivedAt;

  const NotificationRecord({
    required this.title,
    required this.body,
    required this.receivedAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'receivedAt': receivedAt.toIso8601String(),
      };

  factory NotificationRecord.fromJson(Map<String, dynamic> json) => NotificationRecord(
        title: (json['title'] ?? '').toString(),
        body: (json['body'] ?? '').toString(),
        receivedAt: DateTime.tryParse((json['receivedAt'] ?? '').toString()) ?? DateTime.now(),
      );
}
