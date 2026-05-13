import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/progress_ring.dart';

const kOnboardingSeenKey = 'onboarding_seen';

const _bg = Color(0xFF0A0A0F);
const _cyan = Color(0xFF00F2FF);
const _orange = Color(0xFFF97316);
const _teal = Color(0xFF00897B);
const _purple = Color(0xFF8B5CF6);
const _violet = Color(0xFFA855F7);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.isFromSettings = false});
  final bool isFromSettings;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;
  static const _total = 5;

  late final AnimationController _glowCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _xpCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));
    _xpCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _glowCtrl.dispose();
    _ringCtrl.dispose();
    _xpCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int p) {
    setState(() => _page = p);
    if (p == 2) {
      _ringCtrl.reset();
      Future.delayed(const Duration(milliseconds: 350),
          () { if (mounted) _ringCtrl.forward(); });
    }
    if (p == 3) {
      _xpCtrl.reset();
      Future.delayed(const Duration(milliseconds: 350),
          () { if (mounted) _xpCtrl.forward(); });
    }
  }

  Future<void> _finish() async {
    if (!widget.isFromSettings) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kOnboardingSeenKey, true);
    }
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _next() {
    if (_page < _total - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final safePad = MediaQuery.of(context).padding;
    final isLast = _page == _total - 1;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Dot grid
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGrid(color: Colors.white.withValues(alpha: 0.03)),
            ),
          ),

          // Pages
          PageView(
            controller: _pageCtrl,
            onPageChanged: _onPageChanged,
            physics: const ClampingScrollPhysics(),
            children: [
              _WelcomePage(ctrl: _glowCtrl),
              const _ActivitiesPage(),
              _CheckInsPage(ctrl: _ringCtrl),
              _LevelUpPage(ctrl: _xpCtrl),
              const _ReadyPage(),
            ],
          ),

          // Skip / Close
          Positioned(
            top: safePad.top + 8,
            right: 12,
            child: TextButton(
              onPressed: _finish,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.38),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                widget.isFromSettings ? 'Close' : 'Skip',
                style:
                    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          // Bottom: dots + CTA
          Positioned(
            left: 24,
            right: 24,
            bottom: safePad.bottom + 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_total, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active
                            ? _cyan
                            : Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                    color: _cyan.withValues(alpha: 0.5),
                                    blurRadius: 8)
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // CTA
                GestureDetector(
                  onTap: _next,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLast
                            ? [_cyan, Color.lerp(_cyan, _purple, 0.4)!]
                            : [
                                _cyan.withValues(alpha: 0.12),
                                _cyan.withValues(alpha: 0.06)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _cyan.withValues(alpha: isLast ? 0.7 : 0.2),
                        width: 1,
                      ),
                      boxShadow: isLast
                          ? [
                              BoxShadow(
                                color: _cyan.withValues(alpha: 0.25),
                                blurRadius: 24,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        isLast
                            ? (widget.isFromSettings ? 'Done' : 'Start Building')
                            : 'Continue',
                        style: GoogleFonts.inter(
                          color: isLast ? _bg : _cyan,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 1: Welcome ──────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.ctrl});
  final AnimationController ctrl;

  @override
  Widget build(BuildContext context) {
    final glow = Tween<double>(begin: 0.25, end: 0.65)
        .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));
    final scaleAnim = Tween<double>(begin: 0.94, end: 1.06)
        .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: ctrl,
              builder: (_, __) => Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow halo
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _cyan.withValues(alpha: glow.value * 0.3),
                          blurRadius: 80,
                          spreadRadius: 30,
                        ),
                        BoxShadow(
                          color: _purple.withValues(alpha: glow.value * 0.18),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Orbit ring
                  Container(
                    width: 136,
                    height: 136,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _cyan.withValues(alpha: glow.value * 0.22),
                        width: 1,
                      ),
                    ),
                  ),
                  // App logo
                  Transform.scale(
                    scale: scaleAnim.value,
                    child: Container(
                      width: 116,
                      height: 116,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _cyan.withValues(alpha: glow.value * 0.55),
                            blurRadius: 40,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: _purple.withValues(alpha: glow.value * 0.3),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          width: 116,
                          height: 116,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 38),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [_cyan, _purple],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(b),
              child: Text(
                'PACE',
                style: GoogleFonts.outfit(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 12,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Build streaks. Break limits.\nSet the pace.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: _cyan.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: _cyan.withValues(alpha: 0.18)),
              ),
              child: Text(
                'Your habits  •  Your rules  •  No cloud required',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _cyan.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }
}

// ─── Page 2: Activities ───────────────────────────────────────────────────────

class _ActivitiesPage extends StatelessWidget {
  const _ActivitiesPage();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, 72, 22, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageHeader(
              number: '01',
              title: 'Track What\nMatters',
              subtitle:
                  'Habits, challenges, or deep work — all in one place.',
            ),
            SizedBox(height: 28),
            _MockCard(
              name: 'Morning Run',
              icon: Icons.directions_run_rounded,
              color: _orange,
              type: 'TASK',
              streak: 14,
              dots: [true, true, true, false, true, true, false],
              ringProgress: 0.85,
              isDone: false,
            ),
            SizedBox(height: 10),
            _MockCard(
              name: 'Read 30 Minutes',
              icon: Icons.menu_book_rounded,
              color: _teal,
              type: 'FOCUS',
              streak: 9,
              dots: [true, false, true, true, true, false, true],
              ringProgress: 1.0,
              isDone: true,
            ),
            SizedBox(height: 10),
            _MockCard(
              name: '30-Day Challenge',
              icon: Icons.military_tech_rounded,
              color: _violet,
              type: 'CHALLENGE',
              streak: 23,
              dots: [true, true, true, true, true, true, true],
              ringProgress: 0.6,
              isDone: false,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 3: Check-Ins ────────────────────────────────────────────────────────

class _CheckInsPage extends StatelessWidget {
  const _CheckInsPage({required this.ctrl});
  final AnimationController ctrl;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 72),
            const _PageHeader(
              number: '02',
              title: 'One Tap,\nEvery Day',
              subtitle:
                  'Check in daily to build momentum and never break your streak.',
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: ctrl,
              builder: (_, __) {
                final t = ctrl.value;
                final ringT = (t / 0.4).clamp(0.0, 1.0);
                final dotsT = ((t - 0.35) / 0.40).clamp(0.0, 1.0);
                final badgeT = ((t - 0.65) / 0.35).clamp(0.0, 1.0);
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

                return Column(
                  children: [
                    // Big ring
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (ringT > 0.4)
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _orange.withValues(
                                        alpha: (ringT - 0.4) * 0.25),
                                    blurRadius: 50,
                                    spreadRadius: 15,
                                  ),
                                ],
                              ),
                            ),
                          ProgressRing(
                            progress: ringT,
                            color: _orange,
                            size: 120,
                            strokeWidth: 8,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              child: ringT >= 1.0
                                  ? const Icon(
                                      Icons.check_rounded,
                                      key: ValueKey('check'),
                                      color: _orange,
                                      size: 52,
                                    )
                                  : Text(
                                      key: const ValueKey('pct'),
                                      '${(ringT * 100).toInt()}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: _orange,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Week dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (i) {
                        final threshold = i / 6.0;
                        final lit = dotsT >= threshold;
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: lit
                                      ? _orange
                                      : _orange.withValues(alpha: 0.1),
                                  boxShadow: lit
                                      ? [
                                          BoxShadow(
                                            color: _orange.withValues(
                                                alpha: 0.6),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                days[i],
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: lit
                                      ? FontWeight.w800
                                      : FontWeight.w400,
                                  color: lit
                                      ? _orange
                                      : Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 30),
                    // Streak badge
                    Opacity(
                      opacity: badgeT,
                      child: Transform.translate(
                        offset: Offset(0, (1 - badgeT) * 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          decoration: BoxDecoration(
                            color: _orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: _orange.withValues(alpha: 0.25)),
                            boxShadow: [
                              BoxShadow(
                                color: _orange.withValues(alpha: 0.15),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                '14 day streak',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 4: Level Up ─────────────────────────────────────────────────────────

class _LevelUpPage extends StatelessWidget {
  const _LevelUpPage({required this.ctrl});
  final AnimationController ctrl;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 72, 22, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PageHeader(
              number: '03',
              title: 'Level Up\nEvery Day',
              subtitle:
                  'Earn XP with every check-in. Unlock badges and trophies.',
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: ctrl,
              builder: (_, __) {
                final t = ctrl.value;
                final barFill = Curves.easeOut
                    .transform((t / 0.6).clamp(0.0, 1.0));
                final xpProgress = 0.18 + barFill * 0.55;
                final badgeT = ((t - 0.3) / 0.6).clamp(0.0, 1.0);

                final appearT = ((t - 0.5) / 0.15).clamp(0.0, 1.0);
                final fadeT = ((t - 0.65) / 0.22).clamp(0.0, 1.0);
                final xpFloat = appearT * (1 - fadeT);
                final xpOffset =
                    -24.0 * ((t - 0.5) / 0.4).clamp(0.0, 1.0);

                return Column(
                  children: [
                    _MockXpCard(xpProgress: xpProgress),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 36,
                      child: Center(
                        child: Opacity(
                          opacity: xpFloat.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, xpOffset),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: _cyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: _cyan.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '+ 50 XP',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _cyan,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BadgeGrid(progress: badgeT),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 5: Ready ────────────────────────────────────────────────────────────

class _ReadyPage extends StatelessWidget {
  const _ReadyPage();

  static const _emojis = ['⚡', '🔥', '📊', '🔒'];
  static const _texts = [
    'XP, levels, badges & trophies',
    'Daily streaks & contribution grid',
    'Analytics across week, month & year',
    'Offline-first, no account needed',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyan.withValues(alpha: 0.09),
                border:
                    Border.all(color: _cyan.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _cyan.withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child:
                  const Icon(Icons.check_rounded, color: _cyan, size: 52),
            ),
            const SizedBox(height: 32),
            Text(
              "You're all set.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Start tracking your habits and\nbuild the life you want — one\ncheck-in at a time.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.48),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 30),
            ...List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(_emojis[i],
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 14),
                    Text(
                      _texts[i],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'You can revisit this guide from Settings anytime.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.number,
    required this.title,
    required this.subtitle,
  });
  final String number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _cyan.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.45),
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _MockCard extends StatelessWidget {
  const _MockCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.streak,
    required this.dots,
    required this.ringProgress,
    required this.isDone,
  });

  final String name;
  final IconData icon;
  final Color color;
  final String type;
  final int streak;
  final List<bool> dots;
  final double ringProgress;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDone ? 0.12 : 0.07),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
          ),
          child: Stack(
            children: [
              // Glowing left bar
              Positioned(
                left: 0,
                top: 12,
                bottom: 12,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(4)),
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.6), blurRadius: 6)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 13, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: color.withValues(alpha: 0.2)),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Colors.white.withValues(alpha: 0.92),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  type,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: color.withValues(alpha: 0.85),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ProgressRing(
                          progress: ringProgress,
                          color: color,
                          size: 42,
                          strokeWidth: 3,
                          child: isDone
                              ? Icon(Icons.check_rounded,
                                  color: color, size: 18)
                              : Icon(Icons.add_rounded,
                                  color: color.withValues(alpha: 0.6),
                                  size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥',
                                  style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 3),
                              Text(
                                '$streak',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(7, (i) {
                            final on = i < dots.length && dots[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2.5),
                              child: Column(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: on
                                          ? color
                                          : color.withValues(alpha: 0.1),
                                      boxShadow: on
                                          ? [
                                              BoxShadow(
                                                color: color.withValues(
                                                    alpha: 0.5),
                                                blurRadius: 4,
                                              )
                                            ]
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    days[i],
                                    style: GoogleFonts.inter(
                                      fontSize: 7,
                                      color: on
                                          ? color
                                          : Colors.white.withValues(
                                              alpha: 0.22),
                                      fontWeight: on
                                          ? FontWeight.w800
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockXpCard extends StatelessWidget {
  const _MockXpCard({required this.xpProgress});
  final double xpProgress;

  static const _level = 7;
  static const _totalXp = 2840;
  static const _xpToNext = 500;

  @override
  Widget build(BuildContext context) {
    final xpInto = (xpProgress * _xpToNext).toInt();
    final pct = '${(xpProgress * 100).toInt()}%';

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cyan.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _cyan.withValues(alpha: 0.18), width: 1),
            boxShadow: [
              BoxShadow(
                color: _cyan.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_cyan, _cyan.withValues(alpha: 0.5)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _cyan.withValues(alpha: 0.35),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_level',
                        style: GoogleFonts.inter(
                          color: _bg,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level $_level',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$_totalXp total XP',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    pct,
                    style: GoogleFonts.inter(
                      color: _cyan,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Stack(
                children: [
                  Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: xpProgress,
                    child: Container(
                      height: 7,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_cyan.withValues(alpha: 0.7), _cyan],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                              color: _cyan.withValues(alpha: 0.45),
                              blurRadius: 5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Text(
                    '$xpInto',
                    style: GoogleFonts.inter(
                      color: _cyan.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    ' / $_xpToNext XP',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '183 completions',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.progress});
  final double progress;

  static const _badges = [
    ('🔥', 'Streak 7', _orange, true),
    ('🏆', 'First 30', _purple, true),
    ('⭐', 'Power Week', Colors.amber, false),
    ('🎖', 'Elite Run', _violet, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_badges.length, (i) {
        final b = _badges[i];
        final delay = i / _badges.length;
        final opacity =
            ((progress - delay) / (1 - delay + 0.001)).clamp(0.0, 1.0);
        final unlocked = b.$4;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, (1 - opacity) * 10),
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unlocked
                          ? b.$3.withValues(alpha: 0.14)
                          : Colors.white.withValues(alpha: 0.04),
                      border: Border.all(
                        color: unlocked
                            ? b.$3.withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: unlocked
                          ? [
                              BoxShadow(
                                  color: b.$3.withValues(alpha: 0.2),
                                  blurRadius: 12)
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        b.$1,
                        style: TextStyle(
                          fontSize: 24,
                          color: unlocked
                              ? null
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    b.$2,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: unlocked
                          ? Colors.white.withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DotGrid extends CustomPainter {
  const _DotGrid({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
