import 'package:yelo_laundry_erp/features/wallet/models/wallet_deduction_receipt.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_payment_confirmation.dart';

const dummyWalletDeductionReceipt = WalletDeductionReceipt(
  transactionNumber: 'WD-20260808-00001',
  transactionDate: '08 Agustus 2026',
  transactionTime: '10:15 WIB',
  customerName: 'Andi Saputra',
  phoneNumber: '081234567890',
  balanceBefore: 350000,
  deductionAmount: 75000,
  balanceAfter: 275000,
  reason: 'Pembayaran Laundry',
  relatedOrder: 'YL-004288',
  cashierName: 'Nugroho',
);

WalletDeductionReceipt walletDeductionReceiptFromConfirmation(
  WalletPaymentConfirmation confirmation,
) {
  return WalletDeductionReceipt.fromConfirmation(confirmation);
}
