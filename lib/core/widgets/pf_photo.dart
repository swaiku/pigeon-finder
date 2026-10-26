import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import 'pf_image_placeholder.dart';

/// A photo loaded from [url], fading in over a [PfImagePlaceholder] that
/// stays visible while it loads or if it cannot be loaded.
///
/// [child] is drawn on top of the photo. [cacheWidth] is the width, in
/// logical pixels, the photo is displayed at: it is decoded no larger than
/// that to spare memory.
class const PfPhoto({
  super.key,
  required final String url,
  required final double cacheWidth,
  final BorderRadius borderRadius = const BorderRadius.all(
    Radius.circular(AppSpacing.radiusThumbnail),
  ),
  final Widget? child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return PfImagePlaceholder(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
            cacheWidth: (cacheWidth * pixelRatio).round(),
            frameBuilder: (_, image, frame, wasSynchronouslyLoaded) =>
                AnimatedOpacity(
                  opacity: frame == null && !wasSynchronouslyLoaded ? 0 : 1,
                  duration: AppMotion.medium,
                  child: image,
                ),
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
          ?child,
        ],
      ),
    );
  }
}
