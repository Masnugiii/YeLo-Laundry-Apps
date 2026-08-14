import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/new_order_section_card.dart';
import 'package:yelo_laundry_erp/features/points/models/yelo_rewards_models.dart';

class CksBenefitSection extends StatelessWidget {
  const CksBenefitSection({
    super.key,
    required this.entitlements,
    required this.selectedId,
    required this.onSelected,
    required this.freeKg,
    required this.billableKg,
    required this.hasCksService,
    this.isLoading = false,
  });

  final List<CksEntitlement> entitlements;
  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final double freeKg;
  final double billableKg;
  final bool hasCksService;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!hasCksService && entitlements.isEmpty) {
      return const SizedBox.shrink();
    }

    return NewOrderSectionCard(
      title: 'YeLo Rewards / Benefit',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (entitlements.isEmpty)
            Text(
              hasCksService
                  ? 'Tidak ada CKS entitlement aktif untuk pelanggan ini.'
                  : 'Tambahkan layanan CKS untuk memakai entitlement.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          else ...[
            for (final entitlement in entitlements)
              InkWell(
                onTap: hasCksService
                    ? () => onSelected(entitlement.redemptionItemId)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.s8),
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedId == entitlement.redemptionItemId
                          ? AppColors.primary
                          : AppColors.divider,
                      width: selectedId == entitlement.redemptionItemId
                          ? 1.5
                          : 1,
                    ),
                    color: selectedId == entitlement.redemptionItemId
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : Colors.transparent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entitlement.rewardName} tersedia',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sisa ${_formatKg(entitlement.remainingKg)} KG'
                        '${entitlement.expiresAt == null ? '' : ' · Exp ${_formatDate(entitlement.expiresAt!)}'}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            TextButton(
              onPressed: selectedId == null ? null : () => onSelected(null),
              child: const Text('Hapus benefit'),
            ),
            if (selectedId != null && hasCksService) ...[
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Gratis: ${_formatKg(freeKg)} KG',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Dibayar: ${_formatKg(billableKg)} KG',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static String _formatKg(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
