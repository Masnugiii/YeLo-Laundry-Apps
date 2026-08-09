import 'package:yelo_laundry_erp/features/binatu/models/binatu_notification.dart';

List<BinatuNotification> dummyBinatuNotifications() {
  final now = DateTime.now();

  return [
    BinatuNotification(
      id: 'bnotif-001',
      type: BinatuNotificationType.newIroningJob,
      orderNumber: 'YL-004291',
      customerName: 'Andi Saputra',
      service: 'Cuci Kering Setrika',
      weightKg: 4.5,
      createdAt: now.subtract(const Duration(minutes: 8)),
      message: 'Order baru siap disetrika.',
    ),
    BinatuNotification(
      id: 'bnotif-002',
      type: BinatuNotificationType.ironingJobAccepted,
      orderNumber: 'YL-004290',
      customerName: 'Siti Rahayu',
      assignedBinatu: 'Pak Budi',
      createdAt: now.subtract(const Duration(minutes: 20)),
      message: 'Pekerjaan setrika telah diterima.',
    ),
    BinatuNotification(
      id: 'bnotif-003',
      type: BinatuNotificationType.todaysDeadline,
      orderNumber: 'YL-004289',
      customerName: 'Budi Santoso',
      createdAt: now.subtract(const Duration(minutes: 35)),
      message: 'Deadline setrika hari ini pukul 11:30 WIB.',
    ),
    BinatuNotification(
      id: 'bnotif-004',
      type: BinatuNotificationType.ironingFinished,
      orderNumber: 'YL-004288',
      customerName: 'Dewi Lestari',
      assignedBinatu: 'Pak Budi',
      createdAt: now.subtract(const Duration(minutes: 25)),
      message: 'Setrika selesai dan siap quality check.',
    ),
    BinatuNotification(
      id: 'bnotif-005',
      type: BinatuNotificationType.readyForCashier,
      orderNumber: 'YL-004287',
      customerName: 'Rina Wijaya',
      createdAt: now.subtract(const Duration(hours: 1)),
      message: 'Order siap diambil. Kasir dapat memberi tahu pelanggan.',
    ),
  ];
}

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
