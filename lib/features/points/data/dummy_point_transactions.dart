import 'package:yelo_laundry_erp/features/points/models/point_transaction.dart';

final dummyPointTransactions = <PointTransaction>[
  PointTransaction(
    id: 'pt-001',
    customerId: 'cust-006',
    date: DateTime(2026, 8, 7),
    points: 25,
    source: PointSource.orderLaundry,
    referenceNumber: 'ORD-20260807-00024',
    description: 'Order Cuci Kering Setrika',
  ),
  PointTransaction(
    id: 'pt-002',
    customerId: 'cust-006',
    date: DateTime(2026, 8, 5),
    points: 50,
    source: PointSource.topUpDompet,
    referenceNumber: 'TOP-20260805-00018',
    description: 'Top up dompet Rp500.000',
  ),
  PointTransaction(
    id: 'pt-003',
    customerId: 'cust-006',
    date: DateTime(2026, 8, 3),
    points: 100,
    source: PointSource.promoMember,
    referenceNumber: 'PRM-20260803-00007',
    description: 'Promo member akhir pekan',
  ),
  PointTransaction(
    id: 'pt-004',
    customerId: 'cust-006',
    date: DateTime(2026, 7, 28),
    points: 200,
    source: PointSource.bonusUlangTahun,
    referenceNumber: 'BDY-20260728-00001',
    description: 'Bonus ulang tahun pelanggan',
  ),
  PointTransaction(
    id: 'pt-005',
    customerId: 'cust-006',
    date: DateTime(2026, 7, 20),
    points: 75,
    source: PointSource.referral,
    referenceNumber: 'REF-20260720-00012',
    description: 'Referral pelanggan baru',
  ),
  PointTransaction(
    id: 'pt-006',
    customerId: 'cust-006',
    date: DateTime(2026, 7, 15),
    points: 30,
    source: PointSource.orderLaundry,
    referenceNumber: 'ORD-20260715-00019',
    description: 'Order Cuci Basah Reguler',
  ),
  PointTransaction(
    id: 'pt-007',
    customerId: 'cust-006',
    date: DateTime(2026, 7, 10),
    points: 15,
    source: PointSource.manualAdjustment,
    referenceNumber: 'ADJ-20260710-00003',
    description: 'Penyesuaian point oleh admin',
  ),
  PointTransaction(
    id: 'pt-008',
    customerId: 'cust-001',
    date: DateTime(2026, 8, 6),
    points: 20,
    source: PointSource.orderLaundry,
    referenceNumber: 'ORD-20260806-00021',
    description: 'Order Cuci Kering Setrika',
  ),
  PointTransaction(
    id: 'pt-009',
    customerId: 'cust-001',
    date: DateTime(2026, 8, 1),
    points: 40,
    source: PointSource.topUpDompet,
    referenceNumber: 'TOP-20260801-00009',
    description: 'Top up dompet Rp150.000',
  ),
  PointTransaction(
    id: 'pt-010',
    customerId: 'cust-002',
    date: DateTime(2026, 8, 4),
    points: 35,
    source: PointSource.orderLaundry,
    referenceNumber: 'ORD-20260804-00016',
    description: 'Order Cuci Basah Express',
  ),
  PointTransaction(
    id: 'pt-011',
    customerId: 'cust-002',
    date: DateTime(2026, 7, 25),
    points: 80,
    source: PointSource.promoMember,
    referenceNumber: 'PRM-20260725-00005',
    description: 'Promo member bulan Juli',
  ),
  PointTransaction(
    id: 'pt-012',
    customerId: 'cust-004',
    date: DateTime(2026, 8, 2),
    points: 45,
    source: PointSource.orderLaundry,
    referenceNumber: 'ORD-20260802-00014',
    description: 'Order Setrika Saja',
  ),
];

List<PointTransaction> pointTransactionsForCustomer(String customerId) {
  return dummyPointTransactions
      .where((transaction) => transaction.customerId == customerId)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}
