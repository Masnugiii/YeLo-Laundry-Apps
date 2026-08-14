import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_page_header.dart';
import 'package:yelo_laundry_customer/features/help/data/help_center_content.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class HelpPaymentScreen extends StatelessWidget {
  const HelpPaymentScreen({super.key});

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

  Widget _buildFaqList(BuildContext context) {
    final items = HelpCenterContent.paymentFaqs;

    return PickupDashboardCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: AppColors.divider,
          splashColor: AppColors.brandBlue.withValues(alpha: 0.08),
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s4,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  0,
                  AppSpacing.s16,
                  AppSpacing.s12,
                ),
                iconColor: AppColors.brandBlue,
                collapsedIconColor: AppColors.textSecondary,
                title: Text(
                  items[i].question,
                  style: _poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      items[i].answer,
                      style: _poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (i < items.length - 1)
                const Divider(height: 1, color: AppColors.divider),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const DashboardPageHeader(title: 'Bantuan Pembayaran'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s24,
              ),
              children: [
                Text(
                  'Temukan jawaban seputar pembayaran pesanan laundry di Yelo.',
                  style: _poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                _buildFaqList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
