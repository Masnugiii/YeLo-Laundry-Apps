import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yelo_laundry_erp/core/navigation/navigation_utils.dart';
import 'package:yelo_laundry_erp/shared/widgets/erp_app_bar.dart';
import 'package:yelo_laundry_erp/shared/widgets/flow_exit_scope.dart';

void main() {
  group('navigation_utils', () {
    testWidgets('navigateBack pops child route', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => context.push('/child'),
                  child: const Text('Open'),
                ),
              ),
            ),
            routes: [
              GoRoute(
                path: 'child',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(
                    leading: BackButton(
                      onPressed: () => navigateBack(context),
                    ),
                  ),
                  body: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(canNavigateBack(tester.element(find.byType(Scaffold).last)), isTrue);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
    });
  });

  group('FlowExitScope', () {
    testWidgets('invokes onExit when pop is blocked', (tester) async {
      var exitCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return FlowExitScope(
                onExit: () => exitCount++,
                child: Scaffold(
                  body: TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Try Pop'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Try Pop'));
      await tester.pumpAndSettle();

      expect(exitCount, 1);
    });
  });

  group('ErpAppBar', () {
    testWidgets('hides back button when showBackButton is false', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              appBar: ErpAppBar(
                title: 'Test',
                showBackButton: false,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byType(BackButton), findsNothing);
    });
  });
}
