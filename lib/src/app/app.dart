import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme.dart';
import 'router.dart';

class ReverApp extends ConsumerWidget {
  const ReverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeProvider);
    final themeMode = ref.watch(themeModeProvider);

    final resolvedMode = switch (themeMode) {
      ReverThemeMode.system => ThemeMode.system,
      ReverThemeMode.light => ThemeMode.light,
      ReverThemeMode.dark => ThemeMode.dark,
    };

    return MaterialApp.router(
      title: 'Rever',
      debugShowCheckedModeBanner: false,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: resolvedMode,
      routerConfig: router,
    );
  }
}
