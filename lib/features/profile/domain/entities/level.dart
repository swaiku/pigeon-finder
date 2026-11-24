/// How much the user plays the app, earned through XP. Unrelated to the
/// ranking, which counts points (pigeons and coos received).
enum Level {
  fledgling(0),
  forager(50),
  stroller(150),
  lookout(300),
  cooer(500),
  rockDove(800),
  grandRockDove(1200),
  woodPigeon(1700),
  fancier(2300),
  rooftopKing(3000);

  const Level(this.minXp);

  /// XP needed to reach this level.
  final int minXp;

  static const xpPerPhoto = 20;
  static const xpPerActiveDay = 10;
  static const xpPerCooGiven = 2;

  /// XP earned by posting, coming back on different days and cooing others.
  static int xp({
    required int photos,
    required int activeDays,
    required int likesGiven,
  }) =>
      photos * xpPerPhoto +
      activeDays * xpPerActiveDay +
      likesGiven * xpPerCooGiven;

  static Level of(int xp) => values.lastWhere((l) => xp >= l.minXp);

  /// 1-based, as shown to the user.
  int get number => index + 1;

  /// Null at the top level.
  Level? get next => index + 1 < values.length ? values[index + 1] : null;

  /// Progress from this level to the next, in [0, 1]; 1 at the top level.
  double progress(int xp) => switch (next) {
    final next? => (xp - minXp) / (next.minXp - minXp),
    null => 1,
  };
}
