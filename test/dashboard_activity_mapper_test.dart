import 'package:flutter_test/flutter_test.dart';
import 'package:yelo_laundry_erp/core/utils/date_display_helper.dart';
import 'package:yelo_laundry_erp/features/dashboard/utils/dashboard_activity_mapper.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';

IncomingOrder _order({
  String id = 'order-12345678',
  String queueNumber = 'YL-00124',
  String customerName = 'Budi',
  IncomingOrderStatus status = IncomingOrderStatus.orderBaru,
  DateTime? receivedAt,
}) {
  return IncomingOrder(
    id: id,
    queueNumber: queueNumber,
    customerName: customerName,
    customerPhone: '08123456789',
    invoiceNumber: 'INV-001',
    itemCount: 1,
    assignedEmployeeName: '-',
    service: LaundryServiceType.regular,
    orderValue: 50000,
    fulfillmentType: FulfillmentType.selfPickup,
    receivedAt: receivedAt ?? DateTime(2026, 8, 10, 9, 42),
    estimatedCompletion: DateTime(2026, 8, 12),
    currentStep: OrderWorkflowStep.orderReceived,
    status: status,
    picAssignment: const PicAssignment(
      pickup: '-',
      washing: '-',
      ironing: '-',
      qualityCheck: '-',
      delivery: '-',
    ),
    weightKg: 3,
    paymentStatus: OrderPaymentStatus.belumLunas,
  );
}

void main() {
  group('DateDisplayHelper.todayApiDateParam', () {
    test('formats date for API query', () {
      expect(
        DateDisplayHelper.todayApiDateParam(DateTime(2026, 8, 10)),
        '2026-08-10',
      );
    });
  });

  group('mapOrderToDashboardActivity', () {
    test('maps queue number and status label', () {
      final activity = mapOrderToDashboardActivity(
        _order(status: IncomingOrderStatus.sedangDicuci),
      );

      expect(activity.orderId, 'order-12345678');
      expect(activity.orderNumber, 'Order YL-00124');
      expect(activity.status, 'Sedang Dicuci');
      expect(activity.activityTime, DateTime(2026, 8, 10, 9, 42));
    });

    test('falls back to invoice number when queue number is empty', () {
      final activity = mapOrderToDashboardActivity(
        _order(queueNumber: '', customerName: 'Ani'),
      );

      expect(activity.orderNumber, 'Order INV-001');
    });
  });
}
