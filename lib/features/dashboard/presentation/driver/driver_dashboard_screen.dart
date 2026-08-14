import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/role/staff_permissions.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/binatu_attendance_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_header.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_menu_card.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_section_title.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/dashboard_activity_section.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/role_dashboard_shell.dart';
import 'package:yelo_laundry_erp/features/notifications/presentation/notification_center_screen.dart';
import 'package:yelo_laundry_erp/features/pickup_delivery/presentation/pickup_delivery_screen.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardShell(
      key: const ValueKey('driver-dashboard'),
      role: UserRole.driver,
      backgroundColor: AppColors.dashboardBackground,
      pages: const [
        _DriverHomePage(key: ValueKey('driver-dashboard-home')),
        PickupDeliveryScreen(
          key: ValueKey('driver-dashboard-pickup'),
          showBackButton: false,
        ),
        BinatuAttendanceScreen(
          key: ValueKey('driver-dashboard-attendance'),
          showBackButton: false,
        ),
        NotificationCenterScreen(
          key: ValueKey('driver-dashboard-notifications'),
          showBackButton: false,
        ),
      ],
    );
  }
}

class _DriverHomePage extends ConsumerWidget {
  const _DriverHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(staffPermissionsProvider);

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
                const PosSectionTitle(title: 'Menu Utama'),
                const SizedBox(height: AppSpacing.s16),
                if (permissions.pickupDelivery)
                  PosMenuCard(
                    title: 'Pickup & Delivery',
                    icon: Icons.local_shipping_outlined,
                    highlight: true,
                    onTap: () => context.push('/pickup-delivery'),
                  ),
                if (permissions.attendance)
                  PosMenuCard(
                    title: 'Kehadiran',
                    icon: Icons.fingerprint_outlined,
                    onTap: () => context.push('/attendance/personal'),
                  ),
                if (permissions.notification)
                  PosMenuCard(
                    title: 'Notification Center',
                    icon: Icons.notifications_outlined,
                    onTap: () => context.push('/notifications'),
                  ),
                PosMenuCard(
                  title: 'Laci Laundry',
                  icon: Icons.inventory_2_outlined,
                  onTap: () => context.push('/laci-laundry'),
                ),
                const SizedBox(height: AppSpacing.s32),
                const DashboardActivitySection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
