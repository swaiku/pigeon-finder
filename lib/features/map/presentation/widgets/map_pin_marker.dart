import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_photo.dart';
import '../../domain/entities/map_post.dart';

/// Fraction of a post's life left at which the ring is amber.
const _halfLife = .5;

const _ringStroke = 6.0;
const _ringInset = 3.0;
const _photoBorder = 3.0;
const _badgeBorder = 2.0;
const _tailSize = 12.0;
const _tailOverlap = 7.0;
const _selectedScale = 1.18;
const _shadowElevation = 6.0;

/// Smallest arc drawn, in degrees, so a nearly expired ring never vanishes.
const _minSweepDegrees = 4;

/// Color of the expiry ring for a post with [remaining] of its life left:
/// teal while fresh, amber at half-life, red when about to disappear.
Color freshnessColor(double remaining) {
  final r = remaining.clamp(0.0, 1.0);
  return r >= _halfLife
      ? Color.lerp(
          AppColors.grain,
          AppColors.iridescent,
          (r - _halfLife) / _halfLife,
        )!
      : Color.lerp(AppColors.pin, AppColors.grain, r / _halfLife)!;
}

/// Round photo pin with a 24 h expiry ring, a count badge and a tail.
/// It pops in when it appears and swells while [selected].
class MapPinMarker extends StatefulWidget {
  const MapPinMarker({
    super.key,
    required this.post,
    required this.onTap,
    required this.now,
    this.selected = false,
    this.showRing = true,
  });

  static const size = 58.0;
  static const height = 72.0;

  final MapPost post;
  final VoidCallback onTap;

  /// Clock the ring is drawn against; the map refreshes it as time goes by.
  final DateTime now;
  final bool selected;
  final bool showRing;

  @override
  State<MapPinMarker> createState() => _MapPinMarkerState();
}

class _MapPinMarkerState extends State<MapPinMarker>
    with SingleTickerProviderStateMixin {
  late final _pop = AnimationController(
    vsync: this,
    duration: AppMotion.emphasis,
  )..forward();

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final badge = post.flagged
        ? AppColors.grain
        : post.mine
        ? AppColors.iridescent
        : AppColors.night;
    final pin = GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MapPinMarker.size,
            height: MapPinMarker.size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RingPainter(
                      fraction: post.remaining(now: widget.now),
                      mine: post.mine,
                      showRing: widget.showRing,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(_ringInset),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: _photoBorder,
                          ),
                        ),
                        child: PfPhoto(
                          url: post.photoUrl,
                          cacheWidth: MapPinMarker.size,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(MapPinMarker.size),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -AppSpacing.xs,
                  right: -AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.compact,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: badge,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusChip,
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: _badgeBorder,
                      ),
                    ),
                    child: Text(
                      '×${post.count}',
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -_tailOverlap),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: _tailSize,
                height: _tailSize,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    // Both scales grow from the tail, which must stay on the post position.
    return ScaleTransition(
      scale: CurvedAnimation(parent: _pop, curve: Curves.elasticOut),
      alignment: Alignment.bottomCenter,
      child: AnimatedScale(
        scale: widget.selected ? _selectedScale : 1,
        duration: AppMotion.medium,
        curve: Curves.easeOutBack,
        alignment: Alignment.bottomCenter,
        child: pin,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.mine,
    required this.showRing,
  });

  final double fraction;
  final bool mine;
  final bool showRing;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawShadow(
      Path()..addOval(rect),
      AppColors.night.withAlpha(0x70),
      _shadowElevation,
      false,
    );
    final base = Paint()..color = mine ? AppColors.night : AppColors.paper;
    canvas.drawOval(rect, base);
    if (mine || !showRing) return;
    final arc = rect.deflate(_ringInset);
    // Track under the arc, so the part already elapsed stays visible.
    canvas.drawArc(
      arc,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = AppColors.trait
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringStroke,
    );
    // Remaining time, clockwise from the top (min 4° so it never vanishes).
    final sweep = math.max(_minSweepDegrees / 360, fraction) * 2 * math.pi;
    canvas.drawArc(
      arc,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = freshnessColor(fraction)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = _ringStroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.mine != mine || old.showRing != showRing;
}
