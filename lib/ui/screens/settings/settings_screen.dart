import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
// import '../../../data/repositories/activity_repository.dart';
// import '../../../data/repositories/completion_repository.dart';
import '../../../data/services/export_service.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/gamification_settings_provider.dart';
import '../../../providers/gamification_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/app_snackbar.dart';

final appInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final gmSettings = ref.watch(gamificationSettingsProvider);
    final gmSettingsNotifier = ref.read(gamificationSettingsProvider.notifier);
    final appInfo = ref.watch(appInfoProvider);

    ExportService makeExport(WidgetRef r) => ExportService(
          activityRepo: r.read(activityRepositoryProvider),
          completionRepo: r.read(completionRepositoryProvider),
          gamificationRepo: r.read(gamificationRepositoryProvider),
        );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Settings',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // ── Appearance ──────────────────────────────────────────────
              const _SectionHeader('Appearance'),
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
                            c.toARGB32() == themeState.seedColor.toARGB32();
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
                                      color: c.withValues(alpha: 0.6),
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
                      showAppSnackBar(context, 'Export failed: $e');
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
                      showAppSnackBar(context, 'Data imported successfully ✓');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showAppSnackBar(context, 'Import failed: $e');
                    }
                  }
                },
              ),
              const Divider(height: 32),

              // ── Gamification ────────────────────────────────────────────
              const _SectionHeader('Gamification'),
              _SettingsTile(
                icon: Icons.military_tech_rounded,
                title: 'Achievement Badges',
                subtitle: 'View badge progress and unlocks',
                onTap: () => context.push('/settings/badges'),
              ),
              _SettingsTile(
                icon: Icons.emoji_events_rounded,
                title: 'Trophies',
                subtitle: 'Track your major milestones',
                onTap: () => context.push('/settings/trophies'),
              ),
              SwitchListTile(
                value: gmSettings.showRewardToasts,
                onChanged: gmSettingsNotifier.setShowRewardToasts,
                title: const Text('Show Reward Toasts'),
                subtitle: const Text('Display +XP and unlock notifications'),
              ),
              SwitchListTile(
                value: gmSettings.enableRewardAnimations,
                onChanged: gmSettingsNotifier.setEnableRewardAnimations,
                title: const Text('Enable Reward Animations'),
                subtitle: const Text('Use richer unlock celebration effects'),
              ),
              SwitchListTile(
                value: gmSettings.showEasterEggHints,
                onChanged: gmSettingsNotifier.setShowEasterEggHints,
                title: const Text('Show Easter Egg Radar Hints'),
                subtitle:
                    const Text('Reveal subtle monthly clues after day 20 for elite challenges'),
              ),

              const Divider(height: 32),

              // ── About ─────────────────────────────────────────────────────
              const _SectionHeader('About'),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'Pace',
                subtitle: appInfo.when(
                  data: (info) => 'v${info.version}+${info.buildNumber} — Built with Flutter & Isar',
                  loading: () => 'Version loading…',
                  error: (_, __) => 'Version unavailable — Built with Flutter & Isar',
                ),
              ),
              const SizedBox(height: 140),
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
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
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
      trailing: onTap != null ? const Icon(Icons.chevron_right_rounded) : null,
      onTap: onTap,
    );
  }
}
