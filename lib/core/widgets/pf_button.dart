import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Visual style of a [PfButton], matching the three button looks cataloged
/// in the design system board: filled accent, filled secondary and
/// outlined.
enum PfButtonVariant { primary, secondary, outline }

/// A full-width call-to-action button, styled from the app theme.
///
/// Presentational only: label and tap behavior are supplied by the caller.
class const PfButton({
  super.key,
  required final String label,
  required final VoidCallback? onPressed,
  final PfButtonVariant variant = PfButtonVariant.primary,
  final IconData? icon,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSpacing.iconMd),
              const SizedBox(width: AppSpacing.sm),
              Text(label),
            ],
          );

    switch (variant) {
      case PfButtonVariant.primary:
        return ElevatedButton(onPressed: onPressed, child: child);
      case PfButtonVariant.secondary:
        final colorScheme = Theme.of(context).colorScheme;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
          ),
          onPressed: onPressed,
          child: child,
        );
      case PfButtonVariant.outline:
        return OutlinedButton(onPressed: onPressed, child: child);
    }
  }
}
