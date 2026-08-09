import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/binatu/data/binatu_laundry_mapper.dart';
import 'package:yelo_laundry_erp/features/binatu/data/dummy_binatu_orders.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_order.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_status.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_notification.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_notification_provider.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/ironing_queue_priority_provider.dart';
import 'package:yelo_laundry_erp/features/notifications/models/operator_assistance_notification.dart';
import 'package:yelo_laundry_erp/features/notifications/providers/app_notification_provider.dart';

class BinatuOrderNotifier extends AsyncNotifier<List<BinatuIroningOrder>> {
  @override
  Future<List<BinatuIroningOrder>> build() async {
    ref.listen(ironingQueuePriorityProvider, (_, _) {
      Future.microtask(_runPostInitTasks);
    });

    final orders = await _loadFromApi();
    Future.microtask(_runPostInitTasks);
    return orders;
  }

  List<BinatuIroningOrder> get _orders => state.value ?? [];

  Future<List<BinatuIroningOrder>> _loadFromApi() async {
    final items =
        await ref.read(laundryRepositoryProvider).fetchIroningQueue();
    return items.map(mapBinatuIroningOrder).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadFromApi());
    _runPostInitTasks();
  }

  Future<void> _runActionAndRefresh(String orderId, String action) async {
    await ref.read(laundryRepositoryProvider).runAction(orderId, action);
    await refresh();
  }

  void _runPostInitTasks() {
    _seedOperatorAssistanceNotifications();
    processWaitingTimers();
  }

  void _seedOperatorAssistanceNotifications() {
    for (final order in _orders) {
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

  BinatuDashboardSummary dashboardSummary({Map<String, dynamic>? laundry}) {
    final waiting = laundry != null
        ? (laundry['waitingIroning'] as num?)?.toInt() ?? 0
        : _orders
            .where(
              (o) =>
                  o.ironingStatus == BinatuIroningStatus.waitingForBinatu ||
                  o.ironingStatus ==
                      BinatuIroningStatus.waitingForOperatorAssistance,
            )
            .length;
    final ironing = laundry != null
        ? (laundry['currentlyIroning'] as num?)?.toInt() ?? 0
        : _orders
            .where(
              (o) =>
                  o.ironingStatus == BinatuIroningStatus.currentlyIroning ||
                  o.ironingStatus == BinatuIroningStatus.acceptedByBinatu,
            )
            .length;
    final completedOrders = _orders.where(
      (o) =>
          o.ironingStatus == BinatuIroningStatus.finishedIroning ||
          o.ironingStatus == BinatuIroningStatus.readyForPickup,
    );
    final ironingCompleted = laundry != null
        ? (laundry['qualityCheck'] as num?)?.toInt() ?? 0
        : completedOrders
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
    return _orders
        .where(
          (order) =>
              order.isOperatorAssistance &&
              (order.ironingStatus == BinatuIroningStatus.finishedIroning ||
                  order.ironingStatus == BinatuIroningStatus.readyForPickup),
        )
        .length;
  }

  BinatuIroningOrder? orderById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  void _updateOrder(String id, BinatuIroningOrder updated) {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index == -1) return;
    final orders = [..._orders];
    orders[index] = updated;
    state = AsyncData(orders);
  }

  void processWaitingTimers() {
    final settings = ref.read(ironingQueuePriorityProvider);
    if (!settings.binatuFirst || !settings.allowOperatorAssistance) {
      return;
    }

    final now = DateTime.now();
    var changed = false;

    final updatedOrders = _orders.map((order) {
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
      state = AsyncData(updatedOrders);
    }
  }

  void createIroningJob(BinatuIroningOrder order) {
    final createdAt = DateTime.now();
    state = AsyncData([
      order.copyWith(
        ironingStatus: BinatuIroningStatus.waitingForBinatu,
        waitingStartedAt: createdAt,
      ),
      ..._orders,
    ]);

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
    if (order == null ||
        !order.canOperatorAccept(settings.allowOperatorAssistance)) {
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

  Future<void> startIroning(String orderId) async {
    final order = orderById(orderId);
    if (order == null || !order.canStartIroning) return;

    await _runActionAndRefresh(orderId, 'start-ironing');
  }

  Future<void> finishIroning(String orderId) async {
    final order = orderById(orderId);
    if (order == null || !order.canFinishIroning) return;

    await _runActionAndRefresh(orderId, 'finish-ironing');

    final refreshed = orderById(orderId);
    if (refreshed == null) return;

    ref.read(binatuNotificationProvider.notifier).prepend(
          BinatuNotification(
            id: 'bnotif-finish-${DateTime.now().millisecondsSinceEpoch}',
            type: BinatuNotificationType.ironingFinished,
            orderNumber: refreshed.orderNumber,
            customerName: refreshed.customerName,
            assignedBinatu: refreshed.assignedBinatu,
            createdAt: DateTime.now(),
            message: refreshed.isOperatorAssistance
                ? 'Bantuan operator selesai menyetrika.'
                : 'Setrika selesai.',
          ),
        );
  }

  Future<void> markReadyForPickup(String orderId) async {
    final order = orderById(orderId);
    if (order == null || !order.canMarkReadyForPickup) return;

    await _runActionAndRefresh(orderId, 'ready');

    final refreshed = orderById(orderId);
    if (refreshed == null) return;

    ref.read(binatuNotificationProvider.notifier).prepend(
          BinatuNotification(
            id: 'bnotif-ready-${DateTime.now().millisecondsSinceEpoch}',
            type: BinatuNotificationType.readyForCashier,
            orderNumber: refreshed.orderNumber,
            customerName: refreshed.customerName,
            createdAt: DateTime.now(),
            message: 'Order siap diambil pelanggan.',
          ),
        );
  }
}

final binatuOrderProvider =
    AsyncNotifierProvider<BinatuOrderNotifier, List<BinatuIroningOrder>>(
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
