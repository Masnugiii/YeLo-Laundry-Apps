import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';

class AiCategoryBadge extends StatelessWidget {
  const AiCategoryBadge({
    super.key,
    required this.category,
  });

  final WhatsappMessageCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: category.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: category.textColor,
        ),
      ),
    );
  }
}
