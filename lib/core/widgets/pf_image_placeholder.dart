import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A placeholder box standing in for a photo that has not loaded yet (map
/// pins, Pigeondex thumbnails, verification preview).
///
/// The design uses a diagonal striped pattern; this approximates it with a
/// two-tone diagonal gradient since Flutter has no built-in stripe paint.
class const PfImagePlaceholder({
  super.key,
  final BorderRadius borderRadius = const BorderRadius.all(
    Radius.circular(AppSpacing.radiusThumbnail),
  ),
  final Widget? child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.placeholderStart, AppColors.placeholderEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
    );
  }
}
