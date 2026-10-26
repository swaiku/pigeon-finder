import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'pf_card.dart';

/// A friendly inline message for an empty list, e.g. "no pigeon posted
/// yet" on the profile screen.
class const PfEmptyState({
  super.key,
  required final String message,
  final IconData? icon,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PfCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.mutedText),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
