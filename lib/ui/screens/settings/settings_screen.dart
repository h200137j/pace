import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
// import '../../../data/repositories/activity_repository.dart';
// import '../../../data/repositories/completion_repository.dart';
import '../../../data/services/export_service.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    ExportService makeExport(WidgetRef r) => ExportService(
          activityRepo: r.read(activityRepositoryProvider),
          completionRepo: r.read(completionRepositoryProvider),
        );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text(
              'Settings',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // ── Appearance ──────────────────────────────────────────────
              const _SectionHeader('Appearance'),
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                trailing: Switch(
                  value: themeState.mode == ThemeMode.dark,
                  onChanged: (_) => themeNotifier.toggleMode(),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        'Accent Color',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AppColors.activityPalette.map((c) {
                        final isSelected =
                            c.value == themeState.seedColor.value;
                        return GestureDetector(
                          onTap: () => themeNotifier.setSeedColor(c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                          color: c.withOpacity(0.6),
                                          blurRadius: 8)
                                    ]
                                  : [],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 32),

              // ── Data Portability ─────────────────────────────────────────
              const _SectionHeader('Data'),
              _SettingsTile(
                icon: Icons.upload_rounded,
                title: 'Export JSON Backup',
                subtitle: 'Saves all activities and completions',
                onTap: () async {
                  final export = makeExport(ref);
                  try {
                    await export.exportJson();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')),
                      );
                    }
                  }
                },
              ),
              _SettingsTile(
                icon: Icons.download_rounded,
                title: 'Import JSON Backup',
                subtitle: 'Restores from a previous backup',
                onTap: () async {
                  final export = makeExport(ref);
                  try {
                    await export.importJson();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Data imported successfully ✓')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Import failed: $e')),
                      );
                    }
                  }
                },
              ),
              _SettingsTile(
                icon: Icons.table_chart_rounded,
                title: 'Export CSV',
                subtitle: 'Exports completions as a spreadsheet',
                onTap: () async {
                  final export = makeExport(ref);
                  try {
                    await export.exportCsv();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')),
                      );
                    }
                  }
                },
              ),

              const Divider(height: 32),

              // ── About ─────────────────────────────────────────────────────
              const _SectionHeader('About'),
              const _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'Pace',
                subtitle: 'v1.0.0 — Built with Flutter & Isar',
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title,
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded) : null),
      onTap: onTap,
    );
  }
}
