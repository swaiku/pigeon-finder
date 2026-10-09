import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The pill-shaped scope switcher used for leaderboard scope ("Quartier /
/// Paris / Monde") and Pigeondex filters.
class PfSegmentedControl extends StatelessWidget {
  const PfSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.segmentTrack,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard - 2),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + 1,
                  ),
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? colorScheme.surface : null,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusChip + 2,
                    ),
                    boxShadow: i == selectedIndex
                        ? AppSpacing.shadowCard
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: textTheme.labelLarge?.copyWith(
                      color: i == selectedIndex
                          ? colorScheme.onSurface
                          : AppColors.mutedText,
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
