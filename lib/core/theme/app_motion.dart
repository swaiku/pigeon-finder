/// Animation durations shared across the app.
abstract final class AppMotion {
  /// Press feedback (scale down on tap).
  static const Duration press = Duration(milliseconds: 100);

  /// Small state changes: color cross-fades, toggles.
  static const Duration fast = Duration(milliseconds: 200);

  /// Elements swapping in and out.
  static const Duration medium = Duration(milliseconds: 300);

  /// Pop-in and bounce effects.
  static const Duration emphasis = Duration(milliseconds: 500);

  /// Camera flights across the map.
  static const Duration camera = Duration(milliseconds: 600);

  /// Entrance of a whole sheet.
  static const Duration entrance = Duration(milliseconds: 700);

  /// Numbers counting up.
  static const Duration countUp = Duration(milliseconds: 900);

  /// Delay between consecutive rows of a list sliding in.
  static const Duration stagger = Duration(milliseconds: 60);
}
