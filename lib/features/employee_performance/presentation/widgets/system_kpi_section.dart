import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/data/dummy_employee_performance_data.dart'
    show binatuAutoMetrics, kasirAutoMetrics;
import 'package:yelo_laundry_erp/features/employee_performance/models/employee_performance_models.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/performance_theme.dart';

class SystemKpiSection extends StatelessWidget {
  const SystemKpiSection({
    super.key,
    required this.role,
  });

  final EmployeeRole role;

  @override
  Widget build(BuildContext context) {
    final metrics = role == EmployeeRole.binatu
        ? binatuAutoMetrics
        : kasirAutoMetrics;
    final title = role == EmployeeRole.binatu ? 'BINATU' : 'KASIR';

    return PerformanceTheme.sectionCard(
      title: 'Sistem KPI — $title',
      subtitle: 'Sistem membaca aktivitas berikut secara otomatis.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < metrics.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s8),
            _MetricItem(label: metrics[i]),
          ],
          const SizedBox(height: AppSpacing.s16),
          if (role == EmployeeRole.binatu)
            const BinatuMetricsExampleCard()
          else
            const KasirMetricsExampleCard(),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle,
          size: 18,
          color: AppColors.success,
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class BinatuMetricsExampleCard extends StatelessWidget {
  const BinatuMetricsExampleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _ExampleCard(
      children: [
        _ExampleRow(label: 'Hari Ini', value: '128 Kg'),
        const _ExampleDivider(),
        _ExampleRow(label: 'Target', value: '100 Kg'),
        const _ExampleDivider(),
        _ExampleRow(
          label: 'Status',
          value: 'Excellent',
          valueColor: AppColors.success,
        ),
        const _ExampleDivider(),
        _ExampleRow(
          label: 'Point',
          value: '+20',
          valueColor: AppColors.success,
        ),
      ],
    );
  }
}

class KasirMetricsExampleCard extends StatelessWidget {
  const KasirMetricsExampleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _ExampleCard(
      children: [
        _ExampleRow(label: 'Order', value: '38'),
        const _ExampleDivider(),
        _ExampleRow(label: 'Wallet', value: '12'),
        const _ExampleDivider(),
        _ExampleRow(label: 'Customer Baru', value: '7'),
        const _ExampleDivider(),
        _ExampleRow(
          label: 'Point',
          value: '145',
          valueColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.dashboardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: PerformanceTheme.labelStyle),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleDivider extends StatelessWidget {
  const _ExampleDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.divider);
  }
}
