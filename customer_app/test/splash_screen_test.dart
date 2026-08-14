import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yelo_laundry_customer/features/auth/presentation/widgets/dev_preview_entry_button.dart';
import 'package:yelo_laundry_customer/features/splash/presentation/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SplashScreen single loading screen', () {
    testWidgets(
        'renders only YeLo splash logo on brand blue — no spinner or Dev Preview',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      await tester.pump();
      expect(tester.takeException(), isNull);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(DevPreviewEntryButton), findsNothing);
      expect(find.textContaining('Preview Dashboard'), findsNothing);
      expect(find.textContaining('Dev'), findsNothing);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF033B8E));

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        SplashScreen.splashLogoAsset,
      );
      expect(image.fit, BoxFit.contain);
    });
  });
}
