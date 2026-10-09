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
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 26, color: color),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: textTheme.labelMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
      );
    }

    const barShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusSheet),
      ),
    );

    const barHeight = 96.0;
    const fabSize = 68.0;
    const fabOverflow = 26.0;
    const fabRing = 6.0;

    return SizedBox(
      height: barHeight + fabOverflow,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: barShape.borderRadius,
                boxShadow: AppSpacing.shadowFloating,
              ),
              child: Material(
                color: AppColors.paper,
                shape: barShape,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < left.length; i++) tab(left[i], i),
                      const SizedBox(width: 96),
                      for (var i = 0; i < right.length; i++)
                        tab(right[i], left.length + i),
                    ],
                  ),
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppSpacing.shadowFab,
            ),
            child: Material(
              color: AppColors.paper,
              shape: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(fabRing),
                child: Material(
                  color: colorScheme.primary,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onCenterTap,
                    splashColor: Colors.white30,
                    highlightColor: Colors.white24,
                    child: SizedBox(
                      width: fabSize,
                      height: fabSize,
                      child: Icon(
                        centerIcon,
                        color: colorScheme.onPrimary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
