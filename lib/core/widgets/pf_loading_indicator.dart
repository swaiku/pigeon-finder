import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A centered spinner with an optional message, used while the AI
/// verification (or any other async step) is running.
class PfLoadingIndicator extends StatelessWidget {
  const PfLoadingIndicator({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: colorScheme.tertiary),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}
