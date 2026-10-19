import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_avatar.dart';
import '../../../../l10n/app_localizations.dart';

/// Floating top bar: city/24 h summary pill and the points/avatar pill.
class MapHeader extends StatelessWidget {
  const MapHeader({
    super.key,
    required this.city,
    required this.liveCount,
    required this.points,
    required this.initial,
    this.onProfileTap,
  });

  final String city;
  final int liveCount;
  final String points;
  final String initial;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
            decoration: BoxDecoration(
              color: AppColors.paper.withAlpha(0xF0),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              boxShadow: AppSpacing.shadowFloating,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium,
                      ),
                      Text(
                        l10n.mapPigeonsSpotted(liveCount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelMedium?.copyWith(
                          color: AppColors.mist,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            decoration: BoxDecoration(
              color: AppColors.night,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              boxShadow: AppSpacing.shadowFloating,
            ),
            child: Row(
              children: [
                Text(
                  points,
                  style: text.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(width: 8),
                PfAvatar(initial: initial, size: 34),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
