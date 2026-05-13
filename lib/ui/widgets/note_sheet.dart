import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/completion_provider.dart';

Future<void> showAndSaveNote(
  BuildContext context,
  WidgetRef ref, {
  required int activityId,
  required String dateKey,
  required Color color,
}) async {
  if (!context.mounted) return;
  final note = await showDialog<String>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => _NoteDialog(color: color),
  );
  if (note == null || note.trim().isEmpty) return;
  if (!context.mounted) return;
  await ref
      .read(completionRepositoryProvider)
      .updateNote(activityId, dateKey, note);
}

/// Edit an existing note (pre-filled with current text).
Future<void> showEditNoteDialog(
  BuildContext context,
  WidgetRef ref, {
  required int activityId,
  required String dateKey,
  required Color color,
  String? initialNote,
}) async {
  if (!context.mounted) return;
  final note = await showDialog<String>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) =>
        _NoteDialog(color: color, initialNote: initialNote),
  );
  if (note == null) return; // cancelled — don't clear existing note
  if (!context.mounted) return;
  await ref
      .read(completionRepositoryProvider)
      .updateNote(activityId, dateKey, note.trim().isEmpty ? null : note);
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.color, this.initialNote});
  final Color color;
  final String? initialNote;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _ctrl = TextEditingController(text: widget.initialNote ?? '');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF13131E),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.15),
              blurRadius: 32,
              spreadRadius: 4,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_note_rounded,
                      color: widget.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How did it go?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Optional · shows up in your montage',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Text field ───────────────────────────────────────────────
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLines: 4,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Add a note…',
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: widget.color.withValues(alpha: 0.06),
                counterStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: widget.color.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: widget.color.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: widget.color, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Actions ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, null),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white.withValues(alpha: 0.6),
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _ctrl.text),
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
