import 'package:yelo_laundry_erp/features/notifications/models/cashier_transaction_notification.dart';

/// Dummy cashier payment notifications — newest transaction first.
List<CashierTransactionNotification> dummyCashierTransactionNotifications() {
  final now = DateTime.now();

  return [
    CashierTransactionNotification(
      id: 'notif-001',
      type: CashierNotificationType.cashPayment,
      customerName: 'Budi Santoso',
      orderNumber: 'A-4295',
      amount: 185000,
      paymentMethod: 'Cash',
      transactionAt: now.subtract(const Duration(minutes: 3)),
    ),
    CashierTransactionNotification(
      id: 'notif-002',
      type: CashierNotificationType.qrisPayment,
      customerName: 'Siti Rahayu',
      orderNumber: 'A-4294',
      amount: 95000,
      transactionAt: now.subtract(const Duration(minutes: 12)),
    ),
    CashierTransactionNotification(
      id: 'notif-003',
      type: CashierNotificationType.walletTopUp,
      customerName: 'Andi Pratama',
      transactionNumber: 'WTU-20260808-0142',
      amount: 250000,
      transactionAt: now.subtract(const Duration(minutes: 25)),
    ),
    CashierTransactionNotification(
      id: 'notif-004',
      type: CashierNotificationType.transferPayment,
      customerName: 'Dewi Lestari',
      orderNumber: 'A-4292',
      amount: 320000,
      transactionAt: now.subtract(const Duration(minutes: 41)),
    ),
    CashierTransactionNotification(
      id: 'notif-005',
      type: CashierNotificationType.walletDeduction,
      customerName: 'Rina Wijaya',
      transactionNumber: 'WDD-20260808-0138',
      orderNumber: 'A-4291',
      amount: 120000,
      transactionAt: now.subtract(const Duration(hours: 1, minutes: 5)),
    ),
    CashierTransactionNotification(
      id: 'notif-006',
      type: CashierNotificationType.qrisPayment,
      customerName: 'John Anderson',
      orderNumber: 'A-4290',
      amount: 275000,
      transactionAt: now.subtract(const Duration(hours: 1, minutes: 28)),
    ),
    CashierTransactionNotification(
      id: 'notif-007',
      type: CashierNotificationType.cashPayment,
      customerName: 'Maya Sari',
      orderNumber: 'A-4289',
      amount: 65000,
      paymentMethod: 'Cash',
      transactionAt: now.subtract(const Duration(hours: 2, minutes: 10)),
    ),
    CashierTransactionNotification(
      id: 'notif-008',
      type: CashierNotificationType.walletDeduction,
      customerName: 'Bambang Hartono',
      transactionNumber: 'WDD-20260808-0095',
      orderNumber: 'A-4288',
      amount: 89000,
      transactionAt: now.subtract(const Duration(hours: 3)),
    ),
    CashierTransactionNotification(
      id: 'notif-009',
      type: CashierNotificationType.transferPayment,
      customerName: 'Fitri Handayani',
      orderNumber: 'A-4287',
      amount: 410000,
      transactionAt: now.subtract(const Duration(hours: 4, minutes: 15)),
    ),
    CashierTransactionNotification(
      id: 'notif-010',
      type: CashierNotificationType.walletTopUp,
      customerName: 'Agus Setiawan',
      transactionNumber: 'WTU-20260808-0061',
      amount: 500000,
      transactionAt: now.subtract(const Duration(hours: 5, minutes: 30)),
    ),
  ];
}

String formatCashierNotificationRelativeTime(DateTime transactionAt) {
  final now = DateTime.now();
  final difference = now.difference(transactionAt);

  if (difference.inMinutes < 1) {
    return 'Baru saja';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} menit lalu';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} jam lalu';
  }

  return '${difference.inDays} hari lalu';
}

String formatCashierNotificationTime(DateTime transactionAt) {
  final hour = transactionAt.hour.toString().padLeft(2, '0');
  final minute = transactionAt.minute.toString().padLeft(2, '0');
  return '$hour:$minute WIB';
}
