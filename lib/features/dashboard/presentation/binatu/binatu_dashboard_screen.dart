import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_header.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/binatu_attendance_screen.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_status.dart';
import 'package:yelo_laundry_erp/features/binatu/presentation/binatu_ironing_queue_screen.dart';
import 'package:yelo_laundry_erp/features/binatu/presentation/binatu_settings_screen.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_dashboard_badge_provider.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_order_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/operational_summary_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_menu_card.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_section_title.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/role_dashboard_shell.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/stat_card.dart';

/// Binatu (ironing staff) dashboard — ironing operations only.
class BinatuDashboardScreen extends ConsumerWidget {
  const BinatuDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleDashboardShell(
      key: const ValueKey('binatu-dashboard'),
      role: UserRole.laundry,
      backgroundColor: AppColors.dashboardBackground,
      pages: [
        const _BinatuHomePage(key: ValueKey('binatu-dashboard-home')),
        const BinatuIroningQueueScreen(
          key: ValueKey('binatu-dashboard-queue'),
          showBackButton: false,
          showBackToDashboard: true,
        ),
        const BinatuAttendanceScreen(
          key: ValueKey('binatu-dashboard-attendance'),
          showBackButton: false,
          showBackToDashboard: true,
        ),
        const BinatuSettingsScreen(
          key: ValueKey('binatu-dashboard-settings'),
          showBackButton: false,
          showBackToDashboard: true,
        ),
      ],
    );
  }
}

class _BinatuHomePage extends ConsumerWidget {
  const _BinatuHomePage({super.key});

  void _openQueue(WidgetRef ref, BinatuQueueFilter filter, int tabIndex) {
    markBinatuQueueBadgeRead(ref, filter);
    ref.read(binatuQueueFilterProvider.notifier).setFilter(filter);
    ref.read(binatuDashboardTabProvider.notifier).setTab(tabIndex);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(binatuOrderProvider);
    final summaryAsync = ref.watch(operationalSummaryProvider);
    final summary = ref.read(binatuOrderProvider.notifier).dashboardSummary(
          laundry: summaryAsync.value?.laundry,
        );
    final badgeState = ref.watch(binatuDashboardBadgeProvider);

    return Column(
      children: [
        const SafeArea(
          bottom: false,
          child: PosHeader(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PosSectionTitle(title: 'Ringkasan Hari Ini'),
                const SizedBox(height: AppSpacing.s16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 500 ? 2 : 1;

                    return GridView(
                      padding: EdgeInsets.zero,
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: AppSpacing.s12,
                        crossAxisSpacing: AppSpacing.s12,
                        mainAxisExtent: 136,
                      ),
                      children: [
                        StatCard(
                          title: 'Waiting to be Assigned',
                          value: '${summary.waitingToBeAssigned}',
                          icon: Icons.hourglass_empty_outlined,
                          iconColor: AppColors.warning,
                        ),
                        StatCard(
                          title: 'Currently Ironing',
                          value: '${summary.currentlyIroning}',
                          icon: Icons.iron_outlined,
                          iconColor: AppColors.primary,
                        ),
                        StatCard(
                          title: 'Ironing Completed',
                          value: '${summary.ironingCompleted}',
                          icon: Icons.check_circle_outline,
                          iconColor: AppColors.success,
                        ),
                        StatCard(
                          title: "Today's Target (Kg)",
                          value: summary.todaysTargetKg > 0
                              ? summary.todaysTargetKg.toStringAsFixed(0)
                              : '—',
                          icon: Icons.flag_outlined,
                          iconColor: AppColors.primary,
                        ),
                        StatCard(
                          title: "Today's Completed (Kg)",
                          value: summary.todaysCompletedKg.toStringAsFixed(1),
                          icon: Icons.scale_outlined,
                          iconColor: AppColors.success,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s32),
                const PosSectionTitle(title: 'Menu Utama'),
                const SizedBox(height: AppSpacing.s16),
                PosMenuCard(
                  title: 'Ironing Queue',
                  icon: Icons.iron_outlined,
                  highlight: true,
                  badgeCount: badgeState.ironingQueueUnreadCount,
                  onTap: () => _openQueue(
                    ref,
                    BinatuQueueFilter.ironingQueue,
                    1,
                  ),
                ),
                PosMenuCard(
                  title: 'Currently Ironing',
                  icon: Icons.iron_outlined,
                  badgeCount: badgeState.currentlyIroningUnreadCount,
                  onTap: () => _openQueue(
                    ref,
                    BinatuQueueFilter.currentlyIroning,
                    1,
                  ),
                ),
                PosMenuCard(
                  title: 'Finished Ironing',
                  icon: Icons.task_alt_outlined,
                  badgeCount: badgeState.finishedIroningUnreadCount,
                  onTap: () => _openQueue(
                    ref,
                    BinatuQueueFilter.finishedIroning,
                    1,
                  ),
                ),
                PosMenuCard(
                  title: 'Ready for Pickup',
                  icon: Icons.inventory_2_outlined,
                  badgeCount: badgeState.readyForPickupUnreadCount,
                  onTap: () => _openQueue(
                    ref,
                    BinatuQueueFilter.readyForPickup,
                    1,
                  ),
                ),
                PosMenuCard(
                  title: 'Laci Laundry',
                  icon: Icons.inventory_2_outlined,
                  onTap: () => context.push('/laci-laundry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
