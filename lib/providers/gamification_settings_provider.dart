import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationSettingsState {
  const GamificationSettingsState({
    this.showRewardToasts = true,
    this.enableRewardAnimations = true,
  });

  final bool showRewardToasts;
  final bool enableRewardAnimations;

  GamificationSettingsState copyWith({
    bool? showRewardToasts,
    bool? enableRewardAnimations,
  }) {
    return GamificationSettingsState(
      showRewardToasts: showRewardToasts ?? this.showRewardToasts,
      enableRewardAnimations:
          enableRewardAnimations ?? this.enableRewardAnimations,
    );
  }
}

class GamificationSettingsNotifier
    extends StateNotifier<GamificationSettingsState> {
  GamificationSettingsNotifier() : super(const GamificationSettingsState()) {
    _loadPreferences();
  }

  static const _showRewardToastsKey = 'gm_show_reward_toasts';
  static const _enableRewardAnimationsKey = 'gm_enable_reward_animations';

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      showRewardToasts:
          prefs.getBool(_showRewardToastsKey) ?? state.showRewardToasts,
      enableRewardAnimations: prefs.getBool(_enableRewardAnimationsKey) ??
          state.enableRewardAnimations,
    );
  }

  Future<void> setShowRewardToasts(bool value) async {
    state = state.copyWith(showRewardToasts: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showRewardToastsKey, value);
  }

  Future<void> setEnableRewardAnimations(bool value) async {
    state = state.copyWith(enableRewardAnimations: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enableRewardAnimationsKey, value);
  }
}

final gamificationSettingsProvider =
    StateNotifierProvider<GamificationSettingsNotifier, GamificationSettingsState>(
  (ref) => GamificationSettingsNotifier(),
);
