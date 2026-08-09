class OrderTimelineEntry {
  const OrderTimelineEntry({
    required this.id,
    required this.time,
    required this.title,
    this.actorName,
  });

  final String id;
  final DateTime time;
  final String title;
  final String? actorName;

  String get timeLabel {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }
}
