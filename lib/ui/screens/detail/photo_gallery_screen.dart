import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/photo_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/completion.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/ui_state_provider.dart';
import '../../widgets/note_sheet.dart';

class PhotoGalleryScreen extends ConsumerWidget {
  const PhotoGalleryScreen({super.key, required this.activityId});

  final int activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(activityByIdProvider(activityId));
    final completionsAsync =
        ref.watch(completionsForActivityProvider(activityId));

    final accentColor = activityAsync.hasValue
        ? Color(activityAsync.value!.colorValue)
        : const Color(0xFF00F2FF);

    final photos = (completionsAsync.valueOrNull ?? [])
        .where((c) => c.photoPath != null)
        .toList()
      ..sort((a, b) => b.dateKey.compareTo(a.dateKey)); // newest first

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(
              activityAsync.valueOrNull?.name ?? 'Photo Journal',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),

          if (photos.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No photos yet.',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _PhotoEntryCard(
                    completion: photos[i],
                    activityId: activityId,
                    accentColor: accentColor,
                  ),
                  childCount: photos.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Single photo entry ─────────────────────────────────────────────────────

class _PhotoEntryCard extends ConsumerStatefulWidget {
  const _PhotoEntryCard({
    required this.completion,
    required this.activityId,
    required this.accentColor,
  });

  final Completion completion;
  final int activityId;
  final Color accentColor;

  @override
  ConsumerState<_PhotoEntryCard> createState() => _PhotoEntryCardState();
}

class _PhotoEntryCardState extends ConsumerState<_PhotoEntryCard> {
  bool _replacing = false;

  Future<void> _replacePhoto() async {
    ref.read(createSheetOpenProvider.notifier).state = true;
    final source = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhotoSourceSheet(color: widget.accentColor),
    );
    ref.read(createSheetOpenProvider.notifier).state = false;

    if (source == null || !mounted) return;

    setState(() => _replacing = true);
    try {
      final file = await PhotoService.instance.pickImage(fromCamera: source);
      if (file == null || !mounted) return;

      final newPath = await PhotoService.instance.saveImageToAppStorage(
        file,
        widget.completion.dateKey,
        widget.activityId,
      );

      // Delete old photo then update record.
      final oldPath = widget.completion.photoPath;
      await ref
          .read(completionRepositoryProvider)
          .updatePhoto(widget.activityId, widget.completion.dateKey, newPath);
      if (oldPath != null) {
        await PhotoService.instance.deleteImage(oldPath);
      }
    } finally {
      if (mounted) setState(() => _replacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.completion;
    final date = PaceDateUtils.fromDateKey(c.dateKey);
    final dateLabel = DateFormat('EEEE, d MMMM yyyy').format(date);
    final hasNote = c.note != null && c.note!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF13131E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: widget.accentColor.withValues(alpha: 0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ──────────────────────────────────────────────────
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: _replacing
                      ? Container(
                          color: Colors.black,
                          child: Center(
                            child: CircularProgressIndicator(
                                color: widget.accentColor),
                          ),
                        )
                      : Image.file(
                          File(c.photoPath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                ),
                // Date overlay bottom-left
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 24, 14, 10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                    child: Text(
                      dateLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(blurRadius: 8, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Note + actions ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasNote)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        c.note!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.45,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      _ActionChip(
                        icon: Icons.camera_alt_rounded,
                        label: 'Edit photo',
                        color: widget.accentColor,
                        onTap: _replacing ? null : _replacePhoto,
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Icons.edit_note_rounded,
                        label: hasNote ? 'Edit note' : 'Add note',
                        color: widget.accentColor,
                        onTap: () => showEditNoteDialog(
                          context,
                          ref,
                          activityId: widget.activityId,
                          dateKey: c.dateKey,
                          color: widget.accentColor,
                          initialNote: c.note,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small helpers ──────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text('Replace Photo', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.camera_alt_rounded, color: color),
            title: const Text('Take new photo'),
            onTap: () => Navigator.pop(context, true),
          ),
          ListTile(
            leading: Icon(Icons.photo_library_rounded, color: color),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(context, false),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
