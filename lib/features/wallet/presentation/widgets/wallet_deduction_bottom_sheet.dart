import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/wallet/data/dummy_wallet_admins.dart';
import 'package:yelo_laundry_erp/features/wallet/data/dummy_wallet_transactions.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_admin.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_payment_confirmation.dart';
import 'package:yelo_laundry_erp/features/wallet/providers/wallet_providers.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_admin_dropdown.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_sheet_widgets.dart';

void showWalletDeductionBottomSheet(
  BuildContext context, {
  required int currentBalance,
  required String customerId,
  required String customerName,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _WalletDeductionBottomSheet(
      currentBalance: currentBalance,
      customerId: customerId,
      customerName: customerName,
    ),
  );
}

class _WalletDeductionBottomSheet extends ConsumerStatefulWidget {
  const _WalletDeductionBottomSheet({
    required this.currentBalance,
    required this.customerId,
    required this.customerName,
  });

  final int currentBalance;
  final String customerId;
  final String customerName;

  @override
  ConsumerState<_WalletDeductionBottomSheet> createState() =>
      _WalletDeductionBottomSheetState();
}

class _WalletDeductionBottomSheetState
    extends ConsumerState<_WalletDeductionBottomSheet> {
  final _amountController = TextEditingController();
  String _selectedReason = walletDeductionReasons.first;
  WalletAdmin _selectedAdmin = dummyCurrentWalletAdmin;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    try {
      await ref.read(walletRepositoryProvider).deduct(
            widget.customerId,
            amount: amount.toDouble(),
            notes: _selectedReason,
          );
      ref.invalidate(customerWalletProvider(widget.customerId));
      ref.invalidate(walletTransactionsProvider(widget.customerId));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memproses pengurangan saldo.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    final dateTime = DateTime.now();
    final confirmation = WalletPaymentConfirmation(
      customerId: widget.customerId,
      customerName: widget.customerName,
      initialBalance: widget.currentBalance,
      deductionAmount: amount,
      finalBalance: widget.currentBalance - amount,
      adminName: _selectedAdmin.name,
      deductionReason: _selectedReason,
      paymentMethod: 'Dompet Yelo',
      referenceNumber: WalletPaymentConfirmation.dummyReferenceNumber(dateTime),
      dateTime: dateTime,
    );

    Navigator.pop(context);
    context.push('/wallet-deduction/review', extra: confirmation);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s12,
        AppSpacing.s20,
        AppSpacing.s24 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WalletSheetHandle(),
          const SizedBox(height: AppSpacing.s20),
          Text(
            'Kurangi Saldo Dompet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          WalletCurrentBalance(balance: widget.currentBalance),
          const SizedBox(height: AppSpacing.s20),
          Text(
            'Jumlah Pengurangan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah pengurangan',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          WalletAdminDropdown(
            selectedAdmin: _selectedAdmin,
            admins: dummyWalletDeductionAdmins,
            onChanged: (admin) => setState(() => _selectedAdmin = admin),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Alasan Pengurangan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          DropdownButtonFormField<String>(
            initialValue: _selectedReason,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            items: [
              for (final reason in walletDeductionReasons)
                DropdownMenuItem(
                  value: reason,
                  child: Text(reason),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedReason = value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.s24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _continue,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Lanjutkan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
