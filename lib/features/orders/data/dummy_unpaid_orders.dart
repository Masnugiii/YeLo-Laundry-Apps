import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/orders/models/unpaid_order.dart';

List<UnpaidOrder> dummyUnpaidOrders() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return [
    UnpaidOrder(
      id: 'unpaid-001',
      customerName: 'Andi Saputra',
      customerPhone: '+6281234567890',
      queueNumber: 'A-023',
      invoiceNumber: 'YL-000043',
      service: UnpaidServiceType.regular,
      weightKg: 4.5,
      quantityPcs: 12,
      totalAmount: 65000,
      paymentStatus: UnpaidPaymentStatus.belumDibayar,
      fulfillment: UnpaidFulfillmentType.pickup,
      receivedAt: today.subtract(const Duration(days: 3)),
      estimatedCompletion: today,
      binatuPic: 'Siti Aminah',
      lateDays: 2,
      lateFee: 10000,
    ),
    UnpaidOrder(
      id: 'unpaid-002',
      customerName: 'Siti Rahayu',
      customerPhone: '+6289876543210',
      queueNumber: 'A-024',
      invoiceNumber: 'YL-000044',
      service: UnpaidServiceType.express,
      weightKg: 6.0,
      quantityPcs: 18,
      totalAmount: 90000,
      paymentStatus: UnpaidPaymentStatus.belumDibayar,
      fulfillment: UnpaidFulfillmentType.delivery,
      receivedAt: today.subtract(const Duration(days: 1)),
      estimatedCompletion: today.add(const Duration(days: 1)),
      deliveryDate: today.add(const Duration(days: 2)),
      binatuPic: 'Budi Santoso',
      lateDays: 0,
      lateFee: 0,
    ),
    UnpaidOrder(
      id: 'unpaid-003',
      customerName: 'Budi Santoso',
      customerPhone: '+6281122334455',
      queueNumber: 'A-025',
      invoiceNumber: 'YL-000045',
      service: UnpaidServiceType.bedCover,
      weightKg: 3.2,
      quantityPcs: 4,
      totalAmount: 120000,
      paymentStatus: UnpaidPaymentStatus.belumDibayar,
      fulfillment: UnpaidFulfillmentType.selfPickup,
      receivedAt: today.subtract(const Duration(days: 2)),
      estimatedCompletion: today.subtract(const Duration(days: 1)),
      binatuPic: 'Rina Wulandari',
      lateDays: 1,
      lateFee: 5000,
    ),
    UnpaidOrder(
      id: 'unpaid-004',
      customerName: 'Rina Wulandari',
      customerPhone: '+6285566778899',
      queueNumber: 'A-026',
      invoiceNumber: 'YL-000046',
      service: UnpaidServiceType.regular,
      weightKg: 5.8,
      quantityPcs: 15,
      totalAmount: 105000,
      paymentStatus: UnpaidPaymentStatus.belumDibayar,
      fulfillment: UnpaidFulfillmentType.pickup,
      receivedAt: today.subtract(const Duration(days: 1)),
      estimatedCompletion: today.add(const Duration(days: 2)),
      binatuPic: 'Dewi Lestari',
      lateDays: 0,
      lateFee: 0,
    ),
    UnpaidOrder(
      id: 'unpaid-005',
      customerName: 'Dewi Lestari',
      customerPhone: '+6287788990011',
      queueNumber: 'A-027',
      invoiceNumber: 'YL-000047',
      service: UnpaidServiceType.express,
      weightKg: 7.0,
      quantityPcs: 22,
      totalAmount: 120000,
      paymentStatus: UnpaidPaymentStatus.belumDibayar,
      fulfillment: UnpaidFulfillmentType.delivery,
      receivedAt: today.subtract(const Duration(days: 5)),
      estimatedCompletion: today.subtract(const Duration(days: 2)),
      deliveryDate: today,
      binatuPic: 'Andi Saputra',
      lateDays: 4,
      lateFee: 15000,
    ),
    UnpaidOrder(
      id: 'unpaid-006',
      customerName: 'John Anderson',
      customerPhone: '+6283344556677',
      queueNumber: 'A-028',
      invoiceNumber: 'YL-000048',
      service: UnpaidServiceType.ironOnly,
      weightKg: 2.5,
      quantityPcs: 8,
      totalAmount: 50000,
      paymentStatus: UnpaidPaymentStatus.belumDibayar,
      fulfillment: UnpaidFulfillmentType.selfPickup,
      receivedAt: today,
      estimatedCompletion: today,
      binatuPic: 'Siti Aminah',
      lateDays: 0,
      lateFee: 0,
    ),
  ];
}

UnpaidOrdersSummary computeUnpaidOrdersSummary(List<UnpaidOrder> orders) {
  return UnpaidOrdersSummary(
    totalOrders: orders.length,
    totalReceivable: orders.fold(0, (sum, order) => sum + order.totalAmount),
    dueTodayCount: orders.where((order) => order.isDueToday).length,
    latePickupCount: orders.where((order) => order.isOverdue).length,
  );
}

List<UnpaidOrder> filterUnpaidOrders({
  required List<UnpaidOrder> orders,
  required String query,
  required UnpaidOrderFilter filter,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  return orders.where((order) {
    final matchesQuery = normalizedQuery.isEmpty ||
        order.customerName.toLowerCase().contains(normalizedQuery) ||
        order.queueNumber.toLowerCase().contains(normalizedQuery) ||
        order.invoiceNumber.toLowerCase().contains(normalizedQuery) ||
        order.customerPhone.toLowerCase().contains(normalizedQuery);

    if (!matchesQuery) return false;

    return switch (filter) {
      UnpaidOrderFilter.semua => true,
      UnpaidOrderFilter.belumDibayar =>
        order.paymentStatus == UnpaidPaymentStatus.belumDibayar,
      UnpaidOrderFilter.terlambatDiambil => order.isOverdue,
      UnpaidOrderFilter.pickup => order.hasPickup,
      UnpaidOrderFilter.delivery => order.hasDelivery,
    };
  }).toList();
}

List<UnpaidOrder> sortUnpaidOrders({
  required List<UnpaidOrder> orders,
  required UnpaidOrderSort sort,
}) {
  final sorted = [...orders];

  sorted.sort((a, b) {
    return switch (sort) {
      UnpaidOrderSort.tanggalMasuk => b.receivedAt.compareTo(a.receivedAt),
      UnpaidOrderSort.nomorAntrian =>
        a.queueNumber.compareTo(b.queueNumber),
      UnpaidOrderSort.namaCustomer =>
        a.customerName.compareTo(b.customerName),
      UnpaidOrderSort.nilaiTagihan =>
        b.totalAmount.compareTo(a.totalAmount),
      UnpaidOrderSort.jumlahDenda => b.lateFee.compareTo(a.lateFee),
    };
  });

  return sorted;
}

String formatUnpaidOrderDate(DateTime dateTime) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = months[dateTime.month - 1];
  return '$day $month ${dateTime.year}';
}

String formatUnpaidOrderDateTime(DateTime dateTime) {
  final date = formatUnpaidOrderDate(dateTime);
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$date\n$hour:$minute WIB';
}

String formatUnpaidAmount(int amount) => formatRupiah(amount);
