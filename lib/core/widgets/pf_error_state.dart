import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'pf_button.dart';

/// A centered error message with an optional retry action.
class PfErrorState extends StatelessWidget {
  const PfErrorState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(message, textAlign: TextAlign.center, style: textTheme.bodyMedium),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.md),
          PfButton(
            label: actionLabel!,
            onPressed: onAction,
            variant: PfButtonVariant.secondary,
          ),
        ],
      ],
    );
  }
}
