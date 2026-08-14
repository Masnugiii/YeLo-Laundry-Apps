import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';

class DashboardActivityItem {
  const DashboardActivityItem({
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.service,
    required this.status,
    required this.statusColor,
    required this.activityTime,
    required this.orderStatus,
  });

  final String orderId;
  final String orderNumber;
  final String customerName;
  final String service;
  final String status;
  final Color statusColor;
  final DateTime activityTime;
  final IncomingOrderStatus orderStatus;
}
