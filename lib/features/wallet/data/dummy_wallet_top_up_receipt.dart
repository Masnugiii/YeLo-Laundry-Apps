import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_confirmation.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_receipt.dart';

const dummyWalletTopUpReceipt = WalletTopUpReceipt(
  transactionNumber: 'WU-20260808-00001',
  transactionDate: '08 Agustus 2026',
  transactionTime: '10:15 WIB',
  customerName: 'Andi Saputra',
  phoneNumber: '081234567890',
  balanceBefore: 150000,
  topUpAmount: 200000,
  balanceAfter: 350000,
  paymentMethod: 'Cash',
  paymentStatus: 'Lunas',
  adminName: 'Nugroho',
);

WalletTopUpReceipt walletTopUpReceiptFromConfirmation(
  WalletTopUpConfirmation confirmation,
) {
  return WalletTopUpReceipt.fromConfirmation(confirmation);
}
