import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_method.dart';
import 'package:yelo_laundry_customer/features/pickup/models/customer_payment_config.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class PaymentMethodSelectionCard extends StatelessWidget {
  const PaymentMethodSelectionCard({
    super.key,
    required this.selectedCode,
    required this.onSelected,
    required this.paymentConfig,
    this.walletBalance,
    this.orderTotal = 0,
    this.allowedMethodCodes,
  });

  final String selectedCode;
  final ValueChanged<String> onSelected;
  final CustomerPaymentConfig paymentConfig;
  final double? walletBalance;
  final int orderTotal;
  final List<String>? allowedMethodCodes;

  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  bool get _walletInsufficient {
    if (selectedCode != CheckoutPaymentMethods.yeloWallet) return false;
    return (walletBalance ?? 0) < orderTotal;
  }

  List<String> get _visibleMethods {
    final available = paymentConfig.availableMethodCodes.toSet();
    final allowed = allowedMethodCodes?.toSet();
    return CheckoutPaymentMethods.all
        .where((code) => available.contains(code))
        .where((code) => allowed == null || allowed.contains(code))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final methods = _visibleMethods;

    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Metode Pembayaran',
            style: _poppins(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.s12),
          if (methods.isEmpty)
            Text(
              'Metode pembayaran belum tersedia. Hubungi outlet.',
              style: _poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
          for (final code in methods) ...[
            _methodTile(code),
            if (code != methods.last) const SizedBox(height: AppSpacing.s8),
          ],
          if (_walletInsufficient) ...[
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Saldo tidak cukup',
              style: _poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _methodTile(String code) {
    final isSelected = selectedCode == code;
    final accent = AppColors.accent;

    String detail;
    if (code == CheckoutPaymentMethods.yeloWallet) {
      detail = 'Saldo tersedia: ${_currency.format(walletBalance ?? 0)}';
    } else {
      detail = CheckoutPaymentMethods.subtitle(code);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(code),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accent : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? accent.withValues(alpha: 0.12) : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CheckoutPaymentMethods.label(code),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.brandBlue : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
