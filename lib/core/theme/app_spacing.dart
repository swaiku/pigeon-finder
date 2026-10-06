import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spacing, corner radii and shadow tokens extracted from the design
/// system board ("Rayons & ombres" section plus recurring shadow recipes
/// used throughout the screens).
abstract final class AppSpacing {
  // --- Spacing ----------------------------------------------------------
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // --- Radii --------------------------------------------------------------
  // Named directly after the board's own scale: vignette, bouton, carte,
  // panneau, feuille. radiusChip and radiusPill are not in that table but
  // recur consistently across chips/badges and pill-shaped headers.
  static const double radiusChip = 10;
  static const double radiusThumbnail = 12;
  static const double radiusButton = 16;
  static const double radiusCard = 18;
  static const double radiusPanel = 20;
  static const double radiusPill = 22;
  static const double radiusSheet = 28;

  // --- Shadows ------------------------------------------------------------
  // Alpha values match the rgba() recipes used throughout the design
  // (e.g. rgba(31,58,95,.14) -> AppColors.night at alpha 0x24).
  static List<BoxShadow> get shadowCard => [
    BoxShadow(
      color: AppColors.night.withAlpha(0x14),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowFloating => [
    BoxShadow(
      color: AppColors.night.withAlpha(0x24),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowPanel => [
    BoxShadow(
      color: AppColors.night.withAlpha(0x2E),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowToast => [
    BoxShadow(
      color: AppColors.night.withAlpha(0x59),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get shadowCta => [
    BoxShadow(
      color: AppColors.pin.withAlpha(0x59),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get shadowFab => [
    BoxShadow(
      color: AppColors.pin.withAlpha(0x66),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}
