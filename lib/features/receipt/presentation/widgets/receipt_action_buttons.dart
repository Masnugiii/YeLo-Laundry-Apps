import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';

class ReceiptActionButtons extends StatelessWidget {
  const ReceiptActionButtons({
    super.key,
    required this.onPrint,
    required this.onShareWhatsApp,
    required this.onSavePdf,
  });

  final VoidCallback onPrint;
  final VoidCallback onShareWhatsApp;
  final VoidCallback onSavePdf;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _ActionButton(
            label: 'Cetak Struk',
            backgroundColor: AppColors.primary,
            textColor: AppColors.onPrimary,
            onPressed: onPrint,
          ),
          const SizedBox(height: AppSpacing.s12),
          _ActionButton(
            label: 'Bagikan ke WhatsApp',
            backgroundColor: const Color(0xFF25D366),
            textColor: AppColors.onPrimary,
            onPressed: onShareWhatsApp,
          ),
          const SizedBox(height: AppSpacing.s12),
          _ActionButton(
            label: 'Simpan PDF',
            backgroundColor: AppColors.surface,
            textColor: AppColors.primary,
            borderColor: AppColors.primary,
            onPressed: onSavePdf,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 1.5)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
