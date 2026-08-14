import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/catalog/data/laundry_perfume_option.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class PerfumeSelectionCard extends StatelessWidget {
  const PerfumeSelectionCard({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  final List<LaundryPerfumeOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

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

  @override
  Widget build(BuildContext context) {
    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.spa_outlined,
                size: 18,
                color: AppColors.brandBlue,
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'Pilihan Parfum',
                style: _poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          if (options.length <= 1)
            Text(
              'Pilihan parfum belum tersedia dari server. Pesanan akan diproses tanpa parfum.',
              style: _poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          for (final option in options) ...[
            RadioListTile<String>(
              value: option.id,
              groupValue: selectedId,
              onChanged: (value) {
                if (value == null) return;
                onSelected(value);
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.brandBlue,
              title: Text(option.name, style: _poppins(fontSize: 14)),
              subtitle: option.hasExtraPrice
                  ? Text(
                      option.priceLabel,
                      style: _poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
