import 'package:flutter/material.dart';

/// Display-only membership badge colors/labels.
/// Thresholds and benefits MUST come from backend membership payload —
/// do not use [minPoints] for business decisions.
enum LoyaltyClass {
  bronze,
  silver,
  gold,
  platinum,
}

class LoyaltyProgress {
  const LoyaltyProgress({
    required this.currentClass,
    required this.nextClass,
    required this.progress,
    required this.percent,
  });

  final LoyaltyClass currentClass;
  final LoyaltyClass? nextClass;
  final double progress;
  final int percent;

  bool get isMaxLevel => nextClass == null;
}

extension LoyaltyClassX on LoyaltyClass {
  String get label => switch (this) {
        LoyaltyClass.bronze => 'Regular',
        LoyaltyClass.silver => 'Silver',
        LoyaltyClass.gold => 'Gold',
        LoyaltyClass.platinum => 'Platinum',
      };

  /// Fallback display thresholds aligned with DEFAULT_LOYALTY_SETTINGS.
  /// Prefer [loyaltyClassFromCode] / membership API when available.
  int get minPoints => switch (this) {
        LoyaltyClass.bronze => 0,
        LoyaltyClass.silver => 500,
        LoyaltyClass.gold => 1500,
        LoyaltyClass.platinum => 3000,
      };

  Color get badgeBackground => switch (this) {
        LoyaltyClass.bronze => const Color(0xFFCD7F32),
        LoyaltyClass.silver => const Color(0xFFC0C0C0),
        LoyaltyClass.gold => const Color(0xFFF8D613),
        LoyaltyClass.platinum => const Color(0xFFE5E4E2),
      };

  Color get badgeText => switch (this) {
        LoyaltyClass.bronze => const Color(0xFFFFFFFF),
        LoyaltyClass.silver => const Color(0xFF1F2937),
        LoyaltyClass.gold => const Color(0xFF033B8E),
        LoyaltyClass.platinum => const Color(0xFF1F2937),
      };

  String get pointRange => switch (this) {
        LoyaltyClass.bronze => '0 – 499 Point',
        LoyaltyClass.silver => '500 – 1.499 Point',
        LoyaltyClass.gold => '1.500 – 2.999 Point',
        LoyaltyClass.platinum => '3.000+ Point',
      };

  LoyaltyClass? get nextClass => switch (this) {
        LoyaltyClass.bronze => LoyaltyClass.silver,
        LoyaltyClass.silver => LoyaltyClass.gold,
        LoyaltyClass.gold => LoyaltyClass.platinum,
        LoyaltyClass.platinum => null,
      };

  List<String> get benefits => switch (this) {
        LoyaltyClass.bronze => const [],
        LoyaltyClass.silver => ['Free Pickup'],
        LoyaltyClass.gold => ['Free Delivery'],
        LoyaltyClass.platinum => ['10% Discount', 'Priority Queue'],
      };
}

LoyaltyClass loyaltyClassFromCode(String? code) {
  switch ((code ?? '').toUpperCase()) {
    case 'SILVER':
      return LoyaltyClass.silver;
    case 'GOLD':
      return LoyaltyClass.gold;
    case 'PLATINUM':
      return LoyaltyClass.platinum;
    case 'REGULAR':
    case 'BRONZE':
    default:
      return LoyaltyClass.bronze;
  }
}

/// Fallback when membership API is unavailable.
/// Thresholds match backend DEFAULT_LOYALTY_SETTINGS.
LoyaltyClass loyaltyClassFromPoints(int points) {
  if (points >= 3000) {
    return LoyaltyClass.platinum;
  }
  if (points >= 1500) {
    return LoyaltyClass.gold;
  }
  if (points >= 500) {
    return LoyaltyClass.silver;
  }
  return LoyaltyClass.bronze;
}

LoyaltyProgress loyaltyProgressFromPoints(int points) {
  final currentClass = loyaltyClassFromPoints(points);
  final nextClass = currentClass.nextClass;

  if (nextClass == null) {
    return LoyaltyProgress(
      currentClass: currentClass,
      nextClass: null,
      progress: 1,
      percent: 100,
    );
  }

  final span = nextClass.minPoints - currentClass.minPoints;
  final progress = span <= 0
      ? 1.0
      : ((points - currentClass.minPoints) / span).clamp(0.0, 1.0);

  return LoyaltyProgress(
    currentClass: currentClass,
    nextClass: nextClass,
    progress: progress,
    percent: (progress * 100).round(),
  );
}
