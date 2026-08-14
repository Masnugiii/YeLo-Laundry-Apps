import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_order_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/back_to_dashboard_link.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_shell_tab_provider.dart';

void main() {
  testWidgets('DashboardAppBarBackButton sets shell tab index to 0', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(dashboardShellTabProvider.notifier).setTab(2);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(leading: DashboardAppBarBackButton()),
          ),
        ),
      ),
    );

    expect(container.read(dashboardShellTabProvider), 2);
    expect(find.text('Kembali ke Dashboard'), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pump();

    expect(container.read(dashboardShellTabProvider), 0);
  });

  testWidgets('DashboardAppBarBackButton resets binatu shell tab index', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(binatuDashboardTabProvider.notifier).setTab(3);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(leading: DashboardAppBarBackButton()),
          ),
        ),
      ),
    );

    expect(container.read(binatuDashboardTabProvider), 3);

    await tester.tap(find.byType(BackButton));
    await tester.pump();

    expect(container.read(binatuDashboardTabProvider), 0);
  });
}
