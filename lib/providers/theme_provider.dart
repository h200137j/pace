import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ThemeState {
  final ThemeMode mode;
  final Color seedColor;

  const ThemeState({
    this.mode = ThemeMode.system,
    this.seedColor = const Color(0xFF6750A4),
  });

  ThemeState copyWith({ThemeMode? mode, Color? seedColor}) => ThemeState(
        mode: mode ?? this.mode,
        seedColor: seedColor ?? this.seedColor,
      );
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState());

  void setMode(ThemeMode mode) => state = state.copyWith(mode: mode);

  void setSeedColor(Color color) => state = state.copyWith(seedColor: color);

  void toggleMode() {
    if (state.mode == ThemeMode.dark) {
      state = state.copyWith(mode: ThemeMode.light);
    } else {
      state = state.copyWith(mode: ThemeMode.dark);
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
