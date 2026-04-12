import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';

class ContributionGrid extends StatelessWidget {
  const ContributionGrid({
    super.key,
    required this.dateKeys,
    required this.color,
    this.startDate,
    this.endDate,
  });

  final Set<String> dateKeys;
  final Color color;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = PaceDateUtils.toDateOnly(DateTime.now());

    // Use provided range or fallback to trailing 52 weeks
    final end = endDate ?? today;
    final start = startDate ?? end.subtract(const Duration(days: 363));

    // Align start to the beginning of that week (Monday)
    final weekdayOffset = start.weekday - 1;
    final gridStart = start.subtract(Duration(days: weekdayOffset));
    
    // We want the grid to always show the full range provided
    final cells = PaceDateUtils.dateRange(gridStart, end);

    final months = <int, int>{};
    for (var i = 0; i < cells.length; i++) {
      final d = cells[i];
      if (d.day == 1) months[i] = d.month;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekday labels (Left fixed column)
        Column(
          children: [
            const SizedBox(height: 16), // space for month labels
            const SizedBox(height: 4),  // space for spacing
            ...['M', '', 'W', '', 'F', '', 'S'].map((label) {
              return SizedBox(
                width: 14,
                height: 14,
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(width: 4),
        // Scrollable area
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
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
                // Grid cells
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    (cells.length / 7).ceil(),
                    (col) => Column(
                      children: List.generate(7, (row) {
                        final idx = col * 7 + row;
                        if (idx >= cells.length) {
                          return const SizedBox(width: 14, height: 14);
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
                                      : color.withValues(alpha: 0.1),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
