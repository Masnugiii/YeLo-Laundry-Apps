String formatBinatuNotificationRelativeTime(DateTime createdAt) {
  final difference = DateTime.now().difference(createdAt);

  if (difference.inMinutes < 1) return 'Baru saja';
  if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
  if (difference.inHours < 24) return '${difference.inHours} jam lalu';
  return '${difference.inDays} hari lalu';
}

String formatBinatuNotificationTime(DateTime createdAt) {
  final hour = createdAt.hour.toString().padLeft(2, '0');
  final minute = createdAt.minute.toString().padLeft(2, '0');
  return '$hour:$minute WIB';
}
