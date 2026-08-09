import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';

class ReceiptLayoutConfig {
  const ReceiptLayoutConfig({
    required this.width,
    required this.baseFontSize,
    required this.titleFontSize,
    required this.logoHeight,
    required this.horizontalPadding,
    required this.sectionSpacing,
    required this.compact,
  });

  final double width;
  final double baseFontSize;
  final double titleFontSize;
  final double logoHeight;
  final double horizontalPadding;
  final double sectionSpacing;
  final bool compact;

  static ReceiptLayoutConfig forMode(ReceiptPreviewMode mode) {
    return switch (mode) {
      ReceiptPreviewMode.thermal58 => const ReceiptLayoutConfig(
          width: 216,
          baseFontSize: 10,
          titleFontSize: 12,
          logoHeight: 48,
          horizontalPadding: 10,
          sectionSpacing: 8,
          compact: false,
        ),
      ReceiptPreviewMode.thermal80 => const ReceiptLayoutConfig(
          width: 302,
          baseFontSize: 11,
          titleFontSize: 14,
          logoHeight: 56,
          horizontalPadding: 14,
          sectionSpacing: 10,
          compact: false,
        ),
      ReceiptPreviewMode.pdf => const ReceiptLayoutConfig(
          width: 360,
          baseFontSize: 12,
          titleFontSize: 16,
          logoHeight: 64,
          horizontalPadding: 20,
          sectionSpacing: 12,
          compact: false,
        ),
      ReceiptPreviewMode.whatsapp => const ReceiptLayoutConfig(
          width: 280,
          baseFontSize: 10,
          titleFontSize: 12,
          logoHeight: 44,
          horizontalPadding: 12,
          sectionSpacing: 6,
          compact: true,
        ),
    };
  }
}

abstract final class ReceiptTheme {
  static const backgroundColor = Color(0xFFFFFFFF);
  static const textColor = Color(0xFF000000);
  static const dividerColor = Color(0xFF000000);

  static TextStyle baseText(double size, {FontWeight weight = FontWeight.w500}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: textColor,
      height: 1.35,
    );
  }

  static TextStyle titleText(double size) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: textColor,
      height: 1.2,
    );
  }

  static TextStyle centerText(double size, {FontWeight weight = FontWeight.w600}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: textColor,
      height: 1.3,
    );
  }
}
