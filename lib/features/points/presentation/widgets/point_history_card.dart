import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/points/models/point_transaction.dart';

class PointHistoryCard extends StatelessWidget {
  const PointHistoryCard({
    super.key,
    required this.transaction,
  });

  final PointTransaction transaction;

  static const _cardRadius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    final accentColor = transaction.source.accentBarColor;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _cardRadius,
        boxShadow: AppShadows.md(),
      ),
      child: ClipRRect(
        borderRadius: _cardRadius,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: accentColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Field(
                        label: 'Tanggal',
                        value: transaction.formattedDate,
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _Field(
                        label: 'Point Diperoleh',
                        value: transaction.formattedPoints,
                        valueColor: const Color(0xFF16A34A),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _Field(
                        label: 'Sumber Point',
                        value: transaction.source.label,
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _Field(
                        label: 'Nomor Referensi',
                        value: transaction.referenceNumber,
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _Field(
                        label: 'Keterangan',
                        value: transaction.description,
                      ),
                    ],
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
