import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_erp/app/app.dart';
import 'package:yelo_laundry_erp/features/auth/presentation/login_screen.dart';
import 'package:yelo_laundry_erp/features/auth/presentation/otp_screen.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/presentation/binatu_monitoring_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/owner_dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches and navigates from splash to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    expect(find.byType(MaterialApp), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('Owner dashboard does not overflow on small screens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OwnerDashboardScreen())),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    expect(find.byType(OwnerDashboardScreen), findsOneWidget);
  });

  testWidgets('Monitoring Binatu does not overflow on small screens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: BinatuMonitoringScreen(showBackButton: false)),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    expect(find.byType(BinatuMonitoringScreen), findsOneWidget);
    expect(find.text('Monitoring Binatu'), findsOneWidget);
  });

  testWidgets('OTP screen does not overflow on small screens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OtpScreen(phoneNumber: '+62 812 3456 7890')),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
