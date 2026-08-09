import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/app/router/app_router.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Yelo Laundry',
      theme: AppTheme.light,
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

final themeModeProvider = Provider<ThemeMode>((ref) => ThemeMode.light);
