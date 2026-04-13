import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeState {
  final Color seedColor;

  const ThemeState({
    this.seedColor = const Color(0xFF6750A4),
  });

  ThemeState copyWith({Color? seedColor}) => ThemeState(
        seedColor: seedColor ?? this.seedColor,
      );
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadPreferences();
  }

  static const _seedColorKey = 'theme_seed_color';

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final seedColorValue = prefs.getInt(_seedColorKey);

    final seedColor = seedColorValue != null ? Color(seedColorValue) : state.seedColor;

    state = state.copyWith(seedColor: seedColor);
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.toARGB32());
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
