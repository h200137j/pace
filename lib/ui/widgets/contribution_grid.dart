import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';

class ContributionGrid extends StatelessWidget {
  const ContributionGrid({
    super.key,
    required this.dateKeys,
    required this.color,
    this.weeks = 52,
  });

  final Set<String> dateKeys;
  final Color color;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = PaceDateUtils.toDateOnly(DateTime.now());

    // Build grid from (weeks * 7) days ago to today
    final totalDays = weeks * 7;
    final startDate = today.subtract(Duration(days: totalDays - 1));

    // Align to Monday
    final weekdayOffset = startDate.weekday - 1;
    final gridStart = startDate.subtract(Duration(days: weekdayOffset));
    final cells = PaceDateUtils.dateRange(gridStart, today);

    final months = <int, int>{};
    for (var i = 0; i < cells.length; i++) {
      final d = cells[i];
      if (d.day == 1) months[i] = d.month;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels
        SizedBox(
          height: 16,
          child: Row(
            children: List.generate(
              (cells.length / 7).ceil(),
              (col) {
                final cellIdx = col * 7;
                final month = months[cellIdx];
                return SizedBox(
                  width: 14,
                  child: month != null
                      ? Text(
                          PaceDateUtils.shortMonth(month),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 8,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekday labels
            Column(
              children: ['M', '', 'W', '', 'F', '', 'S'].map((label) {
                return SizedBox(
                  width: 12,
                  height: 14,
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 8,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 2),
            // Grid
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    (cells.length / 7).ceil(),
                    (col) => Column(
                      children: List.generate(7, (row) {
                        final idx = col * 7 + row;
                        if (idx >= cells.length) {
                          return const SizedBox(width: 12, height: 14);
                        }
                        final date = cells[idx];
                        final key = PaceDateUtils.toDateKey(date);
                        final done = dateKeys.contains(key);
                        final isFuture = date.isAfter(today);

                        return Tooltip(
                          message: isFuture
                              ? ''
                              : done
                                  ? '✓ $key'
                                  : key,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: isFuture
                                  ? Colors.transparent
                                  : done
                                      ? color
                                      : color.withOpacity(0.1),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
