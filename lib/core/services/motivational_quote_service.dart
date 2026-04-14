import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/motivational_quotes.dart';

class MotivationalQuoteService {
  MotivationalQuoteService._();

  static const _seenIndicesKey = 'gm_motivational_quote_seen_indices';
  static const _seenCelebrationIndicesKey =
      'gm_celebration_quote_seen_indices';

  static final Random _random = Random();

  static Future<String> getNextQuote() async {
    if (motivationalQuotes.isEmpty) {
      return 'You completed today. Keep the streak alive.';
    }

    final prefs = await SharedPreferences.getInstance();
    final seen = _loadSeenSet(prefs);

    final available = <int>[];
    for (var i = 0; i < motivationalQuotes.length; i++) {
      if (!seen.contains(i)) {
        available.add(i);
      }
    }

    if (available.isEmpty) {
      seen.clear();
      for (var i = 0; i < motivationalQuotes.length; i++) {
        available.add(i);
      }
    }

    final selectedIndex = available[_random.nextInt(available.length)];
    seen.add(selectedIndex);
    await prefs.setString(_seenIndicesKey, jsonEncode(seen.toList()));

    return motivationalQuotes[selectedIndex];
  }

  static Future<String> getCelebrationQuote() async {
    if (celebrationQuotes.isEmpty) {
      return 'You unlocked a rare milestone. Keep rising.';
    }

    final prefs = await SharedPreferences.getInstance();
    final seen = _loadSeenSet(prefs, storageKey: _seenCelebrationIndicesKey);

    final available = <int>[];
    for (var i = 0; i < celebrationQuotes.length; i++) {
      if (!seen.contains(i)) {
        available.add(i);
      }
    }

    if (available.isEmpty) {
      seen.clear();
      for (var i = 0; i < celebrationQuotes.length; i++) {
        available.add(i);
      }
    }

    final selectedIndex = available[_random.nextInt(available.length)];
    seen.add(selectedIndex);
    await prefs.setString(
      _seenCelebrationIndicesKey,
      jsonEncode(seen.toList()),
    );

    return celebrationQuotes[selectedIndex];
  }

  static Set<int> _loadSeenSet(
    SharedPreferences prefs, {
    String storageKey = _seenIndicesKey,
  }) {
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return <int>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <int>{};
      }

      return decoded.whereType<int>().toSet();
    } catch (_) {
      return <int>{};
    }
  }
}