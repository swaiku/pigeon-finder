import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'pf_avatar.dart';

/// A single leaderboard row: rank, avatar, name, subtitle and points.
///
/// When [highlighted] is true it uses the filled accent look reserved for
/// the current user's own row ("Toi").
class PfRankingRow extends StatelessWidget {
  const PfRankingRow({
    super.key,
    required this.rank,
    required this.avatarInitial,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.avatarColor,
    this.highlighted = false,
  });

  final String rank;
  final String avatarInitial;
  final String title;
  final String? subtitle;
  final String trailing;
  final Color? avatarColor;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final foreground = highlighted ? colorScheme.onPrimary : colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: highlighted ? colorScheme.primary : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPanel),
        boxShadow: highlighted ? AppSpacing.shadowCta : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              rank,
              textAlign: TextAlign.right,
              style: textTheme.titleMedium?.copyWith(color: foreground),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          PfAvatar(
            initial: avatarInitial,
            backgroundColor: highlighted ? colorScheme.surface : avatarColor,
            foregroundColor: highlighted ? colorScheme.primary : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(color: foreground),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: highlighted ? colorScheme.onPrimary : AppColors.mutedText,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            trailing,
            style: textTheme.titleMedium?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
