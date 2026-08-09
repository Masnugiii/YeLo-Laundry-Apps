import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/wallet/data/dummy_wallet_admins.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_admin.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_confirmation.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_admin_dropdown.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_sheet_widgets.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

void showWalletTopUpBottomSheet(
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
    builder: (context) => _WalletTopUpBottomSheet(
      currentBalance: currentBalance,
      customerId: customerId,
      customerName: customerName,
    ),
  );
}

class _WalletTopUpBottomSheet extends StatefulWidget {
  const _WalletTopUpBottomSheet({
    required this.currentBalance,
    required this.customerId,
    required this.customerName,
  });

  final int currentBalance;
  final String customerId;
  final String customerName;

  @override
  State<_WalletTopUpBottomSheet> createState() => _WalletTopUpBottomSheetState();
}

class _WalletTopUpBottomSheetState extends State<_WalletTopUpBottomSheet> {
  final _amountController = TextEditingController();
  WalletTopUpPaymentMethod _paymentMethod = WalletTopUpPaymentMethod.cash;
  WalletAdmin _selectedAdmin = dummyCurrentTopUpAdmin;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _continue() {
    final amount = int.tryParse(_amountController.text) ?? 0;
    final confirmation = WalletTopUpConfirmation(
      customerId: widget.customerId,
      customerName: widget.customerName,
      initialBalance: widget.currentBalance,
      topUpAmount: amount,
      finalBalance: widget.currentBalance + amount,
      adminName: _selectedAdmin.name,
      paymentMethod: _paymentMethod,
      dateTime: DateTime.now(),
    );

    // Dummy audit record foundation — no persistence yet.
    final _ = WalletTopUpRecord(
      adminName: _selectedAdmin.name,
      paymentMethod: _paymentMethod,
      amount: amount,
      dateTime: confirmation.dateTime,
      customerId: widget.customerId,
    );

    Navigator.pop(context);

    final route = switch (_paymentMethod) {
      WalletTopUpPaymentMethod.cash => '/wallet-top-up/review',
      WalletTopUpPaymentMethod.qris => '/wallet-top-up/qris',
      WalletTopUpPaymentMethod.transfer => '/wallet-top-up/transfer',
    };

    context.push(route, extra: confirmation);
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
            'Tambah Saldo Dompet',
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
            'Jumlah Top Up',
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
              hintText: 'Masukkan jumlah top up',
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
            admins: dummyWalletAdmins,
            onChanged: (admin) => setState(() => _selectedAdmin = admin),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Metode Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Row(
            children: [
              for (var i = 0; i < WalletTopUpPaymentMethod.values.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: SelectableChip(
                    expand: true,
                    label: WalletTopUpPaymentMethod.values[i].label,
                    isSelected:
                        _paymentMethod == WalletTopUpPaymentMethod.values[i],
                    onTap: () {
                      setState(() {
                        _paymentMethod = WalletTopUpPaymentMethod.values[i];
                      });
                    },
                  ),
                ),
              ],
            ],
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
                'Lanjut',
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
