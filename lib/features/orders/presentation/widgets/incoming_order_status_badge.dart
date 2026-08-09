import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';

class IncomingOrderStatusBadge extends StatelessWidget {
  const IncomingOrderStatusBadge({
    super.key,
    required this.status,
  });

  final IncomingOrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status.textColor,
        ),
      ),
    );
  }
}
