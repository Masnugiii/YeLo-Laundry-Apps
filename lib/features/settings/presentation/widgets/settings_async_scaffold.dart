import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';

class SettingsAsyncScaffold extends StatelessWidget {
  const SettingsAsyncScaffold({
    super.key,
    required this.title,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.canEdit,
    required this.child,
    this.onSave,
    this.isSaving = false,
  });

  final String title;
  final bool isLoading;
  final Object? error;
  final VoidCallback onRetry;
  final bool canEdit;
  final Widget child;
  final VoidCallback? onSave;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Gagal memuat konfigurasi.',
                          style: GoogleFonts.poppins(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        FilledButton(
                          onPressed: onRetry,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  children: [
                    if (!canEdit)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                        padding: const EdgeInsets.all(AppSpacing.s12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Mode baca saja. Hanya Owner yang dapat mengubah konfigurasi.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF9A3412),
                          ),
                        ),
                      ),
                    child,
                    if (canEdit && onSave != null) ...[
                      const SizedBox(height: AppSpacing.s20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isSaving ? null : onSave,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.onAccent,
                          ),
                          child: Text(isSaving ? 'Menyimpan...' : 'Simpan'),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}
