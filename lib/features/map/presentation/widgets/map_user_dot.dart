import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

const _pulse = Duration(seconds: 2);
const _pulseGrowth = 2.0;
const _pulseOpacity = .5;
const _dotBorder = 3.0;
const _dotShadowBlur = 6.0;

/// Pulsing "you are here" dot.
class MapUserDot extends StatefulWidget {
  const MapUserDot({super.key});

  static const size = 18.0;

  @override
  State<MapUserDot> createState() => _MapUserDotState();
}

class _MapUserDotState extends State<MapUserDot>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: _pulse)
    ..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = AppColors.pin;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, _) => Transform.scale(
              scale: 1 + _pulseGrowth * _anim.value,
              child: Opacity(
                opacity: _pulseOpacity * (1 - _anim.value),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: _dotBorder),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: _dotShadowBlur),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
