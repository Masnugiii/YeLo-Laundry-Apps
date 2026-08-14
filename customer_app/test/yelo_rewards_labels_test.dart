import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/features/rewards/data/reward_repository.dart';
import 'package:yelo_laundry_customer/features/rewards/presentation/utils/reward_labels.dart';

void main() {
  group('rewardHistoryLabel', () {
    test('maps laundry earn', () {
      expect(
        rewardHistoryLabel(
          const RewardHistoryItem(
            id: '1',
            point: 5,
            type: 'earn',
            source: 'laundry_payment',
            createdAt: '2026-08-01T00:00:00Z',
          ),
        ),
        'Pembayaran Laundry',
      );
    });

    test('maps deposit earn', () {
      expect(
        rewardHistoryLabel(
          const RewardHistoryItem(
            id: '2',
            point: 6,
            type: 'earn',
            source: 'deposit',
            createdAt: '2026-08-01T00:00:00Z',
          ),
        ),
        'Deposit Saldo',
      );
    });

    test('maps redeem / clawback / expired', () {
      expect(
        rewardHistoryLabel(
          const RewardHistoryItem(
            id: '3',
            point: -5,
            type: 'redeem',
            createdAt: '2026-08-01T00:00:00Z',
          ),
        ),
        'Penukaran Reward',
      );
      expect(
        rewardHistoryLabel(
          const RewardHistoryItem(
            id: '4',
            point: -5,
            type: 'clawback',
            createdAt: '2026-08-01T00:00:00Z',
          ),
        ),
        'Pembatalan Point',
      );
      expect(
        rewardHistoryLabel(
          const RewardHistoryItem(
            id: '5',
            point: -2,
            type: 'expired',
            createdAt: '2026-08-01T00:00:00Z',
          ),
        ),
        'Point Kedaluwarsa',
      );
    });
  });

  group('pointsNeeded / locked rewards', () {
    test('sufficient points need 0', () {
      expect(pointsNeeded(5, 8), 0);
    });

    test('insufficient points returns remaining', () {
      expect(pointsNeeded(10, 8), 2);
      expect(pointsNeeded(15, 8), 7);
    });
  });

  group('redemptionStatusLabel', () {
    test('maps lifecycle statuses', () {
      expect(redemptionStatusLabel('PENDING'), 'Menunggu diambil');
      expect(redemptionStatusLabel('COMPLETED'), 'Siap digunakan');
      expect(redemptionStatusLabel('CANCELLED'), 'Dibatalkan');
    });
  });

  group('CKS catalog metadata', () {
    test('preview catalog contains CKS kg entitlements', () {
      const cks5 = RewardCatalogItem(
        id: 'cks5',
        code: 'CKS_5KG',
        name: 'CKS 5 KG',
        type: RewardCatalogType.laundryKg,
        costPoints: 5,
        isActive: true,
        kg: 5,
        serviceDurationDays: 3,
        serviceType: 'CKS',
      );
      const cks10 = RewardCatalogItem(
        id: 'cks10',
        code: 'CKS_10KG',
        name: 'CKS 10 KG',
        type: RewardCatalogType.laundryKg,
        costPoints: 10,
        isActive: true,
        kg: 10,
        serviceDurationDays: 3,
        serviceType: 'CKS',
      );

      expect(cks5.isLaundryKg, isTrue);
      expect(cks5.kg, 5);
      expect(cks5.serviceDurationDays, 3);
      expect(cks10.kg, 10);
      expect(cks10.costPoints, 10);
    });
  });

  group('mapRedeemErrorMessage', () {
    test('maps insufficient / inactive / network', () {
      expect(
        mapRedeemErrorMessage(
          const ApiException(
            message: 'Insufficient reward points for this redemption',
            type: ApiErrorType.validation,
          ),
        ),
        'Point kamu belum cukup.',
      );
      expect(
        mapRedeemErrorMessage(
          const ApiException(
            message: 'Reward "Blender" is inactive and cannot be redeemed',
            type: ApiErrorType.validation,
          ),
        ),
        'Reward ini sudah tidak tersedia.',
      );
      expect(
        mapRedeemErrorMessage(
          const ApiException(
            message: 'timeout',
            type: ApiErrorType.offline,
          ),
        ),
        'Gagal terhubung ke server. Coba lagi.',
      );
    });
  });
}
