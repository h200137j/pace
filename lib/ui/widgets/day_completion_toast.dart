import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/activity.dart';
import '../../core/services/challenge_easter_egg_service.dart';
import '../../core/services/gamification_service.dart';
import '../../core/services/motivational_quote_service.dart';
import '../../providers/gamification_settings_provider.dart';
import 'app_snackbar.dart';

Future<void> showDayCompletionToast(
  BuildContext context,
  WidgetRef ref,
  XpAwardOutcome outcome,
  {
  Activity? activity,
  String? dateKey,
  }
) async {
  final settings = ref.read(gamificationSettingsProvider);
  if (!settings.showRewardToasts) return;

  final unlockParts = <String>[];
  if (outcome.unlockedBadgeKeys.isNotEmpty) {
    unlockParts.add('${outcome.unlockedBadgeKeys.length} badge');
  }
  if (outcome.unlockedTrophyKeys.isNotEmpty) {
    unlockParts.add('${outcome.unlockedTrophyKeys.length} trophy');
  }
  final unlockText = unlockParts.isEmpty
      ? ''
      : ' • Unlocked ${unlockParts.join(', ')}';

  final quote = await MotivationalQuoteService.getNextQuote();

  final shouldShowXp = outcome.awardedXp > 0;
  final prefix = settings.enableRewardAnimations && unlockParts.isNotEmpty
      ? '✨ '
      : '';
  final firstLine = shouldShowXp
      ? '$prefix+${outcome.awardedXp} XP$unlockText'
      : '$prefix Day completed$unlockText';

  final eggTitle = shouldShowXp && activity != null && dateKey != null
      ? EliteChallengeEasterEggService.unlockedEggTitleForDate(
          activity: activity,
          dateKey: dateKey,
        )
      : null;

  final message = eggTitle == null
      ? '$firstLine\n$quote'
      : '$firstLine\n$quote\n🥚 Secret Egg: $eggTitle';

  showAppSnackBar(
    context,
    message,
    duration: const Duration(milliseconds: 2800),
  );
}