import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/promo/models/customer_promo.dart';
import 'package:yelo_laundry_customer/features/promo/presentation/widgets/promo_percentage_badge.dart';

class PromoCard extends StatelessWidget {
  const PromoCard({
    super.key,
    required this.promo,
    required this.onTap,
    this.onUse,
  });

  final CustomerPromo promo;
  final VoidCallback onTap;
  final VoidCallback? onUse;

  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  String? _expiryLabel(DateTime? expiresAt) {
    if (expiresAt == null) return null;
    return 'Berlaku sampai ${DateFormat('d MMMM yyyy', 'id_ID').format(expiresAt.toLocal())}';
  }

  double _minCardHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.38).clamp(168.0, 192.0);
  }

  @override
  Widget build(BuildContext context) {
    final expiry = _expiryLabel(promo.expiresAt);
    final badgePercent = promo.discountPercent;
    final hasBanner =
        promo.bannerUrl != null && promo.bannerUrl!.trim().isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _PromoCardShell(
          minHeight: _minCardHeight(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: badgePercent != null ? AppSpacing.s12 : AppSpacing.s4,
                    right: badgePercent != null ? 44 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasBanner) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            promo.bannerUrl!,
                            height: 96,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                      ],
                      Text(
                        promo.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (promo.description.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          promo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (promo.minTransaction != null) ...[
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          'Min. transaksi ${_currency.format(promo.minTransaction)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (expiry != null) ...[
                        const SizedBox(height: AppSpacing.s12),
                        Text(
                          expiry,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (onUse != null && promo.isUsable) ...[
                const SizedBox(height: AppSpacing.s16),
                Align(
                  alignment: Alignment.centerRight,
                  child: _UsePromoCta(onPressed: onUse!),
                ),
              ],
            ],
          ),
        ),
        if (badgePercent != null)
          Positioned(
            top: -10,
            right: -6,
            child: PromoPercentageBadge(percentage: badgePercent),
          ),
      ],
    );
  }
}

class _PromoCardShell extends StatelessWidget {
  const _PromoCardShell({
    required this.child,
    required this.minHeight,
  });

  final Widget child;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s20,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _UsePromoCta extends StatelessWidget {
  const _UsePromoCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.onAccent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s8,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        splashFactory: InkRipple.splashFactory,
      ),
      child: Text(
        'Gunakan Promo →',
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.onAccent,
          height: 1.2,
        ),
      ),
    );
  }
}
