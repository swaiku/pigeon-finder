import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/map_camera_animator.dart';
import 'map_floating_button.dart';

/// Compass (locks the north up) and recenter buttons stacked on the map.
class const MapControls({
  super.key,

  /// Rotation of the map in degrees, which the compass needle counters.
  required final ValueListenable<double> rotation,
  required final bool northLocked,
  required final VoidCallback onToggleNorthLock,

  /// Null while the user position is unknown.
  required final VoidCallback? onRecenter,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MapFloatingButton(
          tooltip: northLocked ? l10n.mapNorthUnlock : l10n.mapNorthLock,
          active: northLocked,
          onPressed: onToggleNorthLock,
          // The needle keeps pointing north as the map rotates.
          icon: ValueListenableBuilder<double>(
            valueListenable: rotation,
            builder: (_, degrees, child) => Transform.rotate(
              angle: -degrees * math.pi / halfTurn,
              child: child,
            ),
            child: const Icon(Icons.explore),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        MapFloatingButton(
          tooltip: l10n.mapRecenter,
          icon: const Icon(Icons.my_location),
          onPressed: onRecenter,
        ),
      ],
    );
  }
}
