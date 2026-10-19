import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Bubble standing for several nearby pins that would overlap at this zoom.
/// Tapping it is handled by the cluster layer, which zooms in on its pins.
class MapClusterMarker extends StatelessWidget {
  const MapClusterMarker({super.key, required this.count});

  static const size = 52.0;

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.night,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.night.withAlpha(0x70),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$count',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: Colors.white, height: 1),
        ),
      ),
    );
  }
}
