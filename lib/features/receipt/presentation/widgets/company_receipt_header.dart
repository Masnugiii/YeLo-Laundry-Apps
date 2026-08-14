import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/settings/models/receipt_settings_config.dart';
import 'package:yelo_laundry_erp/features/settings/providers/settings_provider.dart';

class CompanyReceiptHeader extends ConsumerWidget {
  const CompanyReceiptHeader({
    super.key,
    this.config,
    this.logoHeight = 40,
    this.titleFontSize = 10,
    this.baseFontSize = 8,
    this.showLogo = true,
    this.spacing = 8,
  });

  final ReceiptSettingsConfig? config;
  final double logoHeight;
  final double titleFontSize;
  final double baseFontSize;
  final bool showLogo;
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptAsync = ref.watch(receiptSettingsProvider);

    return receiptAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => Text(
        'Informasi perusahaan tidak tersedia',
        textAlign: TextAlign.center,
        style: ReceiptTheme.centerText(baseFontSize),
      ),
      data: (loaded) {
        final data = config ?? loaded;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showLogo && data.showLogo) ...[
              if (data.companyLogoUrl != null &&
                  data.companyLogoUrl!.trim().isNotEmpty)
                Center(
                  child: Image.network(
                    data.companyLogoUrl!,
                    height: logoHeight,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Image.asset(
                      'assets/images/Logo_WithBackground.png',
                      height: logoHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              else
                Center(
                  child: Image.asset(
                    'assets/images/Logo_WithBackground.png',
                    height: logoHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              SizedBox(height: spacing),
            ],
            Center(
              child: Text(
                data.companyName,
                style: ReceiptTheme.titleText(titleFontSize),
                textAlign: TextAlign.center,
              ),
            ),
            if (data.companyAddress != null &&
                data.companyAddress!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  data.companyAddress!,
                  textAlign: TextAlign.center,
                  style: ReceiptTheme.centerText(baseFontSize),
                ),
              ),
            ],
            if (data.companyPhone != null &&
                data.companyPhone!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'WA : ${data.companyPhone}',
                  textAlign: TextAlign.center,
                  style: ReceiptTheme.centerText(baseFontSize),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
