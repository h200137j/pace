import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/activity.dart';
import '../../../providers/activity_provider.dart';

class CreateActivitySheet extends ConsumerStatefulWidget {
  const CreateActivitySheet({super.key, this.existing});

  final Activity? existing;

  @override
  ConsumerState<CreateActivitySheet> createState() =>
      _CreateActivitySheetState();
}

class _CreateActivitySheetState extends ConsumerState<CreateActivitySheet> {
  late TextEditingController _nameCtrl;
  ActivityType _type = ActivityType.task;
  ActivityDifficulty _difficulty = ActivityDifficulty.medium;
  Color _color = AppColors.activityPalette.first;
  int _iconCodePoint = AppIcons.activityIcons.first.icon.codePoint;
  int _targetDaysMask = 127; // all days
  bool _requiresPhoto = false;
  DateTime? _challengeEndDate;
  bool _endDateUserSelected = false;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    if (a != null) {
      _type = a.type;
      _difficulty = a.difficulty;
      _color = Color(a.colorValue);
      _iconCodePoint = a.iconCodePoint;
      _targetDaysMask = a.targetDaysMask;
      _requiresPhoto = a.requiresPhoto;
      _challengeEndDate = a.endDate;
      _endDateUserSelected = a.endDateUserSelected;
    }

    if (a == null && _type == ActivityType.challenge) {
      _challengeEndDate = _defaultYearEnd();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existing != null;

  DateTime _defaultYearEnd() {
    final now = DateTime.now();
    return PaceDateUtils.toDateOnly(DateTime.utc(now.year, 12, 31));
  }

  DateTime _defaultChallengeStartDate() {
    final existing = widget.existing;
    if (existing?.startDate != null) {
      return PaceDateUtils.toDateOnly(existing!.startDate!);
    }
    if (existing != null) {
      return PaceDateUtils.toDateOnly(existing.createdAt);
    }
    return PaceDateUtils.toDateOnly(DateTime.now());
  }

  bool get _canEditEndDate {
    if (_type != ActivityType.challenge) return false;
    final existing = widget.existing;
    if (existing == null) return true;
    return existing.endDate == null;
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    if (_type == ActivityType.challenge && _challengeEndDate == null) {
      _challengeEndDate = _defaultYearEnd();
      _endDateUserSelected = false;
    }

    final notifier = ref.read(activityNotifierProvider.notifier);
    if (_isEditing) {
      final act = widget.existing!
        ..name = name
        ..type = _type
        ..difficulty = _difficulty
        ..colorValue = _color.toARGB32()
        ..iconCodePoint = _iconCodePoint
        ..targetDaysMask = _targetDaysMask
        ..requiresPhoto = _requiresPhoto;

      if (_type == ActivityType.challenge && act.endDate == null) {
        act
          ..startDate = _defaultChallengeStartDate()
          ..endDate = _challengeEndDate ?? _defaultYearEnd()
          ..endDateUserSelected = _endDateUserSelected;
      }

      await notifier.update(act);
    } else {
      await notifier.create(
        name: name,
        type: _type,
        difficulty: _difficulty,
        color: _color,
        iconCodePoint: _iconCodePoint,
        targetDaysMask: _targetDaysMask,
        requiresPhoto: _requiresPhoto,
        challengeEndDate: _type == ActivityType.challenge
            ? _challengeEndDate ?? _defaultYearEnd()
            : null,
        endDateUserSelected: _type == ActivityType.challenge && _endDateUserSelected,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              _isEditing ? 'Edit Activity' : 'New Activity',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),

            // ── Name ──────────────────────────────────────────────────────
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Activity name',
                hintText: 'e.g. Morning Run',
                prefixIcon: Icon(
                  IconData(_iconCodePoint, fontFamily: 'MaterialIcons'),
                  color: _color,
                ),
              ),
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),

            // ── Type Selector ─────────────────────────────────────────────
            Text('Type', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            _TypeSelector(
              selected: _type,
              onChanged: (t) {
                setState(() {
                  _type = t;
                  if (_type == ActivityType.challenge && _challengeEndDate == null) {
                    _challengeEndDate = _defaultYearEnd();
                    _endDateUserSelected = false;
                  }
                  if (_type != ActivityType.challenge) {
                    _challengeEndDate = null;
                    _endDateUserSelected = false;
                  }
                });
              },
            ),
            const SizedBox(height: 20),

            if (_type == ActivityType.challenge) ...[
              Text('Challenge End Date', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: Icon(Icons.event_rounded, color: _color),
                title: Text(
                  DateFormat('EEE, MMM d, yyyy').format(
                    PaceDateUtils.toDateOnly(_challengeEndDate ?? _defaultYearEnd()),
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  _canEditEndDate
                      ? (_endDateUserSelected
                          ? 'User selected'
                          : 'Default: end of current year')
                      : 'Locked after set',
                ),
                trailing: _canEditEndDate
                    ? const Icon(Icons.edit_calendar_rounded)
                    : const Icon(Icons.lock_outline_rounded),
                onTap: !_canEditEndDate
                    ? null
                    : () async {
                        final start = _defaultChallengeStartDate();
                        final minEndDate = start.add(const Duration(days: 6));
                        final maxEndDate = start.add(const Duration(days: 366));
                        var initial = PaceDateUtils.toDateOnly(
                          _challengeEndDate ?? _defaultYearEnd(),
                        );
                        if (initial.isBefore(minEndDate)) {
                          initial = minEndDate;
                        }
                        if (initial.isAfter(maxEndDate)) {
                          initial = maxEndDate;
                        }
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initial,
                          firstDate: minEndDate,
                          lastDate: maxEndDate,
                        );
                        if (picked == null) return;
                        setState(() {
                          _challengeEndDate = PaceDateUtils.toDateOnly(picked);
                          _endDateUserSelected = true;
                        });
                      },
              ),
              const SizedBox(height: 8),
              Text(
                _canEditEndDate
                    ? 'End date is immutable after the challenge is created.'
                    : 'This challenge end date is locked and cannot be changed.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Difficulty Selector ───────────────────────────────────────
            Text('Difficulty', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            _DifficultySelector(
              selected: _difficulty,
              onChanged: (d) => setState(() => _difficulty = d),
            ),
            const SizedBox(height: 8),
            Text(
              'Higher difficulty earns more XP per completion.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // ── Color Picker ──────────────────────────────────────────────
            Text('Color', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            _ColorPicker(
              selected: _color,
              onChanged: (c) => setState(() => _color = c),
            ),
            const SizedBox(height: 20),

            // ── Icon Picker ───────────────────────────────────────────────
            Text('Icon', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            _IconPicker(
              selected: _iconCodePoint,
              color: _color,
              onChanged: (cp) => setState(() => _iconCodePoint = cp),
            ),
            const SizedBox(height: 20),

            // ── Target Days ───────────────────────────────────────────────
            Text('Target Days', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            _DaySelector(
              mask: _targetDaysMask,
              color: _color,
              onChanged: (m) => setState(() => _targetDaysMask = m),
            ),
            const SizedBox(height: 20),

            // ── Photo Requirement ─────────────────────────────────────────
            SwitchListTile(
              value: _requiresPhoto,
              onChanged: (v) => setState(() => _requiresPhoto = v),
              title: const Text('Require daily photo'),
              subtitle: const Text('Capture progress for the montage'),
              secondary: Icon(Icons.camera_alt_rounded, color: _color),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: _color,
            ),
            const SizedBox(height: 28),

            // ── Submit ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(backgroundColor: _color),
                child: Text(
                  _isEditing ? 'Save Changes' : 'Create Activity',
                  style: TextStyle(
                    color: AppColors.onColor(_color),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChanged});

  final ActivityType selected;
  final ValueChanged<ActivityType> onChanged;

  @override
  Widget build(BuildContext context) {
    const types = [
      (type: ActivityType.task, label: 'Task', icon: Icons.check_circle_outline_rounded),
      (type: ActivityType.challenge, label: 'Challenge', icon: Icons.emoji_events_rounded),
      (type: ActivityType.focus, label: 'Focus', icon: Icons.local_fire_department_rounded),
    ];

    return Row(
      children: types.map((t) {
        final isSelected = t.type == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                selected: isSelected,
                showCheckmark: false,
                avatar: Icon(t.icon, size: 16),
                label: Text(t.label),
                onSelected: (_) => onChanged(t.type),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({
    required this.selected,
    required this.onChanged,
  });

  final ActivityDifficulty selected;
  final ValueChanged<ActivityDifficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [
      (difficulty: ActivityDifficulty.easy, label: 'Easy'),
      (difficulty: ActivityDifficulty.medium, label: 'Medium'),
      (difficulty: ActivityDifficulty.hard, label: 'Hard'),
      (difficulty: ActivityDifficulty.elite, label: 'Elite'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map(
            (option) => ChoiceChip(
              label: Text(option.label),
              selected: selected == option.difficulty,
              onSelected: (_) => onChanged(option.difficulty),
            ),
          )
          .toList(),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onChanged});

  final Color selected;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppColors.activityPalette.map((c) {
        final isSelected = c.toARGB32() == selected.toARGB32();
        return GestureDetector(
          onTap: () => onChanged(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 8)]
                  : [],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selected,
    required this.color,
    required this.onChanged,
  });

  final int selected;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: AppIcons.activityIcons.length,
        itemBuilder: (_, i) {
          final entry = AppIcons.activityIcons[i];
          final isSelected = entry.icon.codePoint == selected;
          return GestureDetector(
            onTap: () => onChanged(entry.icon.codePoint),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Icon(
                entry.icon,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.mask,
    required this.color,
    required this.onChanged,
  });

  final int mask;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: List.generate(7, (i) {
        final active = (mask >> i) & 1 == 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                final newMask = active ? mask & ~(1 << i) : mask | (1 << i);
                onChanged(newMask);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: active ? color : color.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: active ? AppColors.onColor(color) : color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
