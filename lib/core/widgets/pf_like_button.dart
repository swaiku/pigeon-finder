import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// The "Roucoule" (coo) toggle button shown under a photo: a pill button
/// that switches between a light and a filled accent look depending on
/// whether the current user already liked the post.
///
/// Presentational only: the already-formatted [label] (e.g. "Roucoule ·
/// 57") is supplied by the caller so it stays localizable.
class const PfLikeButton({
  super.key,
  required final String label,
  required final bool selected,
  required final VoidCallback onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = selected
        ? colorScheme.primary
        : colorScheme.errorContainer;
    final foreground = selected
        ? colorScheme.onPrimary
        : colorScheme.onErrorContainer;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: AppSpacing.iconMd, color: foreground),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
