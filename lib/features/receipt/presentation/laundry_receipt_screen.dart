import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/receipt/data/dummy_laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/pdf_receipt_layout.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_action_buttons.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/thermal_receipt_layout.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/whatsapp_receipt_layout.dart';

class LaundryReceiptScreen extends StatefulWidget {
  const LaundryReceiptScreen({
    super.key,
    this.receipt,
  });

  final LaundryReceipt? receipt;

  @override
  State<LaundryReceiptScreen> createState() => _LaundryReceiptScreenState();
}

class _LaundryReceiptScreenState extends State<LaundryReceiptScreen> {
  ReceiptPreviewMode _previewMode = ReceiptPreviewMode.thermal58;

  LaundryReceipt get _receipt => widget.receipt ?? dummyLaundryReceipt;

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

  Widget _buildPreview() {
    return switch (_previewMode) {
      ReceiptPreviewMode.thermal58 => ThermalReceiptLayout(
          receipt: _receipt,
          paperWidth: ThermalPaperWidth.mm58,
        ),
      ReceiptPreviewMode.thermal80 => ThermalReceiptLayout(
          receipt: _receipt,
          paperWidth: ThermalPaperWidth.mm80,
        ),
      ReceiptPreviewMode.pdf => PdfReceiptLayout(receipt: _receipt),
      ReceiptPreviewMode.whatsapp => WhatsappReceiptLayout(receipt: _receipt),
    };
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
          'Struk Laundry',
          style: GoogleFonts.poppins(
            fontSize: 22,
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PreviewChip(
                    label: '58 mm',
                    selected: _previewMode == ReceiptPreviewMode.thermal58,
                    onTap: () => setState(
                      () => _previewMode = ReceiptPreviewMode.thermal58,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _PreviewChip(
                    label: '80 mm',
                    selected: _previewMode == ReceiptPreviewMode.thermal80,
                    onTap: () => setState(
                      () => _previewMode = ReceiptPreviewMode.thermal80,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _PreviewChip(
                    label: 'PDF',
                    selected: _previewMode == ReceiptPreviewMode.pdf,
                    onTap: () => setState(
                      () => _previewMode = ReceiptPreviewMode.pdf,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _PreviewChip(
                    label: 'WhatsApp',
                    selected: _previewMode == ReceiptPreviewMode.whatsapp,
                    onTap: () => setState(
                      () => _previewMode = ReceiptPreviewMode.whatsapp,
                    ),
                  ),
                ],
              ),
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
                  child: _buildPreview(),
                ),
              ),
            ),
          ),
          ReceiptActionButtons(
            onPrint: () => _showDummySnackBar(
              'Mencetak struk (${_previewMode.name})...',
            ),
            onShareWhatsApp: () => _showDummySnackBar(
              'Membuka WhatsApp untuk membagikan struk...',
            ),
            onSavePdf: () => _showDummySnackBar(
              'Menyimpan struk sebagai PDF...',
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({
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
