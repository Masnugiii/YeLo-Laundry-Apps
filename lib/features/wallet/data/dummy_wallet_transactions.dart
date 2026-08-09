import 'package:yelo_laundry_erp/features/wallet/models/wallet_transaction.dart';

const walletDeductionReasons = [
  'Pembayaran Laundry',
  'Refund',
  'Penyesuaian Saldo',
  'Kesalahan Input',
  'Lainnya',
];

final dummyWalletTransactions = <WalletTransaction>[
  WalletTransaction(
    id: 'wlt-001',
    customerId: 'cust-004',
    date: DateTime(2026, 8, 7, 14, 30),
    type: WalletTransactionType.payment,
    amount: -65000,
    balanceAfter: 185000,
    note: 'Pembayaran Order A-023',
    adminName: 'Kasir - Andi',
    deductionReason: 'Pembayaran Laundry',
  ),
  WalletTransaction(
    id: 'wlt-002',
    customerId: 'cust-004',
    date: DateTime(2026, 8, 6, 10, 15),
    type: WalletTransactionType.topUp,
    amount: 100000,
    balanceAfter: 250000,
    note: 'Top Up Awal',
  ),
  WalletTransaction(
    id: 'wlt-003',
    customerId: 'cust-004',
    date: DateTime(2026, 8, 4, 16, 45),
    type: WalletTransactionType.refund,
    amount: 35000,
    balanceAfter: 150000,
    note: 'Refund Order B-012',
  ),
  WalletTransaction(
    id: 'wlt-004',
    customerId: 'cust-004',
    date: DateTime(2026, 8, 2, 9, 0),
    type: WalletTransactionType.topUp,
    amount: 150000,
    balanceAfter: 115000,
    note: 'Bonus Member',
  ),
  WalletTransaction(
    id: 'wlt-005',
    customerId: 'cust-004',
    date: DateTime(2026, 7, 28, 11, 20),
    type: WalletTransactionType.adjustment,
    amount: -15000,
    balanceAfter: 0,
    note: 'Penyesuaian saldo awal',
  ),
  WalletTransaction(
    id: 'wlt-006',
    customerId: 'cust-001',
    date: DateTime(2026, 8, 5, 13, 0),
    type: WalletTransactionType.topUp,
    amount: 100000,
    balanceAfter: 150000,
    note: 'Deposit Laundry',
  ),
  WalletTransaction(
    id: 'wlt-007',
    customerId: 'cust-001',
    date: DateTime(2026, 8, 3, 15, 30),
    type: WalletTransactionType.payment,
    amount: -50000,
    balanceAfter: 50000,
    note: 'Pembayaran Order A-001',
  ),
  WalletTransaction(
    id: 'wlt-008',
    customerId: 'cust-001',
    date: DateTime(2026, 8, 1, 9, 45),
    type: WalletTransactionType.topUp,
    amount: 100000,
    balanceAfter: 100000,
    note: 'Top Up Awal',
  ),
  WalletTransaction(
    id: 'wlt-009',
    customerId: 'cust-006',
    date: DateTime(2026, 8, 7, 8, 0),
    type: WalletTransactionType.topUp,
    amount: 200000,
    balanceAfter: 500000,
    note: 'Deposit Laundry',
  ),
  WalletTransaction(
    id: 'wlt-010',
    customerId: 'cust-006',
    date: DateTime(2026, 8, 6, 17, 15),
    type: WalletTransactionType.payment,
    amount: -88000,
    balanceAfter: 300000,
    note: 'Pembayaran Order F-003',
  ),
];

List<WalletTransaction> walletTransactionsForCustomer(String customerId) {
  return dummyWalletTransactions
      .where((transaction) => transaction.customerId == customerId)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}
