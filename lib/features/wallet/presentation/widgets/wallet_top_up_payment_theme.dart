import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';

abstract final class WalletTopUpPaymentTheme {
  static const cardRadius = BorderRadius.all(Radius.circular(20));

  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: cardRadius,
    boxShadow: AppShadows.md(),
  );

  static TextStyle titleStyle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle labelStyle = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle valueStyle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static ButtonStyle primaryButtonStyle = FilledButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

  static TextStyle primaryButtonTextStyle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}

class WalletTopUpPaymentCard extends StatelessWidget {
  const WalletTopUpPaymentCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: WalletTopUpPaymentTheme.cardDecoration,
      child: child,
    );
  }
}

class WalletTopUpPaymentInfoRow extends StatelessWidget {
  const WalletTopUpPaymentInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: WalletTopUpPaymentTheme.labelStyle),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: WalletTopUpPaymentTheme.valueStyle.copyWith(
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
              color: emphasized ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class WalletTopUpPaymentDivider extends StatelessWidget {
  const WalletTopUpPaymentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }
}

class WalletTopUpPaymentStatusBadge extends StatelessWidget {
  const WalletTopUpPaymentStatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
