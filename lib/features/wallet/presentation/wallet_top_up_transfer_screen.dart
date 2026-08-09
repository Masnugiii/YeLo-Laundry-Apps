import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/wallet/data/dummy_wallet_bank_account.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_confirmation.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_top_up_payment_theme.dart';

class WalletTopUpTransferScreen extends StatelessWidget {
  const WalletTopUpTransferScreen({
    super.key,
    required this.confirmation,
  });

  final WalletTopUpConfirmation confirmation;

  void _copyAccountNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: dummyWalletAccountNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Nomor rekening berhasil disalin.',
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _continueToConfirmation(BuildContext context) {
    context.push('/wallet-top-up/review', extra: confirmation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Transfer Bank',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              children: [
                WalletTopUpPaymentCard(
                  child: Column(
                    children: [
                      WalletTopUpPaymentInfoRow(
                        label: 'Bank Name',
                        value: dummyWalletBankName,
                      ),
                      const WalletTopUpPaymentDivider(),
                      WalletTopUpPaymentInfoRow(
                        label: 'Account Number',
                        value: dummyWalletAccountNumber,
                        emphasized: true,
                      ),
                      const WalletTopUpPaymentDivider(),
                      WalletTopUpPaymentInfoRow(
                        label: 'Account Holder',
                        value: dummyWalletAccountHolder,
                      ),
                      const WalletTopUpPaymentDivider(),
                      WalletTopUpPaymentInfoRow(
                        label: 'Payment Amount',
                        value: formatRupiah(confirmation.topUpAmount),
                        emphasized: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s12,
              AppSpacing.s20,
              AppSpacing.s24,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () => _copyAccountNumber(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Salin Nomor Rekening',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                FilledButton(
                  onPressed: () => _continueToConfirmation(context),
                  style: WalletTopUpPaymentTheme.primaryButtonStyle,
                  child: Text(
                    'Saya Sudah Menerima Pembayaran',
                    style: WalletTopUpPaymentTheme.primaryButtonTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
