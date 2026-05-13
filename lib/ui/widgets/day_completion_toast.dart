import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/activity.dart';
import '../../core/services/challenge_easter_egg_service.dart';
import '../../core/services/gamification_service.dart';
import '../../core/services/motivational_quote_service.dart';
import '../../providers/completion_provider.dart';
import '../../providers/gamification_settings_provider.dart';
import 'egg_celebration.dart';

const _kToastDuration = Duration(milliseconds: 3800);

Future<void> showDayCompletionToast(
  BuildContext context,
  WidgetRef ref,
  XpAwardOutcome outcome, {
  Activity? activity,
  String? dateKey,
}) async {
  final settings = ref.read(gamificationSettingsProvider);

  // Detect egg regardless of toast setting — celebrations always show.
  final eggTitle = activity != null && dateKey != null
      ? EliteChallengeEasterEggService.unlockedEggTitleForDate(
          activity: activity,
          dateKey: dateKey,
        )
      : null;

  // ── XP overlay (respects toast setting) ───────────────────────────────
  if (settings.showRewardToasts && context.mounted) {
    final unlockParts = <String>[];
    if (outcome.unlockedBadgeKeys.isNotEmpty) {
      unlockParts.add(
        '${outcome.unlockedBadgeKeys.length} badge${outcome.unlockedBadgeKeys.length > 1 ? 's' : ''} unlocked',
      );
    }
    if (outcome.unlockedTrophyKeys.isNotEmpty) {
      unlockParts.add(
        '${outcome.unlockedTrophyKeys.length} troph${outcome.unlockedTrophyKeys.length > 1 ? 'ies' : 'y'} unlocked',
      );
    }

    final quote = await MotivationalQuoteService.getNextQuote();
    if (!context.mounted) return;

    _showXpToast(
      context,
      activityName: activity?.name ?? '',
      activityColor:
          activity != null ? Color(activity.colorValue) : const Color(0xFF00F2FF),
      xp: outcome.awardedXp,
      unlockLines: unlockParts,
      quote: quote,
      showSparkle:
          settings.enableRewardAnimations && unlockParts.isNotEmpty,
    );
  }

  // ── Egg celebration dialogs (always, even if toasts disabled) ──────────
  if (eggTitle == null || !context.mounted) return;

  await showEggFoundDialog(context, eggTitle);
  if (!context.mounted) return;

  final allDateKeys = await ref
      .read(completionRepositoryProvider)
      .getDateKeysForActivity(activity!.id);
  final eggProgress = EliteChallengeEasterEggService.evaluate(
    activity: activity,
    completionDateKeys: allDateKeys,
  );

  if (eggProgress.metaTrophyUnlocked && context.mounted) {
    await showMetaTrophyDialog(context, activity);
  }
}

// ── Overlay entry ──────────────────────────────────────────────────────────

void _showXpToast(
  BuildContext context, {
  required String activityName,
  required Color activityColor,
  required int xp,
  required List<String> unlockLines,
  required String quote,
  required bool showSparkle,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _XpToastOverlay(
      activityName: activityName,
      activityColor: activityColor,
      xp: xp,
      unlockLines: unlockLines,
      quote: quote,
      showSparkle: showSparkle,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

// ── Animated overlay widget ────────────────────────────────────────────────

class _XpToastOverlay extends StatefulWidget {
  const _XpToastOverlay({
    required this.activityName,
    required this.activityColor,
    required this.xp,
    required this.unlockLines,
    required this.quote,
    required this.showSparkle,
    required this.onDone,
  });

  final String activityName;
  final Color activityColor;
  final int xp;
  final List<String> unlockLines;
  final String quote;
  final bool showSparkle;
  final VoidCallback onDone;

  @override
  State<_XpToastOverlay> createState() => _XpToastOverlayState();
}

class _XpToastOverlayState extends State<_XpToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  static const _animDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _animDuration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween(begin: 0.82, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _ctrl.forward();

    Future.delayed(_kToastDuration - _animDuration, () {
      if (mounted) {
        _ctrl.reverse().then((_) => widget.onDone());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: const Alignment(0, -0.15),
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              child: _XpToastCard(
                activityName: widget.activityName,
                activityColor: widget.activityColor,
                xp: widget.xp,
                unlockLines: widget.unlockLines,
                quote: widget.quote,
                showSparkle: widget.showSparkle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Card UI ────────────────────────────────────────────────────────────────

class _XpToastCard extends StatelessWidget {
  const _XpToastCard({
    required this.activityName,
    required this.activityColor,
    required this.xp,
    required this.unlockLines,
    required this.quote,
    required this.showSparkle,
  });

  final String activityName;
  final Color activityColor;
  final int xp;
  final List<String> unlockLines;
  final String quote;
  final bool showSparkle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFF13131E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: activityColor.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: activityColor.withValues(alpha: 0.22),
            blurRadius: 40,
            spreadRadius: 6,
          ),
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Activity name chip ─────────────────────────────────────────
          if (activityName.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: activityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: activityColor.withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                activityName,
                style: TextStyle(
                  color: activityColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: 16),

          // ── XP amount ──────────────────────────────────────────────────
          Text(
            xp > 0 ? '${showSparkle ? '✦ ' : ''}+$xp XP' : 'Day Complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: xp > 0 ? 34 : 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),

          // ── Unlock lines ───────────────────────────────────────────────
          if (unlockLines.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final line in unlockLines)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '• $line',
                  style: TextStyle(
                    color: activityColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],

          // ── Quote ──────────────────────────────────────────────────────
          if (quote.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              height: 0.5,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 12),
            Text(
              quote,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
