import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/completion_provider.dart';

/// Shows the note prompt and saves the result. Call after a photo completion.
Future<void> showAndSaveNote(
  BuildContext context,
  WidgetRef ref, {
  required int activityId,
  required String dateKey,
  required Color color,
}) async {
  if (!context.mounted) return;
  final note = await _showNoteSheet(context, color: color);
  if (note == null || note.trim().isEmpty) return;
  if (!context.mounted) return;
  await ref
      .read(completionRepositoryProvider)
      .updateNote(activityId, dateKey, note);
}

Future<String?> _showNoteSheet(
  BuildContext context, {
  required Color color,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _NoteSheet(color: color),
  );
}

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({required this.color});
  final Color color;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + bottomInset),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'How did it go?',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Optional — shows up in your montage.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 3,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Add a note…',
              filled: true,
              fillColor: widget.color.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: widget.color.withValues(alpha: 0.25)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: widget.color.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: widget.color, width: 1.5),
              ),
              counterStyle: theme.textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Skip'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(context, _ctrl.text),
                style: FilledButton.styleFrom(
                    backgroundColor: widget.color),
                child: const Text('Save note'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
