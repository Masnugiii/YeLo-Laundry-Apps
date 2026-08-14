import 'package:flutter/material.dart';

import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';

enum MembershipLevel {
  bronze,
  silver,
  gold,
  platinum;

  String get label => switch (this) {
        MembershipLevel.bronze => 'BRONZE',
        MembershipLevel.silver => 'SILVER',
        MembershipLevel.gold => 'GOLD',
        MembershipLevel.platinum => 'PLATINUM',
      };

  Color get accentColor => switch (this) {
        MembershipLevel.bronze => const Color(0xFFB87333),
        MembershipLevel.silver => const Color(0xFFC0C0C0),
        MembershipLevel.gold => AppColors.brandYellow,
        MembershipLevel.platinum => const Color(0xFFE8E8F0),
      };

  Color get borderColor => switch (this) {
        MembershipLevel.bronze => const Color(0xFF8B5A2B),
        MembershipLevel.silver => const Color(0xFF9E9E9E),
        MembershipLevel.gold => const Color(0xFFD4AF37),
        MembershipLevel.platinum => const Color(0xFFB8B8C8),
      };

  Color get textColor => switch (this) {
        MembershipLevel.bronze => const Color(0xFFFFF8F0),
        MembershipLevel.silver => const Color(0xFF1A1A2E),
        MembershipLevel.gold => const Color(0xFF5C4A00),
        MembershipLevel.platinum => const Color(0xFF033B8E),
      };

  IconData get icon => Icons.workspace_premium_rounded;

  static MembershipLevel? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    return switch (raw.trim().toUpperCase()) {
      'BRONZE' || 'REGULAR' => MembershipLevel.bronze,
      'SILVER' => MembershipLevel.silver,
      'GOLD' => MembershipLevel.gold,
      'PLATINUM' => MembershipLevel.platinum,
      _ => null,
    };
  }

  static MembershipLevel? fromJson(Map<String, dynamic> json) {
    final direct = json['membershipLevel'] ?? json['membership_level'];
    if (direct is String) return tryParse(direct);

    final membership = json['membership'];
    if (membership is Map<String, dynamic>) {
      final currentLevel = membership['currentLevel'];
      if (currentLevel is Map<String, dynamic>) {
        return tryParse(currentLevel['code'] as String?);
      }
      return tryParse(membership['code'] as String?);
    }

    return null;
  }
}

extension CustomerSessionMembership on CustomerSession {
  MembershipLevel get resolvedMembershipLevel =>
      membershipLevel ?? MembershipLevel.bronze;
}
