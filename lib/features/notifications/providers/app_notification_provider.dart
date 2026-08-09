import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/features/notifications/data/dummy_cashier_notifications.dart';
import 'package:yelo_laundry_erp/features/notifications/models/cashier_transaction_notification.dart';
import 'package:yelo_laundry_erp/features/notifications/models/laundry_job_accepted_notification.dart';
import 'package:yelo_laundry_erp/features/notifications/models/operator_assistance_notification.dart';

class AppNotificationState {
  const AppNotificationState({
    required this.transactionNotifications,
    required this.laundryJobNotifications,
    required this.operatorAssistanceNotifications,
  });

  final List<CashierTransactionNotification> transactionNotifications;
  final List<LaundryJobAcceptedNotification> laundryJobNotifications;
  final List<OperatorAssistanceNotification> operatorAssistanceNotifications;

  AppNotificationState copyWith({
    List<CashierTransactionNotification>? transactionNotifications,
    List<LaundryJobAcceptedNotification>? laundryJobNotifications,
    List<OperatorAssistanceNotification>? operatorAssistanceNotifications,
  }) {
    return AppNotificationState(
      transactionNotifications:
          transactionNotifications ?? this.transactionNotifications,
      laundryJobNotifications:
          laundryJobNotifications ?? this.laundryJobNotifications,
      operatorAssistanceNotifications: operatorAssistanceNotifications ??
          this.operatorAssistanceNotifications,
    );
  }
}

class AppNotificationNotifier extends Notifier<AppNotificationState> {
  @override
  AppNotificationState build() {
    return AppNotificationState(
      transactionNotifications: dummyCashierTransactionNotifications(),
      laundryJobNotifications: const [],
      operatorAssistanceNotifications: const [],
    );
  }

  void addLaundryJobAccepted(LaundryJobAcceptedNotification notification) {
    state = state.copyWith(
      laundryJobNotifications: [notification, ...state.laundryJobNotifications],
    );
  }

  void upsertOperatorAssistance(OperatorAssistanceNotification notification) {
    final existingIndex = state.operatorAssistanceNotifications
        .indexWhere((item) => item.orderId == notification.orderId);

    if (existingIndex == -1) {
      state = state.copyWith(
        operatorAssistanceNotifications: [
          notification,
          ...state.operatorAssistanceNotifications,
        ],
      );
      return;
    }

    final updated = [...state.operatorAssistanceNotifications];
    final existing = updated[existingIndex];
    if (existing.isResolved) return;

    updated[existingIndex] = notification;
    state = state.copyWith(operatorAssistanceNotifications: updated);
  }

  void resolveOperatorAssistance(String orderId, {required String acceptedBy}) {
    final updated = state.operatorAssistanceNotifications.map((notification) {
      if (notification.orderId != orderId || notification.isResolved) {
        return notification;
      }

      return notification.copyWith(
        isResolved: true,
        acceptedBy: acceptedBy,
        resolvedAt: DateTime.now(),
      );
    }).toList();

    state = state.copyWith(operatorAssistanceNotifications: updated);
  }

  List<LaundryJobAcceptedNotification> laundryJobsForCashierAndOwner() {
    return [...state.laundryJobNotifications]
      ..sort((a, b) => b.acceptedAt.compareTo(a.acceptedAt));
  }

  List<CashierTransactionNotification> transactionsForCashier() {
    return [...state.transactionNotifications]
      ..sort((a, b) => b.transactionAt.compareTo(a.transactionAt));
  }

  List<OperatorAssistanceNotification> operatorAssistanceForOperators() {
    return [...state.operatorAssistanceNotifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

final appNotificationProvider =
    NotifierProvider<AppNotificationNotifier, AppNotificationState>(
  AppNotificationNotifier.new,
);
