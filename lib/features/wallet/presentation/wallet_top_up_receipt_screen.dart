import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/wallet/data/dummy_wallet_top_up_receipt.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_confirmation.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_receipt.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_top_up_thermal_receipt_layout.dart';

class WalletTopUpReceiptScreen extends StatefulWidget {
  const WalletTopUpReceiptScreen({
    super.key,
    this.confirmation,
    this.receipt,
  });

  final WalletTopUpConfirmation? confirmation;
  final WalletTopUpReceipt? receipt;

  @override
  State<WalletTopUpReceiptScreen> createState() =>
      _WalletTopUpReceiptScreenState();
}

class _WalletTopUpReceiptScreenState extends State<WalletTopUpReceiptScreen> {
  WalletTopUpReceiptPaperWidth _paperWidth = WalletTopUpReceiptPaperWidth.mm58;

  WalletTopUpReceipt get _receipt {
    if (widget.receipt != null) return widget.receipt!;
    if (widget.confirmation != null) {
      return walletTopUpReceiptFromConfirmation(widget.confirmation!);
    }
    return dummyWalletTopUpReceipt;
  }

  String? get _customerId => widget.confirmation?.customerId;

  void _showDummySnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _onFinish() {
    if (_customerId != null) {
      context.go('/customers/$_customerId');
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Struk Top Up Wallet',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s16,
              AppSpacing.s20,
              AppSpacing.s8,
            ),
            child: Row(
              children: [
                _PaperChip(
                  label: '58 mm',
                  selected: _paperWidth == WalletTopUpReceiptPaperWidth.mm58,
                  onTap: () => setState(
                    () => _paperWidth = WalletTopUpReceiptPaperWidth.mm58,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                _PaperChip(
                  label: '80 mm',
                  selected: _paperWidth == WalletTopUpReceiptPaperWidth.mm80,
                  onTap: () => setState(
                    () => _paperWidth = WalletTopUpReceiptPaperWidth.mm80,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s20,
                  vertical: AppSpacing.s16,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ReceiptTheme.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: WalletTopUpThermalReceiptLayout(
                    receipt: _receipt,
                    paperWidth: _paperWidth,
                  ),
                ),
              ),
            ),
          ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () => _showDummySnackBar(
                      'Mencetak struk top up (${_paperWidth.name})...',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cetak Struk',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () => _showDummySnackBar(
                      'Membuka WhatsApp untuk membagikan struk...',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Bagikan Struk ke WhatsApp',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _onFinish,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Selesai',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaperChip extends StatelessWidget {
  const _PaperChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.onPrimary : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
