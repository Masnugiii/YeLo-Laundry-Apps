import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_radius.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/data/dummy_binatu_monitoring_data.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/models/binatu_monitoring_models.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/presentation/widgets/binatu_monitoring_empty_state.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/presentation/widgets/binatu_monitoring_filter_section.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/presentation/widgets/binatu_monitoring_order_card.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/utils/binatu_monitoring_date_helper.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_section_title.dart';

class BinatuMonitoringEmployeeDetailScreen extends StatefulWidget {
  const BinatuMonitoringEmployeeDetailScreen({
    super.key,
    required this.employeeId,
    this.initialFilter = BinatuMonitoringDateFilter.today,
    this.initialDate,
  });

  final String employeeId;
  final BinatuMonitoringDateFilter initialFilter;
  final DateTime? initialDate;

  @override
  State<BinatuMonitoringEmployeeDetailScreen> createState() =>
      _BinatuMonitoringEmployeeDetailScreenState();
}

class _BinatuMonitoringEmployeeDetailScreenState
    extends State<BinatuMonitoringEmployeeDetailScreen> {
  late BinatuMonitoringDateFilter _filter;
  late DateTime _customDate;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _customDate = widget.initialDate ?? DateTime.now();
  }

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

  @override
  Widget build(BuildContext context) {
    final employee = employeeMonitoringById(widget.employeeId);

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Binatu')),
        body: const Center(child: Text('Karyawan tidak ditemukan.')),
      );
    }

    final dateRange = _dateRange;
    final stats = employeeStatsForRange(widget.employeeId, dateRange);
    final orders = ordersForEmployeeInRange(widget.employeeId, dateRange);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          employee.name,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: ListView(
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.cardRadius,
              boxShadow: AppShadows.md(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  dateRange.displayLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                _SummaryMetric(
                  label: 'Total Ironing Orders',
                  value: '${stats.totalIroningOrders}',
                ),
                _SummaryMetric(
                  label: 'Total Kg Ironed',
                  value: '${stats.totalKgIroned.toStringAsFixed(1)} Kg',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          const PosSectionTitle(title: 'Order List'),
          const SizedBox(height: AppSpacing.s16),
          if (orders.isEmpty)
            const BinatuMonitoringEmptyState()
          else
            for (var i = 0; i < orders.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.s12),
              BinatuMonitoringOrderCard(order: orders[i]),
            ],
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
