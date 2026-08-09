import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';

Future<void> showWalletTopUpProcessingDialog(BuildContext context) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const _WalletTopUpProcessingDialog(),
  );

  await Future<void>.delayed(const Duration(seconds: 2));

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _WalletTopUpProcessingDialog extends StatelessWidget {
  const _WalletTopUpProcessingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Text(
              'Memproses transaksi...',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
