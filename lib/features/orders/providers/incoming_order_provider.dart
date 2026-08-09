import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/notifications/models/laundry_job_accepted_notification.dart';
import 'package:yelo_laundry_erp/features/notifications/providers/app_notification_provider.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_timeline_entry.dart';

class IncomingOrderNotifier extends AsyncNotifier<List<IncomingOrder>> {
  @override
  Future<List<IncomingOrder>> build() async {
    final response = await ref.read(orderRepositoryProvider).fetchOrders();
    return response.items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  void acceptLaundryJob({
    required String orderId,
    required String acceptedBy,
  }) {
    final orders = state.value;
    if (orders == null) return;

    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    final order = orders[index];
    if (!order.canAcceptLaundryJob) return;

    final acceptedAt = DateTime.now();
    final timelineEntry = OrderTimelineEntry(
      id: 'timeline-$orderId-${acceptedAt.millisecondsSinceEpoch}',
      time: acceptedAt,
      title: 'Laundry Job Accepted',
      actorName: acceptedBy,
    );

    final updatedPic = PicAssignment(
      pickup: order.picAssignment.pickup,
      washing: acceptedBy,
      ironing: order.picAssignment.ironing,
      qualityCheck: order.picAssignment.qualityCheck,
      delivery: order.picAssignment.delivery,
    );

    final updatedOrder = order.copyWith(
      isLaundryJobAccepted: true,
      laundryPic: acceptedBy,
      laundryAcceptedAt: acceptedAt,
      laundryAcceptedBy: acceptedBy,
      currentStep: OrderWorkflowStep.washing,
      status: IncomingOrderStatus.sedangDicuci,
      picAssignment: updatedPic,
      timelineEntries: [timelineEntry, ...order.timelineEntries],
    );

    final updatedOrders = [...orders];
    updatedOrders[index] = updatedOrder;
    state = AsyncData(updatedOrders);

    ref.read(appNotificationProvider.notifier).addLaundryJobAccepted(
          LaundryJobAcceptedNotification(
            id: 'job-notif-${acceptedAt.millisecondsSinceEpoch}',
            orderId: order.id,
            orderNumber: order.queueNumber,
            customerName: order.customerName,
            serviceName: order.serviceLabel,
            weightKg: order.weightKg,
            acceptedBy: acceptedBy,
            acceptedAt: acceptedAt,
          ),
        );
  }
}

final incomingOrderProvider =
    AsyncNotifierProvider<IncomingOrderNotifier, List<IncomingOrder>>(
  IncomingOrderNotifier.new,
);

int laundryQueuePendingCount(List<IncomingOrder> orders) =>
    orders.where((order) => order.canAcceptLaundryJob).length;
