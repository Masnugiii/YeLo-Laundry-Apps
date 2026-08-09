import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';

class PosOperationalSummaryRow extends StatelessWidget {
  const PosOperationalSummaryRow({
    super.key,
    required this.items,
  });

  final List<PosOperationalSummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _OperationalCard(data: items[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class PosOperationalSummaryItem {
  const PosOperationalSummaryItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}

class _OperationalCard extends StatelessWidget {
  const _OperationalCard({required this.data});

  final PosOperationalSummaryItem data;

  static const _cardRadius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _cardRadius,
        boxShadow: AppShadows.md(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            data.value,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              data.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
