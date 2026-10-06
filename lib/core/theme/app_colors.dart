import 'package:flutter/material.dart';

/// Color tokens extracted from the "Pigeon Finder" design system board.
///
/// Named tokens (night, pin, iridescent, ...) mirror the names used in the
/// design: everything in the palette comes from the app icon (map tiles,
/// park greenery, the Seine, the pigeon's iridescent neck feathers, the red
/// map pin).
abstract final class AppColors {
  // --- Core palette ---------------------------------------------------
  static const Color night = Color(0xFF1F3A5F);
  static const Color pin = Color(0xFFEE3350);
  static const Color iridescent = Color(0xFF2E9C8F);
  static const Color feather = Color(0xFF7A5A9C);
  static const Color slate = Color(0xFF5E6B8C);
  static const Color grain = Color(0xFFF6B93B);
  static const Color river = Color(0xFF8EC3F2);
  static const Color park = Color(0xFFBFDDA8);
  static const Color pavement = Color(0xFFF3EDE1);
  static const Color cream = Color(0xFFFBF7EF);
  static const Color paper = Color(0xFFFFFDF8);
  static const Color trait = Color(0xFFE3DACB);
  static const Color mist = Color(0xFF5C6F8A);

  // --- Semantic status colors ------------------------------------------
  // Reused consistently across screens for AI/report/moderation feedback,
  // even though they are not part of the named swatch board.
  static const Color successContainer = Color(0xFFDDF1EC);
  static const Color onSuccessContainer = Color(0xFF1F7A6F);
  static const Color dangerContainer = Color(0xFFFDE3E7);
  static const Color danger = Color(0xFFC21F3B);
  static const Color warningContainer = Color(0xFFFFF3D6);
  static const Color onWarningContainer = Color(0xFF8A5A00);

  static const Color mutedText = Color(0xFF8A98AE);
  static const Color divider = Color(0xFFF1EBDD);
  static const Color segmentTrack = Color(0xFFEDE5D4);

  /// Decorative placeholder gradient for photos that have not loaded yet.
  static const Color placeholderStart = Color(0xFF6F7C9C);
  static const Color placeholderEnd = Color(0xFF7E8AA8);

  /// Scrim behind modal sheets / full-screen overlays.
  static const Color scrim = Color(0xFF0E1522);

  static final ColorScheme lightScheme = ColorScheme.light(
    primary: pin,
    onPrimary: paper,
    primaryContainer: dangerContainer,
    onPrimaryContainer: danger,
    secondary: night,
    onSecondary: paper,
    secondaryContainer: trait,
    onSecondaryContainer: night,
    tertiary: iridescent,
    onTertiary: paper,
    tertiaryContainer: successContainer,
    onTertiaryContainer: onSuccessContainer,
    error: danger,
    onError: paper,
    errorContainer: dangerContainer,
    onErrorContainer: danger,
    surface: paper,
    onSurface: night,
    onSurfaceVariant: mist,
    surfaceContainerHighest: segmentTrack,
    outline: trait,
    outlineVariant: divider,
    shadow: night,
    scrim: scrim,
  );
}
