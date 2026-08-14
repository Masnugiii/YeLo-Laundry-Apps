import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_confirmation.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_success_action_button.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_top_up_review_summary_card.dart';
import 'package:yelo_laundry_erp/shared/widgets/erp_app_bar.dart';
import 'package:yelo_laundry_erp/shared/widgets/flow_exit_scope.dart';

class WalletTopUpSuccessScreen extends StatelessWidget {
  const WalletTopUpSuccessScreen({
    super.key,
    required this.confirmation,
  });

  final WalletTopUpConfirmation confirmation;

  void _finish(BuildContext context) {
    context.go('/customers/${confirmation.customerId}');
  }

  @override
  Widget build(BuildContext context) {
    return FlowExitScope(
      onExit: () => _finish(context),
      child: Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        appBar: ErpAppBar(
          title: 'Top Up Berhasil',
          onBack: () => _finish(context),
        ),
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
                      'Top Up Berhasil',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s32),
                    WalletTopUpSuccessSummaryCard(confirmation: confirmation),
                    const SizedBox(height: AppSpacing.s24),
                    WalletSuccessActionButton(
                      label: 'Cetak Struk',
                      backgroundColor: AppColors.primary,
                      textColor: AppColors.onPrimary,
                      onPressed: () => context.push(
                        '/wallet-top-up/receipt',
                        extra: confirmation,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    WalletSuccessActionButton(
                      label: 'Bagikan Struk ke WhatsApp',
                      backgroundColor: const Color(0xFF25D366),
                      textColor: AppColors.onPrimary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              'Membuka WhatsApp untuk membagikan struk...',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
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
                  onPressed: () => _finish(context),
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
    ),
    );
  }
}
