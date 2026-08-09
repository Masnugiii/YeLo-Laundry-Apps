import 'package:flutter/material.dart';

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
        LoyaltyClass.bronze => 'Bronze',
        LoyaltyClass.silver => 'Silver',
        LoyaltyClass.gold => 'Gold',
        LoyaltyClass.platinum => 'Platinum',
      };

  int get minPoints => switch (this) {
        LoyaltyClass.bronze => 0,
        LoyaltyClass.silver => 1000,
        LoyaltyClass.gold => 3000,
        LoyaltyClass.platinum => 7000,
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
        LoyaltyClass.bronze => '0 – 999 Point',
        LoyaltyClass.silver => '1.000 – 2.999 Point',
        LoyaltyClass.gold => '3.000 – 6.999 Point',
        LoyaltyClass.platinum => '7.000+ Point',
      };

  LoyaltyClass? get nextClass => switch (this) {
        LoyaltyClass.bronze => LoyaltyClass.silver,
        LoyaltyClass.silver => LoyaltyClass.gold,
        LoyaltyClass.gold => LoyaltyClass.platinum,
        LoyaltyClass.platinum => null,
      };

  List<String> get benefits => switch (this) {
        LoyaltyClass.bronze => ['Basic Member'],
        LoyaltyClass.silver => [
            'Bonus Point',
            'Priority Promotion',
          ],
        LoyaltyClass.gold => [
            'Higher Bonus Point',
            'Special Promotion',
            'Birthday Reward',
          ],
        LoyaltyClass.platinum => [
            'Highest Bonus Point',
            'Exclusive Promotion',
            'Priority Service',
            'Special Gift',
          ],
      };
}

LoyaltyClass loyaltyClassFromPoints(int points) {
  if (points >= 7000) {
    return LoyaltyClass.platinum;
  }
  if (points >= 3000) {
    return LoyaltyClass.gold;
  }
  if (points >= 1000) {
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

  final progress = (points / nextClass.minPoints).clamp(0.0, 1.0);

  return LoyaltyProgress(
    currentClass: currentClass,
    nextClass: nextClass,
    progress: progress,
    percent: (progress * 100).round(),
  );
}
