import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// One tab of a [PfBottomNavBar].
class PfNavItem {
  const PfNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The 5-slot bottom navigation bar with a raised circular camera action in
/// the middle, used instead of a standard [NavigationBar] because of that
/// center FAB.
///
/// Expects exactly 4 [items], split two on each side of the center action.
class PfBottomNavBar extends StatelessWidget {
  const PfBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.centerIcon,
    required this.onCenterTap,
  });

  final List<PfNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final IconData centerIcon;
  final VoidCallback onCenterTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final left = items.take(2).toList();
    final right = items.skip(2).take(2).toList();

    Widget tab(PfNavItem item, int index) {
      final selected = index == currentIndex;
      final color = selected ? colorScheme.primary : AppColors.mutedText;
      return Expanded(
        child: InkWell(
          onTap: () => onTap(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 26, color: color),
              const SizedBox(height: 3),
              Text(item.label, style: textTheme.labelMedium?.copyWith(color: color)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 96,
      padding: const EdgeInsets.only(top: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
        boxShadow: AppSpacing.shadowFloating,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < left.length; i++) tab(left[i], i),
          SizedBox(
            width: 88,
            child: Transform.translate(
              offset: const Offset(0, -34),
              child: Center(
                child: InkWell(
                  onTap: onCenterTap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.paper, width: 5),
                      boxShadow: AppSpacing.shadowFab,
                    ),
                    child: Icon(centerIcon, color: colorScheme.onPrimary, size: 32),
                  ),
                ),
              ),
            ),
          ),
          for (var i = 0; i < right.length; i++) tab(right[i], left.length + i),
        ],
      ),
    );
  }
}
