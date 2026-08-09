import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/wallet/data/dummy_wallet_deduction_receipt.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_deduction_receipt.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_payment_confirmation.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_deduction_review_summary_card.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_deduction_whatsapp_share_dialog.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_success_action_button.dart';

class WalletPaymentSuccessScreen extends StatelessWidget {
  const WalletPaymentSuccessScreen({
    super.key,
    required this.confirmation,
  });

  final WalletPaymentConfirmation confirmation;

  WalletDeductionReceipt get _receipt =>
      walletDeductionReceiptFromConfirmation(confirmation);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  AppSpacing.s32,
                  AppSpacing.s20,
                  AppSpacing.s20,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 56,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    Text(
                      'Pengurangan Saldo Berhasil',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s32),
                    WalletDeductionSuccessSummaryCard(
                      confirmation: confirmation,
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    WalletSuccessActionButton(
                      label: 'Cetak Struk',
                      backgroundColor: AppColors.primary,
                      textColor: AppColors.onPrimary,
                      onPressed: () => context.push(
                        '/wallet-deduction/receipt',
                        extra: confirmation,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    WalletSuccessActionButton(
                      label: 'Bagikan Struk ke WhatsApp',
                      backgroundColor: const Color(0xFF25D366),
                      textColor: AppColors.onPrimary,
                      onPressed: () => showWalletDeductionWhatsappShareDialog(
                        context,
                        receipt: _receipt,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s12,
                AppSpacing.s20,
                AppSpacing.s24,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    context.go('/customers/${confirmation.customerId}');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Selesai',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
