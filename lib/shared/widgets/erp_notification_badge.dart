import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared Material 3 notification badge used across Yelo Laundry ERP dashboards.
abstract final class ErpNotificationBadgeStyle {
  static const Color backgroundColor = Color(0xFFDC2626);
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 5, vertical: 2);
  static const Alignment alignment = Alignment.topRight;
  static const Offset offset = Offset(4, -4);

  static TextStyle labelStyle() => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );
}

String formatErpBadgeCount(int count) {
  if (count <= 0) return '';
  if (count > 99) return '99+';
  return '$count';
}

class ErpNotificationBadge extends StatelessWidget {
  const ErpNotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.alignment = ErpNotificationBadgeStyle.alignment,
    this.offset = ErpNotificationBadgeStyle.offset,
  });

  final int count;
  final Widget child;
  final Alignment alignment;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return child;
    }

    return Badge(
      label: Text(
        formatErpBadgeCount(count),
        style: ErpNotificationBadgeStyle.labelStyle(),
      ),
      backgroundColor: ErpNotificationBadgeStyle.backgroundColor,
      padding: ErpNotificationBadgeStyle.padding,
      alignment: alignment,
      offset: offset,
      child: child,
    );
  }
}
