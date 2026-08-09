import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/models/today_order.dart';
import 'package:yelo_laundry_erp/features/orders/models/unpaid_order.dart';

UnpaidOrder toUnpaidOrder(IncomingOrder order) {
  final lateDays = _computeLateDays(order.estimatedCompletion);

  return UnpaidOrder(
    id: order.id,
    customerName: order.customerName,
    customerPhone: order.customerPhone,
    queueNumber: order.queueNumber,
    invoiceNumber: order.invoiceNumber.isNotEmpty
        ? order.invoiceNumber
        : order.queueNumber,
    service: _toUnpaidService(order.service),
    weightKg: order.weightKg,
    quantityPcs: order.itemCount,
    totalAmount: order.orderValue,
    paymentStatus: UnpaidPaymentStatus.belumDibayar,
    fulfillment: _toUnpaidFulfillment(order.fulfillmentType),
    receivedAt: order.receivedAt,
    estimatedCompletion: order.estimatedCompletion,
    deliveryDate: order.deliveryInfo?.dateTime,
    binatuPic: order.assignedEmployeeName,
    lateDays: lateDays,
    lateFee: 0,
  );
}

TodayOrder toTodayOrder(IncomingOrder order) {
  return TodayOrder(
    queueNumber: order.queueNumber,
    customerName: order.customerName,
    weightKg: order.weightKg,
    totalPrice: formatRupiah(order.orderValue),
    status: _toLaundryStatus(order.status),
    serviceType: _toServiceType(order.service),
    pickupDelivery: _toPickupDelivery(order.fulfillmentType),
    paymentMethod: _toTodayPaymentMethod(order.apiPaymentMethod),
  );
}

int _computeLateDays(DateTime estimatedCompletion) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final estimated = DateTime(
    estimatedCompletion.year,
    estimatedCompletion.month,
    estimatedCompletion.day,
  );
  final diff = today.difference(estimated).inDays;
  return diff > 0 ? diff : 0;
}

UnpaidServiceType _toUnpaidService(LaundryServiceType service) {
  return switch (service) {
    LaundryServiceType.regular => UnpaidServiceType.regular,
    LaundryServiceType.express => UnpaidServiceType.express,
    LaundryServiceType.bedCover => UnpaidServiceType.bedCover,
    LaundryServiceType.ironOnly => UnpaidServiceType.ironOnly,
  };
}

UnpaidFulfillmentType _toUnpaidFulfillment(FulfillmentType type) {
  return switch (type) {
    FulfillmentType.selfPickup => UnpaidFulfillmentType.selfPickup,
    FulfillmentType.pickup => UnpaidFulfillmentType.pickup,
    FulfillmentType.delivery => UnpaidFulfillmentType.delivery,
  };
}

LaundryStatus _toLaundryStatus(IncomingOrderStatus status) {
  return switch (status) {
    IncomingOrderStatus.orderBaru => LaundryStatus.menunggu,
    IncomingOrderStatus.sedangPickup => LaundryStatus.menunggu,
    IncomingOrderStatus.sedangDicuci => LaundryStatus.dicuci,
    IncomingOrderStatus.sedangDikeringkan => LaundryStatus.dikeringkan,
    IncomingOrderStatus.sedangDisetrika => LaundryStatus.disetrika,
    IncomingOrderStatus.qualityCheck => LaundryStatus.disetrika,
    IncomingOrderStatus.siapDiambil => LaundryStatus.readyPickup,
    IncomingOrderStatus.sedangDelivery => LaundryStatus.selesai,
    IncomingOrderStatus.selesai => LaundryStatus.selesai,
  };
}

ServiceType _toServiceType(LaundryServiceType service) {
  return switch (service) {
    LaundryServiceType.regular => ServiceType.regular,
    LaundryServiceType.express => ServiceType.express,
    LaundryServiceType.bedCover => ServiceType.premium,
    LaundryServiceType.ironOnly => ServiceType.regular,
  };
}

PickupDeliveryType _toPickupDelivery(FulfillmentType type) {
  return switch (type) {
    FulfillmentType.selfPickup => PickupDeliveryType.datangSendiri,
    FulfillmentType.pickup => PickupDeliveryType.jemput,
    FulfillmentType.delivery => PickupDeliveryType.antar,
  };
}

OrderPaymentMethod _toTodayPaymentMethod(String? method) {
  switch (method?.toUpperCase()) {
    case 'QRIS':
      return OrderPaymentMethod.qris;
    case 'BANK_TRANSFER':
    case 'TRANSFER':
      return OrderPaymentMethod.transfer;
    default:
      return OrderPaymentMethod.cash;
  }
}
