import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/utils/date_display_helper.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/today_activity_tile.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/today_activity_provider.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_erp/shared/widgets/erp_app_bar.dart';

class TodayActivityScreen extends ConsumerWidget {
  const TodayActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(todayActivityProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: const ErpAppBar(title: 'Aktivitas Hari Ini'),
      body: activityAsync.when(
        loading: () => const ApiLoadingView(),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.read(todayActivityProvider.notifier).refresh(),
        ),
        data: (state) {
          if (state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: Text(
                  'Belum ada aktivitas hari ini',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final itemCount =
              1 + state.items.length + (state.isLoadingMore ? 1 : 0);

          return RefreshIndicator(
            onRefresh: () => ref.read(todayActivityProvider.notifier).refresh(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
                  ref.read(todayActivityProvider.notifier).loadMore();
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  AppSpacing.s20,
                  AppSpacing.s20,
                  AppSpacing.s32,
                ),
                itemCount: itemCount,
                separatorBuilder: (context, index) {
                  if (index == 0) {
                    return const SizedBox(height: AppSpacing.s16);
                  }
                  return const SizedBox(height: AppSpacing.s12);
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Text(
                      DateDisplayHelper.shortIndonesianDate(state.activityDate),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    );
                  }

                  final itemIndex = index - 1;
                  if (itemIndex >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.s16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }

                  final item = state.items[itemIndex];
                  return TodayActivityTile(
                    item: item,
                    onTap: () => context.push('/orders/${item.orderId}'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
