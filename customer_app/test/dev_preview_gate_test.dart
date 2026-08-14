import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/widgets/dev_preview_entry_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    DevPreviewGate.deactivate();
    DevPreviewGate.resetForProduction();
  });

  group('DevPreviewGate', () {
    test('isAvailable follows kDebugMode', () {
      expect(DevPreviewGate.isAvailable, kDebugMode);
    });

    test('isActive is false before activation', () {
      expect(DevPreviewGate.isActive, isFalse);
    });

    test('activation only works in debug mode', () {
      DevPreviewGate.activate();
      expect(DevPreviewGate.isActive, kDebugMode);
    });

    test('deactivate clears active state', () {
      DevPreviewGate.activate();
      DevPreviewGate.deactivate();
      expect(DevPreviewGate.isActive, isFalse);
    });
  });

  group('DevPreviewEntryButton', () {
    testWidgets('renders only when dev preview is available', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DevPreviewEntryButton(compact: true),
            ),
          ),
        ),
      );
      await tester.pump();

      if (kDebugMode) {
        expect(find.text('Preview Dashboard (Dev)'), findsOneWidget);
      } else {
        expect(find.byType(DevPreviewEntryButton), findsOneWidget);
        expect(find.text('Preview Dashboard (Dev)'), findsNothing);
      }
    });
  });
}
