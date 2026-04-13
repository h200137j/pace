import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ui/screens/analytics/analytics_screen.dart';
import 'ui/screens/detail/activity_detail_screen.dart';
import 'ui/screens/detail/montage_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/settings/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _analyticsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'analytics');
final _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (ctx, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
            ),
            GoRoute(
              path: '/activity/:id',
              builder: (_, state) => ActivityDetailScreen(
                activityId: int.parse(state.pathParameters['id']!),
              ),
              routes: [
                GoRoute(
                  path: 'montage',
                  builder: (_, state) => MontageScreen(
                    activityId: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _analyticsNavigatorKey,
          routes: [
            GoRoute(
              path: '/analytics',
              builder: (_, __) => const AnalyticsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;
  final Color _accentColor = const Color(0xFF00F2FF); // Electric Cyan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      extendBody: true,
      body: Stack(
        children: [
          // ── Depth Background ──────────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A0F),
                    Color(0xFF1A1A2A),
                  ],
                ),
              ),
            ),
          ),
          
          // ── Background Texture ────────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(color: Colors.white.withValues(alpha: 0.04)),
            ),
          ),

          // ── Page Content ──────────────────────────────────────────────────
          shell,

          // ── Bottom Navigation Bar ────────────────────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: _CustomBottomNav(
              selectedIndex: shell.currentIndex,
              onTap: (index) => shell.goBranch(
                index,
                initialLocation: index == shell.currentIndex,
              ),
              accentColor: _accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomBottomNav extends StatelessWidget {
  const _CustomBottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.accentColor,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavButton(
                icon: Icons.home_filled,
                label: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
                accentColor: accentColor,
              ),
              _NavButton(
                icon: Icons.bar_chart_rounded,
                label: 'Stats',
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
                accentColor: accentColor,
              ),
              _NavButton(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: selectedIndex == 2,
                onTap: () => onTap(2),
                accentColor: accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.4),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
