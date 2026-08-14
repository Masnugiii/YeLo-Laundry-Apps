import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/models/binatu_monitoring_models.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/presentation/widgets/binatu_monitoring_empty_state.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/presentation/widgets/binatu_monitoring_filter_section.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/presentation/widgets/binatu_monitoring_employee_card.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/providers/binatu_monitoring_provider.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/utils/binatu_monitoring_date_helper.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_section_title.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class BinatuMonitoringScreen extends ConsumerStatefulWidget {
  const BinatuMonitoringScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  ConsumerState<BinatuMonitoringScreen> createState() =>
      _BinatuMonitoringScreenState();
}

class _BinatuMonitoringScreenState
    extends ConsumerState<BinatuMonitoringScreen> {
  BinatuMonitoringDateFilter _filter = BinatuMonitoringDateFilter.today;
  DateTime _customDate = DateTime.now();

  BinatuMonitoringDateRange get _dateRange =>
      BinatuMonitoringDateHelper.resolveRange(
        filter: _filter,
        customDate: _customDate,
      );

  DateTime get _displayDate => BinatuMonitoringDateHelper.displayDate(
        filter: _filter,
        customDate: _customDate,
      );

  Future<void> _pickDate() async {
    final picked = await showBinatuMonitoringDatePicker(
      context,
      initialDate: _displayDate,
    );

    if (picked == null) return;

    setState(() {
      _filter = BinatuMonitoringDateFilter.custom;
      _customDate = picked;
    });
  }

  void _onFilterSelected(BinatuMonitoringDateFilter filter) {
    setState(() => _filter = filter);

    if (filter == BinatuMonitoringDateFilter.custom) {
      _pickDate();
    }
  }

  String _summarySectionTitle() {
    return switch (_filter) {
      BinatuMonitoringDateFilter.today => 'Ringkasan Hari Ini',
      BinatuMonitoringDateFilter.yesterday => 'Ringkasan Kemarin',
      BinatuMonitoringDateFilter.thisWeek => 'Ringkasan Minggu Ini',
      BinatuMonitoringDateFilter.thisMonth => 'Ringkasan Bulan Ini',
      BinatuMonitoringDateFilter.custom => 'Ringkasan Tanggal Terpilih',
    };
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = _dateRange;
    final monitoringAsync = ref.watch(
      binatuMonitoringProvider(
        BinatuMonitoringQuery(
          filter: _filter,
          customDate: _customDate,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Monitoring Binatu',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: monitoringAsync.when(
        loading: () => const ApiLoadingView(message: 'Memuat monitoring binatu...'),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.invalidate(
            binatuMonitoringProvider(
              BinatuMonitoringQuery(
                filter: _filter,
                customDate: _customDate,
              ),
            ),
          ),
        ),
        data: (monitoring) {
          final summary = monitoring.summary;
          final employees = monitoring.employees
              .where((employee) => employee.isActive)
              .toList();
          final hasActivity = summary.totalIroningOrders > 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s32,
            ),
            children: [
              BinatuMonitoringFilterSection(
                selectedFilter: _filter,
                selectedDate: _displayDate,
                onFilterSelected: _onFilterSelected,
                onDatePickerTap: _pickDate,
              ),
              const SizedBox(height: AppSpacing.s24),
              PosSectionTitle(title: _summarySectionTitle()),
              const SizedBox(height: AppSpacing.s16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 520;
                  final itemWidth = isWide
                      ? (constraints.maxWidth - AppSpacing.s12) / 2
                      : constraints.maxWidth;

                  final summaryCards = [
                    StatCard(
                      title: 'Active Binatu',
                      value: '${summary.activeBinatu}',
                      icon: Icons.people_outline,
                      iconColor: AppColors.primary,
                      useOwnerStyle: true,
                    ),
                    StatCard(
                      title: 'Total Ironing Orders',
                      value: '${summary.totalIroningOrders}',
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppColors.primary,
                      useOwnerStyle: true,
                    ),
                    StatCard(
                      title: 'Total Kg Ironed',
                      value: summary.totalKgIroned.toStringAsFixed(1),
                      icon: Icons.scale_outlined,
                      iconColor: AppColors.success,
                      useOwnerStyle: true,
                    ),
                    StatCard(
                      title: 'Orders In Progress',
                      value: '${summary.ordersStillInProgress}',
                      icon: Icons.iron_outlined,
                      iconColor: AppColors.warning,
                      useOwnerStyle: true,
                    ),
                  ];

                  return Wrap(
                    spacing: AppSpacing.s12,
                    runSpacing: AppSpacing.s12,
                    children: [
                      for (final card in summaryCards)
                        SizedBox(
                          width: itemWidth,
                          child: card,
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s32),
              const PosSectionTitle(title: 'Daftar Binatu'),
              const SizedBox(height: AppSpacing.s16),
              if (!hasActivity)
                const BinatuMonitoringEmptyState()
              else
                for (var i = 0; i < employees.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.s12),
                  BinatuMonitoringEmployeeCard(
                    employee: employees[i],
                    dateLabel: dateRange.displayLabel,
                    onViewDetail: () {
                      final dateQuery =
                          _customDate.toIso8601String().split('T').first;
                      context.push(
                        '/monitoring-binatu/${employees[i].id}'
                        '?filter=${_filter.name}&date=$dateQuery',
                      );
                    },
                  ),
                ],
            ],
          );
        },
      ),
    );
  }
}
