import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_payment_confirmation.dart';

class WalletDeductionProcessingScreen extends StatefulWidget {
  const WalletDeductionProcessingScreen({
    super.key,
    required this.confirmation,
  });

  final WalletPaymentConfirmation confirmation;

  @override
  State<WalletDeductionProcessingScreen> createState() =>
      _WalletDeductionProcessingScreenState();
}

class _WalletDeductionProcessingScreenState
    extends State<WalletDeductionProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _processDeduction();
  }

  Future<void> _processDeduction() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    context.replace('/wallet-payment-success', extra: widget.confirmation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              Text(
                'Memproses pengurangan saldo...',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
