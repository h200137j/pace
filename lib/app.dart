import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'router.dart';

class PaceApp extends ConsumerWidget {
  const PaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Pace',
      debugShowCheckedModeBanner: false,
      themeMode: themeState.mode,
      theme: AppTheme.light(seedColor: themeState.seedColor),
      darkTheme: AppTheme.dark(seedColor: themeState.seedColor),
      routerConfig: appRouter,
    );
  }
}
