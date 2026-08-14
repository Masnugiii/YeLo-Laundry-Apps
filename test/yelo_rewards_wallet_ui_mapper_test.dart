import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_erp/features/points/models/yelo_rewards_models.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_transaction.dart';
import 'package:yelo_laundry_erp/features/wallet/providers/wallet_providers.dart';

void main() {
  group('RewardCatalogItem.fromJson', () {
    test('maps backend catalog fields used by Customer App and Internal App', () {
      final item = RewardCatalogItem.fromJson({
        'id': 'cks-5',
        'code': 'CKS_5KG',
        'name': 'CKS 5 KG',
        'type': 'LAUNDRY_KG',
        'costPoints': 5,
        'isActive': true,
        'kg': 5,
        'entitlementKg': 5,
        'serviceType': 'CKS',
        'serviceDurationDays': 3,
        'durationDays': 3,
        'metadata': {'freeKg': 5, 'durationDays': 3},
        'pointRewardValueIdr': 5000,
      });

      expect(item.id, 'cks-5');
      expect(item.code, 'CKS_5KG');
      expect(item.name, 'CKS 5 KG');
      expect(item.type, RewardCatalogType.laundryKg);
      expect(item.costPoints, 5);
      expect(item.entitlementKg, 5);
      expect(item.durationDays, 3);
      expect(item.isActive, isTrue);
      expect(item.pointRewardValueIdr, 5000);
    });

    test('parses six catalog rewards without hard-coded UI names', () {
      const payload = [
        {'id': '1', 'code': 'CKS_5KG', 'name': 'CKS 5 KG', 'type': 'LAUNDRY_KG', 'costPoints': 5, 'kg': 5, 'serviceDurationDays': 3, 'isActive': true},
        {'id': '2', 'code': 'CKS_10KG', 'name': 'CKS 10 KG', 'type': 'LAUNDRY_KG', 'costPoints': 10, 'kg': 10, 'serviceDurationDays': 3, 'isActive': true},
        {'id': '3', 'code': 'BANTAL_PREMIUM', 'name': 'Bantal Premium', 'type': 'PHYSICAL_GOODS', 'costPoints': 5, 'isActive': true},
        {'id': '4', 'code': 'BLENDER', 'name': 'Blender', 'type': 'PHYSICAL_GOODS', 'costPoints': 10, 'isActive': true},
        {'id': '5', 'code': 'SPREI', 'name': 'Sprei', 'type': 'PHYSICAL_GOODS', 'costPoints': 10, 'isActive': true},
        {'id': '6', 'code': 'MAGIC_COM', 'name': 'Magic Com', 'type': 'PHYSICAL_GOODS', 'costPoints': 15, 'isActive': true},
      ];

      final catalog = payload
          .map((item) => RewardCatalogItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      expect(catalog, hasLength(6));
      expect(
        catalog.map((item) => item.code),
        containsAll([
          'CKS_5KG',
          'CKS_10KG',
          'BANTAL_PREMIUM',
          'BLENDER',
          'SPREI',
          'MAGIC_COM',
        ]),
      );
      expect(pointsNeeded(5, 711), 0);
      expect(pointsNeeded(15, 711), 0);
    });
  });

  group('mapWalletTransaction', () {
    test('maps deposit amount, type, date, status, and reference', () {
      final transaction = mapWalletTransaction(
        {
          'id': 'tx-1',
          'type': 'TOPUP',
          'amount': 250000,
          'balanceAfter': 313000,
          'referenceNumber': 'WLT-20260812-000001',
          'createdAt': '2026-08-12T10:00:00.000Z',
          'notes': 'Top up via Cash',
        },
        'customer-1',
      );

      expect(transaction.amount, 250000);
      expect(transaction.isCredit, isTrue);
      expect(transaction.type.label, 'Deposit');
      expect(transaction.referenceNumber, 'WLT-20260812-000001');
      expect(transaction.status, 'Berhasil');
    });

    test('maps laundry payment as debit', () {
      final transaction = mapWalletTransaction(
        {
          'id': 'tx-2',
          'type': 'PAYMENT',
          'amount': 35000,
          'balanceAfter': 278000,
          'createdAt': '2026-08-12T11:00:00.000Z',
        },
        'customer-1',
      );

      expect(transaction.amount, -35000);
      expect(transaction.isCredit, isFalse);
      expect(transaction.type.label, 'Pembayaran Laundry');
    });
  });
}
