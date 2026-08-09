import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';

class OrderWorkflowTimeline extends StatelessWidget {
  const OrderWorkflowTimeline({
    super.key,
    required this.currentStep,
  });

  final OrderWorkflowStep currentStep;

  @override
  Widget build(BuildContext context) {
    final steps = OrderWorkflowStepX.orderedSteps;
    final currentIndex = steps.indexOf(currentStep);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workflow Status',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        for (var i = 0; i < steps.length; i++) ...[
          _StepRow(
            label: steps[i].label,
            isActive: i == currentIndex,
            isCompleted: i < currentIndex,
          ),
          if (i < steps.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Text(
                '↓',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  final String label;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.primary
        : isCompleted
            ? AppColors.success
            : AppColors.textSecondary;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : isCompleted
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.dashboardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? Icon(Icons.check, size: 14, color: color)
              : isActive
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.onPrimary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
