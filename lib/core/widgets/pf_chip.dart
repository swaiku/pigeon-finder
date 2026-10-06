import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Semantic color of a [PfStatusChip], matching the "Étiquettes & contrôles"
/// section of the design system board: AI/report feedback chips use
/// success/danger/warning tones, everything else is neutral or dark.
enum PfChipTone { success, danger, warning, neutral, dark }

/// A small inline label used for AI verification results, report counts,
/// expiry notices and achievement badges.
///
/// With [filled] set to false it renders as an outline only, which covers
/// the "locked" badge look (the design uses a dashed border there; Flutter
/// has no built-in dashed border, so a plain outline is used instead).
class PfStatusChip extends StatelessWidget {
  const PfStatusChip({
    super.key,
    required this.label,
    this.tone = PfChipTone.neutral,
    this.filled = true,
  });

  final String label;
  final PfChipTone tone;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (tone) {
      PfChipTone.success => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
      ),
      PfChipTone.danger => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
      PfChipTone.warning => (AppColors.warningContainer, AppColors.onWarningContainer),
      PfChipTone.neutral => (AppColors.segmentTrack, AppColors.mist),
      PfChipTone.dark => (colorScheme.secondary, colorScheme.onSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: filled ? background : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip + 4),
        border: filled ? null : Border.all(color: background, width: 2),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: filled ? foreground : AppColors.mutedText,
        ),
      ),
    );
  }
}

/// A tiny counter pill ("×3") overlaid on a photo thumbnail or map pin.
class PfCountBadge extends StatelessWidget {
  const PfCountBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        border: Border.all(color: colorScheme.surface, width: 2),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colorScheme.onSecondary),
      ),
    );
  }
}
