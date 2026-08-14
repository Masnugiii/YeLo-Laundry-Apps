import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_customer/core/membership/membership_level.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/widgets/dev_preview_entry_button.dart';
import 'package:yelo_laundry_customer/features/claim_point/models/claim_mission.dart';
import 'package:yelo_laundry_customer/features/claim_point/presentation/widgets/mission_card.dart';
import 'package:yelo_laundry_customer/features/claim_point/presentation/widgets/yelo_point_balance_card.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/membership_wallet_card.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/pending_payment_card.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const smallPhone = Size(320, 640);

  Future<void> pumpSmall(
    WidgetTester tester,
    Widget child, {
    Size size = smallPhone,
    bool scrollable = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final body = scrollable
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          )
        : Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: body),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  group('layout overflow — narrow screens', () {
    testWidgets('MissionCard with long CTA does not overflow', (tester) async {
      await pumpSmall(
        tester,
        MissionCard(
          mission: const ClaimMission(
            id: 'm-1',
            type: MissionType.linkAccount,
            title: 'Hubungkan Akun Media Sosial Kamu Sekarang',
            description:
                'Lengkapi profil dan hubungkan akun untuk mendapatkan bonus poin tambahan.',
            rewardPoints: 12500,
            status: MissionStatus.available,
            ctaLabel: 'Lengkapi Profil',
          ),
          onAction: () {},
        ),
      );
    });

    testWidgets('YeloPointBalanceCard does not overflow', (tester) async {
      await pumpSmall(
        tester,
        const YeloPointBalanceCard(
          level: MembershipLevel.platinum,
          pointsLabel: '12.500.000 Point',
          memberSerialNumber: 'CUS-0004827',
        ),
      );
    });

    testWidgets('MembershipWalletCard does not overflow', (tester) async {
      await pumpSmall(
        tester,
        MembershipWalletCard(
          level: MembershipLevel.gold,
          balanceText: 'Rp 15.250.000',
          pointsText: '1.250.000',
          balanceVisible: true,
          onToggleBalanceVisibility: () {},
          memberSerialNumber: 'CUS-0004827',
        ),
      );
    });

    testWidgets('MembershipWalletCard fits fixed AspectRatio on narrow width',
        (tester) async {
      await pumpSmall(
        tester,
        MembershipWalletCard(
          level: MembershipLevel.gold,
          balanceText: 'Rp 15.250.000',
          pointsText: '1.250.000',
          balanceVisible: true,
          onToggleBalanceVisibility: () {},
          memberSerialNumber: 'CUS-0004827',
        ),
        scrollable: false,
      );
    });

    testWidgets('YeloPointBalanceCard fits fixed AspectRatio on narrow width',
        (tester) async {
      await pumpSmall(
        tester,
        const YeloPointBalanceCard(
          level: MembershipLevel.platinum,
          pointsLabel: '12.500.000 Point',
          memberSerialNumber: 'CUS-0004827',
        ),
        scrollable: false,
      );
    });

    testWidgets('DevPreviewEntryButton compact does not overflow', (tester) async {
      await pumpSmall(
        tester,
        const SizedBox(
          width: 280,
          child: DevPreviewEntryButton(compact: true),
        ),
      );
    });

    testWidgets('PendingPaymentCard natural height fits dashboard carousel default',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const order = OrderItem(
        id: 'order-1',
        orderNumber: 'ORD-2026-0004827',
        orderStatus: 'PENDING_PAYMENT',
        paymentStatus: 'pending',
        grandTotal: 152500,
        orderDate: '2026-08-11T10:00:00.000Z',
        pickupRequired: true,
        deliveryRequired: true,
        serviceSummary: 'Cuci Kering + Setrika Premium',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 347.4,
              child: PendingPaymentCard(
                order: order,
                amountText: 'Rp 152.500',
                onStatusTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      final box = tester.renderObject(find.byType(PendingPaymentCard)) as RenderBox;
      expect(box.size.height, lessThan(244));
    });
  });
}
