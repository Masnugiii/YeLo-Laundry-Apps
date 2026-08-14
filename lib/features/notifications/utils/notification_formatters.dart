String formatCashierNotificationRelativeTime(DateTime transactionAt) {
  final difference = DateTime.now().difference(transactionAt);

  if (difference.inMinutes < 1) return 'Baru saja';
  if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
  if (difference.inHours < 24) return '${difference.inHours} jam lalu';
  return '${difference.inDays} hari lalu';
}

String formatCashierNotificationTime(DateTime transactionAt) {
  final hour = transactionAt.hour.toString().padLeft(2, '0');
  final minute = transactionAt.minute.toString().padLeft(2, '0');
  return '$hour:$minute WIB';
}
