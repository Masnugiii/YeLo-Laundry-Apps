import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';

Future<OrderWorkflowStep?> showUpdateOrderStatusBottomSheet(
  BuildContext context, {
  required OrderWorkflowStep currentStep,
}) {
  return showModalBottomSheet<OrderWorkflowStep>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _UpdateOrderStatusBottomSheet(
      currentStep: currentStep,
    ),
  );
}

class _UpdateOrderStatusBottomSheet extends StatefulWidget {
  const _UpdateOrderStatusBottomSheet({
    required this.currentStep,
  });

  final OrderWorkflowStep currentStep;

  @override
  State<_UpdateOrderStatusBottomSheet> createState() =>
      _UpdateOrderStatusBottomSheetState();
}

class _UpdateOrderStatusBottomSheetState
    extends State<_UpdateOrderStatusBottomSheet> {
  late OrderWorkflowStep _selectedStep;

  @override
  void initState() {
    super.initState();
    _selectedStep = widget.currentStep;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s20,
        AppSpacing.s20,
        AppSpacing.s20 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Update Status Laundry',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: SingleChildScrollView(
              child: RadioGroup<OrderWorkflowStep>(
                groupValue: _selectedStep,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStep = value);
                  }
                },
                child: Column(
                  children: [
                    for (final step in OrderWorkflowStepX.orderedSteps)
                      RadioListTile<OrderWorkflowStep>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          step.updateStatusLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        value: step,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          FilledButton(
            onPressed: () => Navigator.pop(context, _selectedStep),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Simpan Status',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
