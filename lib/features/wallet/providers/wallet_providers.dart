import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/wallet/data/wallet_repository.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_transaction.dart';

WalletTransactionType _mapWalletTransactionType(String? type) {
  switch (type?.toUpperCase()) {
    case 'TOPUP':
      return WalletTransactionType.topUp;
    case 'PAYMENT':
    case 'DEDUCTION':
      return WalletTransactionType.payment;
    case 'REFUND':
      return WalletTransactionType.refund;
    default:
      return WalletTransactionType.adjustment;
  }
}

WalletTransaction mapWalletTransaction(
  Map<String, dynamic> json,
  String customerId,
) {
  final type = _mapWalletTransactionType(json['type'] as String?);
  final rawAmount = (json['amount'] as num?)?.toDouble() ?? 0;
  final signedAmount = switch (type) {
    WalletTransactionType.payment => -rawAmount.round(),
    WalletTransactionType.adjustment when rawAmount < 0 => rawAmount.round(),
    _ => rawAmount.round(),
  };
  final createdBy = json['createdByEmployee'] as Map<String, dynamic>?;

  return WalletTransaction(
    id: json['id'] as String? ?? '',
    customerId: customerId,
    date: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now(),
    type: type,
    amount: signedAmount,
    balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
    note: json['notes'] as String?,
    adminName: createdBy?['fullName'] as String?,
    deductionReason: type == WalletTransactionType.payment
        ? json['notes'] as String?
        : null,
  );
}

final customerWalletProvider =
    FutureProvider.family<CustomerWalletSummary, String>((ref, customerId) {
  return ref.watch(walletRepositoryProvider).fetchCustomerWallet(customerId);
});

final walletTransactionsProvider =
    FutureProvider.family<List<WalletTransaction>, String>((ref, customerId) {
  return ref
      .watch(walletRepositoryProvider)
      .fetchTransactions(customerId)
      .then(
        (items) => items
            .map((item) => mapWalletTransaction(item, customerId))
            .toList(),
      );
});
