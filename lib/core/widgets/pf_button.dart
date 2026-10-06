import 'package:flutter/material.dart';

/// Visual style of a [PfButton], matching the three button looks cataloged
/// in the design system board: filled accent, filled secondary and
/// outlined.
enum PfButtonVariant { primary, secondary, outline }

/// A full-width call-to-action button, styled from the app theme.
///
/// Presentational only: label and tap behavior are supplied by the caller.
class PfButton extends StatelessWidget {
  const PfButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PfButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final PfButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
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
