import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/features/rewards/data/reward_repository.dart';

/// Human-readable labels for point ledger history.
String rewardHistoryLabel(RewardHistoryItem item) {
  final type = item.type.toLowerCase();
  final source = (item.source ?? '').toLowerCase();
  final description = (item.description ?? '').toLowerCase();

  if (type == 'clawback') return 'Pembatalan Point';
  if (type == 'expired') return 'Point Kedaluwarsa';
  if (type == 'program_reset') return 'Reset Program';
  if (type == 'redeem' || source == 'redeem') return 'Penukaran Reward';

  if (source == 'deposit' || description.contains('deposit')) {
    return 'Deposit Saldo';
  }
  if (source == 'laundry_payment' || description.contains('laundry')) {
    return 'Pembayaran Laundry';
  }
  if (source == 'mission') return 'Misi (histori)';
  if (source == 'manual_bonus') return 'Bonus Manual';

  final rawDescription = item.description?.trim();
  if (rawDescription != null && rawDescription.isNotEmpty) {
    return rawDescription;
  }

  if (type == 'earn') return 'Perolehan Point';
  return item.type.replaceAll('_', ' ');
}

String rewardHistoryPointsLabel(RewardHistoryItem item) {
  final amount = item.point.abs();
  final isCredit = item.point >= 0 && item.type.toLowerCase() == 'earn';
  final type = item.type.toLowerCase();
  if (type == 'earn' || isCredit) {
    return '+$amount Point';
  }
  return '-$amount Point';
}

String redemptionStatusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return 'Menunggu diambil';
    case 'COMPLETED':
      return 'Siap digunakan';
    case 'CANCELLED':
      return 'Dibatalkan';
    default:
      return status;
  }
}

String mapRedeemErrorMessage(Object error) {
  if (error is ApiException) {
    final message = error.message.toLowerCase();
    if (message.contains('insufficient') || message.contains('belum cukup')) {
      return 'Point kamu belum cukup.';
    }
    if (message.contains('inactive') || message.contains('tidak tersedia')) {
      return 'Reward ini sudah tidak tersedia.';
    }
    if (message.contains('expired') || message.contains('kedaluwarsa')) {
      return 'Point yang kamu miliki sudah kedaluwarsa.';
    }
    if (error.type == ApiErrorType.timeout ||
        error.type == ApiErrorType.offline) {
      return 'Gagal terhubung ke server. Coba lagi.';
    }
    if (error.message.trim().isNotEmpty) {
      return error.message;
    }
  }
  return 'Gagal menukar reward. Coba lagi.';
}

int pointsNeeded(int costPoints, int currentPoints) {
  final needed = costPoints - currentPoints;
  return needed > 0 ? needed : 0;
}
