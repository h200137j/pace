import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

class PaceApp extends ConsumerWidget {
  const PaceApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Pace',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.light(seedColor: themeState.seedColor),
      darkTheme: AppTheme.dark(seedColor: themeState.seedColor),
      routerConfig: router,
    );
  }
}
