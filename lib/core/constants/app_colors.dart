import 'package:flutter/material.dart';

/// App-wide color constants for use in the M3 color system.
/// These are the seed colors users can pick when creating an activity.
class AppColors {
  AppColors._();

  static const List<Color> activityPalette = [
    Color(0xFF6750A4), // M3 Purple (default)
    Color(0xFF0077CC), // Ocean Blue
    Color(0xFF00897B), // Teal
    Color(0xFF2ECC71), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Coral Red
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Green
    Color(0xFFF97316), // Orange
    Color(0xFFA855F7), // Lavender
  ];

  /// Returns a light foreground color guaranteed to be readable on [bg].
  static Color onColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.4 ? Colors.black87 : Colors.white;
  }

  /// Contribution grid intensity shades (GitHub-style).
  static Color gridCell(Color base, double intensity) {
    if (intensity <= 0) return base.withOpacity(0.07);
    if (intensity < 0.25) return base.withOpacity(0.25);
    if (intensity < 0.5) return base.withOpacity(0.5);
    if (intensity < 0.75) return base.withOpacity(0.75);
    return base;
  }
}
