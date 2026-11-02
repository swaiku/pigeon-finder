import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Round floating map control (recenter, compass...).
class const MapFloatingButton({
  super.key,
  required final Widget icon,
  required final VoidCallback? onPressed,
  final String? tooltip,

  /// Highlights the button, e.g. while the north is locked.
  final bool active = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppSpacing.shadowFloating,
      ),
      child: Material(
        color: active ? colorScheme.primary : AppColors.paper,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          iconSize: AppSpacing.iconLg,
          padding: const EdgeInsets.all(AppSpacing.md),
          color: active ? colorScheme.onPrimary : AppColors.night,
          icon: icon,
        ),
      ),
    );
  }
}
