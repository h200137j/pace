import 'package:flutter/material.dart';

import '../../core/utils/streak_calculator.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({
    super.key,
    required this.result,
    this.compact = false,
  });

  final StreakResult result;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streakActive = result.current > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: streakActive
            ? theme.colorScheme.tertiaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            streakActive ? '🔥' : '○',
            style: TextStyle(fontSize: compact ? 12 : 14),
          ),
          const SizedBox(width: 4),
          Text(
            '${result.current}',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: streakActive
                  ? theme.colorScheme.onTertiaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 2),
            Text(
              'streak',
              style: theme.textTheme.labelSmall?.copyWith(
                color: streakActive
                    ? theme.colorScheme.onTertiaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
