import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/gamification_profile.dart';

class XpLevelCard extends StatelessWidget {
  const XpLevelCard({
    super.key,
    required this.profile,
    required this.accentColor,
  });

  final GamificationProfile profile;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final progress = profile.xpForNextLevel <= 0
        ? 0.0
        : (profile.xpIntoCurrentLevel / profile.xpForNextLevel)
            .clamp(0.0, 1.0)
            .toDouble();

    final percentLabel =
        '${(progress * 100).toStringAsFixed(0)}%';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: level badge + XP total ───────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Level badge
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.55),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${profile.currentLevel}',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0A0A0F),
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          height: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Level label + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level ${profile.currentLevel}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_fmt(profile.totalXp)} total XP',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // XP to next level
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        percentLabel,
                        style: GoogleFonts.inter(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'to lvl ${profile.currentLevel + 1}',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Progress bar ───────────────────────────────────────────
              Stack(
                children: [
                  // Track
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.7),
                            accentColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── XP counter row ─────────────────────────────────────────
              Row(
                children: [
                  Text(
                    _fmt(profile.xpIntoCurrentLevel),
                    style: GoogleFonts.inter(
                      color: accentColor.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    ' / ${_fmt(profile.xpForNextLevel)} XP',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (profile.lifetimeCompletions > 0)
                    Text(
                      '${_fmt(profile.lifetimeCompletions)} completions',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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

String _fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
  return '$n';
}
