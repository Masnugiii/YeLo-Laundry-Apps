import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/dashboard_activity_item.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';

String formatDashboardOrderNumber(IncomingOrder order) {
  if (order.queueNumber.isNotEmpty) {
    return 'Order ${order.queueNumber}';
  }
  if (order.invoiceNumber.isNotEmpty) {
    return 'Order ${order.invoiceNumber}';
  }
  return 'Order #${order.id.substring(0, 8)}';
}

Color dashboardActivityStatusColor(IncomingOrderStatus status) {
  return switch (status) {
    IncomingOrderStatus.siapDiambil || IncomingOrderStatus.selesai =>
      AppColors.success,
    IncomingOrderStatus.orderBaru => AppColors.warning,
    _ => AppColors.primary,
  };
}

DashboardActivityItem mapOrderToDashboardActivity(IncomingOrder order) {
  return DashboardActivityItem(
    orderId: order.id,
    orderNumber: formatDashboardOrderNumber(order),
    customerName: order.customerName,
    service: order.serviceLabel,
    status: order.status.label,
    statusColor: dashboardActivityStatusColor(order.status),
    activityTime: order.receivedAt,
    orderStatus: order.status,
  );
}
