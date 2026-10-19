import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_avatar.dart';
import '../../../../core/widgets/pf_chip.dart';
import '../../../../core/widgets/pf_image_placeholder.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/map_post.dart';

/// Bottom card summarising the tapped pin.
class MapPostCard extends StatelessWidget {
  const MapPostCard({super.key, required this.post, required this.onClose});

  final MapPost post;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    final left = post.timeLeft();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPanel),
        boxShadow: AppSpacing.shadowPanel,
      ),
      child: Row(
        children: [
          const SizedBox(width: 84, height: 84, child: PfImagePlaceholder()),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.place, style: text.titleMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    PfAvatar(
                      initial: post.user[0].toUpperCase(),
                      size: 20,
                      backgroundColor: AppColors.feather,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        post.user,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelMedium?.copyWith(
                          color: AppColors.mist,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    PfStatusChip(
                      label: l10n.mapExpiresIn(
                        left.inHours,
                        left.inMinutes % 60,
                      ),
                      tone: PfChipTone.dark,
                    ),
                    PfStatusChip(
                      label: l10n.mapPigeonCount(post.count),
                      tone: PfChipTone.neutral,
                    ),
                    if (post.flagged)
                      PfStatusChip(
                        label: l10n.mapReports(post.reports),
                        tone: PfChipTone.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
