import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_motion.dart';

/// Degrees in a full turn of the map.
const halfTurn = 180.0;
const _fullTurn = halfTurn * 2;

/// Moves a [MapController] smoothly: flutter_map only jumps to a new camera.
class MapCameraAnimator {
  MapCameraAnimator(this._controller, {required TickerProvider vsync})
    : _anim = AnimationController(vsync: vsync, duration: AppMotion.camera);

  final MapController _controller;
  final AnimationController _anim;
  VoidCallback? _tick;

  /// Animates to the given camera; null arguments keep the current value.
  /// [onEnd] only runs when the camera actually reached its target, not when
  /// another animation replaced this one.
  void animateTo({
    LatLng? center,
    double? zoom,
    double? rotation,
    VoidCallback? onEnd,
  }) {
    final cam = _controller.camera;
    final fromCenter = cam.center;
    final fromZoom = cam.zoom;
    final fromRotation = cam.rotation;
    final toCenter = center ?? fromCenter;
    final toZoom = zoom ?? fromZoom;
    final toRotation = rotation ?? fromRotation;
    // Rotate along the shortest way (e.g. 350° -> 0° goes through 360°).
    final rotationDelta =
        (toRotation - fromRotation + halfTurn * 3) % _fullTurn - halfTurn;
    final curve = CurvedAnimation(parent: _anim, curve: Curves.easeInOutCubic);

    void tick() {
      final t = curve.value;
      _controller.moveAndRotate(
        LatLng(
          fromCenter.latitude + (toCenter.latitude - fromCenter.latitude) * t,
          fromCenter.longitude +
              (toCenter.longitude - fromCenter.longitude) * t,
        ),
        fromZoom + (toZoom - fromZoom) * t,
        t == 1 ? toRotation : fromRotation + rotationDelta * t,
      );
    }

    // Replace any animation still running.
    if (_tick != null) _anim.removeListener(_tick!);
    _anim
      ..stop()
      ..reset();
    _tick = tick;
    _anim.addListener(tick);
    // `forward` never completes when interrupted.
    unawaited(_anim.forward().then((_) => onEnd?.call()).catchError((_) {}));
  }

  void dispose() => _anim.dispose();
}
