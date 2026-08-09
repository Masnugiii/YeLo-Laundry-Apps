import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_deduction_receipt.dart';

String buildWalletDeductionWhatsappMessage(WalletDeductionReceipt receipt) {
  return 'Halo ${receipt.customerName},\n\n'
      'Pengurangan saldo Yelo Wallet telah berhasil diproses.\n\n'
      'Nomor Transaksi:\n'
      '${receipt.transactionNumber}\n\n'
      'Nominal Dipotong:\n'
      '${formatRupiah(receipt.deductionAmount)}\n\n'
      'Saldo Sebelum:\n'
      '${formatRupiah(receipt.balanceBefore)}\n\n'
      'Saldo Sesudah:\n'
      '${formatRupiah(receipt.balanceAfter)}\n\n'
      'Terima kasih telah menggunakan Yelo Laundry.';
}

class WalletDeductionWhatsappReceiptPreview extends StatelessWidget {
  const WalletDeductionWhatsappReceiptPreview({
    super.key,
    required this.receipt,
  });

  final WalletDeductionReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: const Color(0xFFECE5DD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF25D366).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        buildWalletDeductionWhatsappMessage(receipt),
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }
}
