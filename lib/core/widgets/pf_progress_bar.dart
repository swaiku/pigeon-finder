import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The thin rounded progress track used for the profile level bar.
class PfProgressBar extends StatelessWidget {
  const PfProgressBar({
    super.key,
    required this.value,
    this.trackColor,
    this.valueColor,
  });

  /// Progress from 0.0 to 1.0.
  final double value;
  final Color? trackColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 10,
        backgroundColor: trackColor ?? AppColors.segmentTrack,
        valueColor: AlwaysStoppedAnimation(valueColor ?? colorScheme.primary),
      ),
    );
  }
}
