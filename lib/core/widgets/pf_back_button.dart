import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Round white chevron button that goes back one screen.
class const PfBackButton({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: AppColors.paper,
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.chevron_left, size: AppSpacing.iconLg),
          onPressed: context.pop,
        ),
      ),
    );
  }
}
