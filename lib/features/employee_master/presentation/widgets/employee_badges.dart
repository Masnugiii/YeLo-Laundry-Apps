import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';

class EmployeeRoleBadge extends StatelessWidget {
  const EmployeeRoleBadge({
    super.key,
    required this.role,
  });

  final EmployeeRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: role.badgeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: role.badgeTextColor,
        ),
      ),
    );
  }
}

class EmployeeStatusBadge extends StatelessWidget {
  const EmployeeStatusBadge({
    super.key,
    required this.status,
  });

  final EmployeeStatus status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == EmployeeStatus.active;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF16A34A).withValues(alpha: 0.12)
            : const Color(0xFFDC2626).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        ),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        ),
      ),
    );
  }
}
