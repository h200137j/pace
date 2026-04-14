class LevelCurve {
  const LevelCurve._();

  static int xpToNextLevel(int level) {
    if (level <= 1) return 100;
    return 100 + ((level - 1) * 25);
  }

  static ({int level, int xpIntoCurrentLevel, int xpForNextLevel})
      resolveLevelFromXp(int totalXp) {
    var level = 1;
    var remaining = totalXp;
    var need = xpToNextLevel(level);

    while (remaining >= need) {
      remaining -= need;
      level++;
      need = xpToNextLevel(level);
    }

    return (
      level: level,
      xpIntoCurrentLevel: remaining,
      xpForNextLevel: need,
    );
  }
}
