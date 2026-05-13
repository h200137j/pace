import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/challenge_easter_egg_service.dart';
import '../../core/services/motivational_quote_service.dart';
import '../../data/models/activity.dart';

Future<void> showEggFoundDialog(BuildContext context, String eggTitle) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return AlertDialog(
        title: const Text('Secret Egg Found!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00F2FF), Color(0xFF0066FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F2FF).withValues(alpha: 0.45),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.egg_alt_rounded, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              eggTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'You found this month\'s hidden egg.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('🥚  Sweet!'),
          ),
        ],
      );
    },
  );
}

Future<void> showMetaTrophyDialog(BuildContext context, Activity activity) async {
  final prefs = await SharedPreferences.getInstance();
  final prefKey = 'challenge_egg_meta_shown_${activity.id}';
  if (prefs.getBool(prefKey) ?? false) return;
  await prefs.setBool(prefKey, true);

  final quote = await MotivationalQuoteService.getCelebrationQuote();
  if (!context.mounted) return;

  final accent = Color(activity.colorValue);

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return AlertDialog(
        title: const Text('Meta Trophy Unlocked'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.75, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Icon(Icons.emoji_events_rounded, color: accent, size: 56),
            ),
            const SizedBox(height: 10),
            Text(
              EliteChallengeEasterEggService.metaTrophyTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'All 12 monthly easter eggs discovered.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(quote, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Legendary'),
          ),
        ],
      );
    },
  );
}
