import 'package:flutter/material.dart';

/// Type scale extracted from the design system board ("Typographie" table).
///
/// Three font families, matching the three Google Fonts imported by the
/// design (bundled locally as variable fonts, see pubspec.yaml):
/// - [display] (Fredoka) for headings, titles and button labels.
/// - [body] (Nunito) for body text, captions and small labels.
/// - [mono] (JetBrains Mono) for numeric / placeholder overline labels.
abstract final class AppTypography {
  static const String display = 'Fredoka';
  static const String body = 'Nunito';
  static const String mono = 'JetBrains Mono';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w700,
      fontSize: 40,
      height: 1.05,
    ),
    displayMedium: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      height: 1.05,
    ),
    displaySmall: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w700,
      fontSize: 26,
      height: 1.15,
    ),
    headlineLarge: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w700,
      fontSize: 24,
      height: 1.1,
    ),
    headlineMedium: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w600,
      fontSize: 22,
      height: 1.2,
    ),
    headlineSmall: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w600,
      fontSize: 19,
      height: 1.2,
    ),
    titleLarge: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.2,
    ),
    titleMedium: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.2,
    ),
    titleSmall: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w600,
      fontSize: 15,
      height: 1.2,
    ),
    bodyLarge: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w700,
      fontSize: 15,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w700,
      fontSize: 13,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w800,
      fontSize: 15,
      height: 1.2,
    ),
    labelMedium: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w800,
      fontSize: 12,
      height: 1.2,
    ),
    labelSmall: TextStyle(
      fontFamily: mono,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      height: 1.2,
    ),
  );
}
