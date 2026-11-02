import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Layout shared by the onboarding steps: optional leading widget, title and
/// subtitle, the [body], then a [note] pinned at the bottom.
class const AuthScaffold({
  super.key,
  required final String title,
  required final Widget body,
  final Widget? leading,
  final Widget? subtitle,
  final String? note,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl - AppSpacing.xxs,
            AppSpacing.lg,
            AppSpacing.xxl - AppSpacing.xxs,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ?leading,
              const SizedBox(height: AppSpacing.xxl),
              Text(title, style: theme.displayMedium),
              const SizedBox(height: AppSpacing.sm),
              if (subtitle != null)
                DefaultTextStyle(
                  style: theme.bodyLarge!.copyWith(
                    color: AppColors.mist,
                    fontWeight: FontWeight.w600,
                  ),
                  child: subtitle!,
                ),
              const SizedBox(height: AppSpacing.xxl),
              body,
              const Spacer(),
              if (note != null)
                Text(
                  note!,
                  textAlign: TextAlign.center,
                  style: theme.bodySmall?.copyWith(color: AppColors.mist),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
