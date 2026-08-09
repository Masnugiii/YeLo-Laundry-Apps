import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_order.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_status.dart';
import 'package:yelo_laundry_erp/features/binatu/presentation/widgets/binatu_ironing_status_badge.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_order_provider.dart';
import 'package:yelo_laundry_erp/features/binatu/models/ironing_queue_priority_settings.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/ironing_queue_priority_provider.dart';

class BinatuOrderDetailScreen extends ConsumerWidget {
  const BinatuOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ironingQueuePriorityProvider);
    final role = ref.watch(userRoleProvider);
    final prioritySettings = ref.watch(ironingQueuePriorityProvider);
    final orders = ref.watch(binatuOrderProvider);
    BinatuIroningOrder? order;
    for (final item in orders) {
      if (item.id == orderId) {
        order = item;
        break;
      }
    }

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Detail')),
        body: const Center(child: Text('Order tidak ditemukan.')),
      );
    }

    final currentOrder = order;
    final actionLabel = _actionLabel(
      currentOrder,
      role: role,
      allowOperatorAssistance: prioritySettings.allowOperatorAssistance,
    );

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Detail Order',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              children: [
                if (_priorityInfo(currentOrder, role, prioritySettings) != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      _priorityInfo(currentOrder, role, prioritySettings)!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        height: 1.45,
                      ),
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.md(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              currentOrder.orderNumber,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          BinatuIroningStatusBadge(
                            status: currentOrder.ironingStatus,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      _DetailRow(
                        label: 'Customer Name',
                        value: currentOrder.customerName,
                      ),
                      _DetailRow(label: 'Service', value: currentOrder.service),
                      _DetailRow(
                        label: 'Weight',
                        value: currentOrder.weightLabel,
                      ),
                      _DetailRow(
                        label: 'Quantity (pcs)',
                        value: currentOrder.quantityLabel,
                      ),
                      _DetailRow(
                        label: 'Customer Notes',
                        value: currentOrder.customerNotes,
                      ),
                      _DetailRow(
                        label: 'Deadline',
                        value: currentOrder.deadlineLabel,
                      ),
                      _DetailRow(
                        label: 'Accepted by',
                        value: currentOrder.assignedBinatu ?? '-',
                        valueColor: AppColors.primary,
                      ),
                      _DetailRow(
                        label: 'Ironing Status',
                        value: currentOrder.ironingStatus.label,
                      ),
                      if (currentOrder.isOperatorAssistance)
                        _DetailRow(
                          label: 'Assistance Type',
                          value: 'Operator Assistance',
                          valueColor: AppColors.warning,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null)
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s12,
                AppSpacing.s20,
                AppSpacing.s24,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      _onActionPressed(context, ref, currentOrder, role),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _priorityInfo(
    BinatuIroningOrder order,
    UserRole role,
    IroningQueuePrioritySettings prioritySettings,
  ) {
    if (order.isWaitingForBinatu &&
        (role == UserRole.cashierLaundry ||
            role == UserRole.cashierLaundryDriver ||
            role == UserRole.cashier)) {
      final remaining =
          order.remainingBinatuPriority(prioritySettings.waitingDuration);
      final minutes = remaining.inMinutes;
      final seconds = remaining.inSeconds % 60;
      return 'Menunggu Binatu menerima pekerjaan. Operator dapat membantu '
          'setelah ${prioritySettings.waitingTimeMinutes} menit '
          '(${minutes}m ${seconds.toString().padLeft(2, '0')}s tersisa).';
    }

    if (order.isWaitingForOperatorAssistance &&
        (role == UserRole.cashierLaundry ||
            role == UserRole.cashierLaundryDriver) &&
        prioritySettings.allowOperatorAssistance) {
      return 'Binatu belum menerima pekerjaan ini. Operator dapat membantu '
          'sebagai prioritas kedua.';
    }

    if (order.isWaitingForOperatorAssistance && role == UserRole.laundry) {
      return 'Waktu prioritas Binatu telah habis. Menunggu bantuan Operator.';
    }

    return null;
  }

  String? _actionLabel(
    BinatuIroningOrder order, {
    required UserRole role,
    required bool allowOperatorAssistance,
  }) {
    if (role == UserRole.laundry && order.canBinatuAccept) {
      return 'Terima Pekerjaan';
    }
    if ((role == UserRole.cashierLaundry ||
            role == UserRole.cashierLaundryDriver) &&
        order.canOperatorAccept(allowOperatorAssistance)) {
      return 'Accept Assistance';
    }
    if (order.canStartIroning) return 'Mulai Setrika';
    if (order.canFinishIroning) return 'Selesai Setrika';
    if (order.canMarkReadyForPickup) return 'Siap Diambil';
    return null;
  }

  void _onActionPressed(
    BuildContext context,
    WidgetRef ref,
    BinatuIroningOrder order,
    UserRole role,
  ) {
    final notifier = ref.read(binatuOrderProvider.notifier);

    if (role == UserRole.laundry && order.canBinatuAccept) {
      notifier.acceptJobAsBinatu(order.id);
    } else if ((role == UserRole.cashierLaundry ||
            role == UserRole.cashierLaundryDriver) &&
        order.canOperatorAccept(
          ref.read(ironingQueuePriorityProvider).allowOperatorAssistance,
        )) {
      notifier.acceptJobAsOperator(order.id);
    } else if (order.canStartIroning) {
      notifier.startIroning(order.id);
    } else if (order.canFinishIroning) {
      notifier.finishIroning(order.id);
    } else if (order.canMarkReadyForPickup) {
      notifier.markReadyForPickup(order.id);
      context.pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        content: Text(
          'Status order diperbarui.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
