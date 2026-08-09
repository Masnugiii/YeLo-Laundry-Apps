import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/features/binatu/data/dummy_binatu_orders.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_order.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_status.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_notification.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_notification_provider.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/ironing_queue_priority_provider.dart';
import 'package:yelo_laundry_erp/features/notifications/models/operator_assistance_notification.dart';
import 'package:yelo_laundry_erp/features/notifications/providers/app_notification_provider.dart';

class BinatuOrderNotifier extends Notifier<List<BinatuIroningOrder>> {
  @override
  List<BinatuIroningOrder> build() {
    ref.listen(ironingQueuePriorityProvider, (_, _) {
      Future.microtask(_runPostInitTasks);
    });
    final orders = List.of(dummyBinatuIroningOrders());
    Future.microtask(_runPostInitTasks);
    return orders;
  }

  void _runPostInitTasks() {
    _seedOperatorAssistanceNotifications();
    processWaitingTimers();
  }

  void _seedOperatorAssistanceNotifications() {
    for (final order in state) {
      if (order.isWaitingForOperatorAssistance) {
        ref.read(appNotificationProvider.notifier).upsertOperatorAssistance(
              _operatorAssistanceNotificationFor(order),
            );
      }
    }
  }

  OperatorAssistanceNotification _operatorAssistanceNotificationFor(
    BinatuIroningOrder order,
  ) {
    return OperatorAssistanceNotification(
      id: 'opassist-${order.id}',
      orderId: order.id,
      orderNumber: order.orderNumber,
      customerName: order.customerName,
      weightKg: order.weightKg,
      waitingStartedAt: order.waitingStartedAt,
      createdAt: order.operatorAssistanceAvailableAt ?? DateTime.now(),
    );
  }

  BinatuDashboardSummary dashboardSummary() {
    final waiting = state
        .where(
          (o) =>
              o.ironingStatus == BinatuIroningStatus.waitingForBinatu ||
              o.ironingStatus ==
                  BinatuIroningStatus.waitingForOperatorAssistance,
        )
        .length;
    final ironing = state
        .where(
          (o) =>
              o.ironingStatus == BinatuIroningStatus.currentlyIroning ||
              o.ironingStatus == BinatuIroningStatus.acceptedByBinatu,
        )
        .length;
    final completedOrders = state.where(
      (o) =>
          o.ironingStatus == BinatuIroningStatus.finishedIroning ||
          o.ironingStatus == BinatuIroningStatus.readyForPickup,
    );
    final ironingCompleted = completedOrders
        .where((order) => !order.isOperatorAssistance)
        .length;
    final operatorAssistanceCompleted = completedOrders
        .where((order) => order.isOperatorAssistance)
        .length;
    final completedKg = completedOrders.fold<double>(
      0,
      (sum, order) => sum + order.weightKg,
    );

    return BinatuDashboardSummary(
      waitingToBeAssigned: waiting,
      currentlyIroning: ironing,
      ironingCompleted: ironingCompleted,
      operatorAssistanceCompleted: operatorAssistanceCompleted,
      todaysTargetKg: dummyBinatuTodaysTargetKg,
      todaysCompletedKg: completedKg,
    );
  }

  int operatorAssistanceCompletedCount() {
    return state
        .where(
          (order) =>
              order.isOperatorAssistance &&
              (order.ironingStatus == BinatuIroningStatus.finishedIroning ||
                  order.ironingStatus == BinatuIroningStatus.readyForPickup),
        )
        .length;
  }

  BinatuIroningOrder? orderById(String id) {
    for (final order in state) {
      if (order.id == id) return order;
    }
    return null;
  }

  void _updateOrder(String id, BinatuIroningOrder updated) {
    final index = state.indexWhere((order) => order.id == id);
    if (index == -1) return;
    final orders = [...state];
    orders[index] = updated;
    state = orders;
  }

  void processWaitingTimers() {
    final settings = ref.read(ironingQueuePriorityProvider);
    if (!settings.binatuFirst || !settings.allowOperatorAssistance) {
      return;
    }

    final now = DateTime.now();
    var changed = false;

    final updatedOrders = state.map((order) {
      if (!order.isWaitingForBinatu) return order;

      final elapsed = now.difference(order.waitingStartedAt);
      if (elapsed < settings.waitingDuration) return order;

      changed = true;
      final assistanceAt = order.waitingStartedAt.add(settings.waitingDuration);
      final updated = order.copyWith(
        ironingStatus: BinatuIroningStatus.waitingForOperatorAssistance,
        operatorAssistanceAvailableAt: assistanceAt,
      );

      ref.read(appNotificationProvider.notifier).upsertOperatorAssistance(
            _operatorAssistanceNotificationFor(updated),
          );

      return updated;
    }).toList();

    if (changed) {
      state = updatedOrders;
    }
  }

  void createIroningJob(BinatuIroningOrder order) {
    final createdAt = DateTime.now();
    state = [
      order.copyWith(
        ironingStatus: BinatuIroningStatus.waitingForBinatu,
        waitingStartedAt: createdAt,
      ),
      ...state,
    ];

    ref.read(binatuNotificationProvider.notifier).prepend(
          BinatuNotification(
            id: 'bnotif-new-${createdAt.millisecondsSinceEpoch}',
            type: BinatuNotificationType.newIroningJob,
            orderNumber: order.orderNumber,
            customerName: order.customerName,
            service: order.service,
            weightKg: order.weightKg,
            createdAt: createdAt,
            message: 'Order baru siap disetrika.',
          ),
        );
  }

  void acceptJobAsBinatu(
    String orderId, {
    String staffName = dummyBinatuStaffName,
  }) {
    processWaitingTimers();
    final order = orderById(orderId);
    if (order == null || !order.canBinatuAccept) return;

    final acceptedAt = DateTime.now();
    _updateOrder(
      orderId,
      order.copyWith(
        ironingStatus: BinatuIroningStatus.acceptedByBinatu,
        assignedBinatu: staffName,
        acceptedAt: acceptedAt,
        isOperatorAssistance: false,
      ),
    );

    ref.read(appNotificationProvider.notifier).resolveOperatorAssistance(
          orderId,
          acceptedBy: staffName,
        );

    ref.read(binatuNotificationProvider.notifier).prepend(
          BinatuNotification(
            id: 'bnotif-${acceptedAt.millisecondsSinceEpoch}',
            type: BinatuNotificationType.ironingJobAccepted,
            orderNumber: order.orderNumber,
            customerName: order.customerName,
            assignedBinatu: staffName,
            createdAt: acceptedAt,
            message: 'Pekerjaan setrika telah diterima.',
          ),
        );
  }

  void acceptJobAsOperator(
    String orderId, {
    String staffName = dummyOperatorStaffName,
  }) {
    processWaitingTimers();
    final settings = ref.read(ironingQueuePriorityProvider);
    final order = orderById(orderId);
    if (order == null || !order.canOperatorAccept(settings.allowOperatorAssistance)) {
      return;
    }

    final acceptedAt = DateTime.now();
    _updateOrder(
      orderId,
      order.copyWith(
        ironingStatus: BinatuIroningStatus.acceptedByBinatu,
        assignedBinatu: staffName,
        acceptedAt: acceptedAt,
        isOperatorAssistance: true,
      ),
    );

    ref.read(appNotificationProvider.notifier).resolveOperatorAssistance(
          orderId,
          acceptedBy: staffName,
        );

    ref.read(binatuNotificationProvider.notifier).prepend(
          BinatuNotification(
            id: 'bnotif-op-${acceptedAt.millisecondsSinceEpoch}',
            type: BinatuNotificationType.ironingJobAccepted,
            orderNumber: order.orderNumber,
            customerName: order.customerName,
            assignedBinatu: staffName,
            createdAt: acceptedAt,
            message: 'Bantuan operator telah menerima pekerjaan setrika.',
          ),
        );
  }

  void acceptJob(String orderId, {String staffName = dummyBinatuStaffName}) {
    acceptJobAsBinatu(orderId, staffName: staffName);
  }

  void startIroning(String orderId) {
    final order = orderById(orderId);
    if (order == null || !order.canStartIroning) return;

    _updateOrder(
      orderId,
      order.copyWith(
        ironingStatus: BinatuIroningStatus.currentlyIroning,
      ),
    );
  }

  void finishIroning(String orderId) {
    final order = orderById(orderId);
    if (order == null || !order.canFinishIroning) return;

    final finishedAt = DateTime.now();
    _updateOrder(
      orderId,
      order.copyWith(
        ironingStatus: BinatuIroningStatus.finishedIroning,
        finishedAt: finishedAt,
      ),
    );

    ref.read(binatuNotificationProvider.notifier).prepend(
          BinatuNotification(
            id: 'bnotif-finish-${finishedAt.millisecondsSinceEpoch}',
            type: BinatuNotificationType.ironingFinished,
            orderNumber: order.orderNumber,
            customerName: order.customerName,
            assignedBinatu: order.assignedBinatu,
            createdAt: finishedAt,
            message: order.isOperatorAssistance
                ? 'Bantuan operator selesai menyetrika.'
                : 'Setrika selesai.',
          ),
        );
  }

  void markReadyForPickup(String orderId) {
    final order = orderById(orderId);
    if (order == null || !order.canMarkReadyForPickup) return;

    final readyAt = DateTime.now();
    _updateOrder(
      orderId,
      order.copyWith(
        ironingStatus: BinatuIroningStatus.readyForPickup,
      ),
    );

    ref.read(binatuNotificationProvider.notifier).prepend(
          BinatuNotification(
            id: 'bnotif-ready-${readyAt.millisecondsSinceEpoch}',
            type: BinatuNotificationType.readyForCashier,
            orderNumber: order.orderNumber,
            customerName: order.customerName,
            createdAt: readyAt,
            message: 'Order siap diambil pelanggan.',
          ),
        );
  }
}

final binatuOrderProvider =
    NotifierProvider<BinatuOrderNotifier, List<BinatuIroningOrder>>(
  BinatuOrderNotifier.new,
);

class BinatuQueueFilterNotifier extends Notifier<BinatuQueueFilter> {
  @override
  BinatuQueueFilter build() => BinatuQueueFilter.ironingQueue;

  void setFilter(BinatuQueueFilter filter) => state = filter;
}

class BinatuDashboardTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final binatuQueueFilterProvider =
    NotifierProvider<BinatuQueueFilterNotifier, BinatuQueueFilter>(
  BinatuQueueFilterNotifier.new,
);

final binatuDashboardTabProvider =
    NotifierProvider<BinatuDashboardTabNotifier, int>(
  BinatuDashboardTabNotifier.new,
);
