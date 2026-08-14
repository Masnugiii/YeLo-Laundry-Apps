import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_activity_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_activity_tile.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_section_title.dart';

class DashboardActivitySection extends ConsumerWidget {
  const DashboardActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(dashboardActivityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PosSectionTitle(
          title: 'Aktivitas Hari Ini',
          actionLabel: 'Lihat Semua',
          onActionTap: () => context.push('/activities/today'),
        ),
        const SizedBox(height: AppSpacing.s16),
        activityAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (_, _) => Text(
            'Gagal memuat aktivitas terbaru.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Text(
                'Belum ada aktivitas hari ini',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              );
            }

            return Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  PosActivityTile(
                    orderNumber: items[i].orderNumber,
                    customerName: items[i].customerName,
                    service: items[i].service,
                    status: items[i].status,
                    statusColor: items[i].statusColor,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
