import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_error_state.dart';
import '../../../../core/widgets/pf_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../post_detail/presentation/widgets/post_detail_sheet.dart';
import '../../domain/entities/map_defaults.dart';
import '../bloc/map_bloc.dart';
import '../widgets/map_floating_button.dart';
import '../widgets/map_header.dart';
import '../widgets/map_posts_layer.dart';
import '../widgets/osm_tile_layer.dart';

/// Degrees in a full turn of the map.
const _halfTurn = 180.0;
const _fullTurn = _halfTurn * 2;

/// Stand-in until the profile feature provides the real score.
const _placeholderPoints = 1240;

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(const MapStarted()),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView>
    with SingleTickerProviderStateMixin {
  static const _overlayGap = AppSpacing.xxxl;
  static const _recenterZoom = 16.0;
  static const _initialZoom = 14.0;
  static const _minZoom = 3.0;
  static const _maxZoom = 19.0;
  static const _clockTick = Duration(seconds: 30);
  static const _userDotSize = 18.0;
  static const _captureBorderWidth = 2.0;
  static const _captureFillAlpha = 0x22;

  final _controller = MapController();
  late final _anim = AnimationController(
    vsync: this,
    duration: AppMotion.camera,
  );

  VoidCallback? _tick;
  bool _northLocked = false;
  double _rotation = 0;

  /// Part of the map on screen, which the header counts pigeons in.
  LatLngBounds? _visible;

  /// Clock the pins' expiry rings are drawn against; ticks so that they keep
  /// shrinking, and change color, while the map stays open.
  DateTime _now = DateTime.now();
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(
      _clockTick,
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  /// Smoothly moves the camera; null arguments keep the current value.
  void _animateCamera(
    MapBloc bloc, {
    LatLng? center,
    double? zoom,
    double? rotation,
  }) {
    final cam = _controller.camera;
    final from = (center: cam.center, zoom: cam.zoom, rotation: cam.rotation);
    final to = (
      center: center ?? cam.center,
      zoom: zoom ?? cam.zoom,
      rotation: rotation ?? cam.rotation,
    );
    // Rotate along the shortest way (e.g. 350° -> 0° goes through 360°).
    final rotationDelta =
        (to.rotation - from.rotation + _halfTurn * 3) % _fullTurn - _halfTurn;
    final curve = CurvedAnimation(parent: _anim, curve: Curves.easeInOutCubic);

    void tick() {
      final t = curve.value;
      _controller.moveAndRotate(
        LatLng(
          from.center.latitude +
              (to.center.latitude - from.center.latitude) * t,
          from.center.longitude +
              (to.center.longitude - from.center.longitude) * t,
        ),
        from.zoom + (to.zoom - from.zoom) * t,
        t == 1 ? to.rotation : from.rotation + rotationDelta * t,
      );
    }

    // Replace any animation still running.
    if (_tick != null) _anim.removeListener(_tick!);
    _anim
      ..stop()
      ..reset();
    _tick = tick;
    _anim.addListener(tick);
    unawaited(
      _anim
          .forward()
          .then((_) {
            // `forward` never completes when interrupted, so this only runs when
            // the camera actually reached its target.
            if (mounted) bloc.add(MapCameraMoved(to.center, to.zoom));
          })
          .catchError((_) {}),
    );
  }

  void _toggleNorthLock(MapBloc bloc) {
    final lock = !_northLocked;
    setState(() => _northLocked = lock);
    if (lock && _rotation != 0) _animateCamera(bloc, rotation: 0);
  }

  @override
  void dispose() {
    _clock?.cancel();
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top;
    // With `extendBody` this includes the height of the bottom nav bar.
    final bottom = MediaQuery.paddingOf(context).bottom;
    final bloc = context.read<MapBloc>();
    return BlocListener<MapBloc, MapState>(
      // First fix of the user position: fly there.
      listenWhen: (prev, curr) =>
          prev.userPosition == null && curr.userPosition != null,
      listener: (_, state) =>
          _animateCamera(bloc, center: state.userPosition, zoom: _recenterZoom),
      child: BlocConsumer<MapBloc, MapState>(
        listenWhen: (prev, curr) =>
            curr.selectedId != null && prev.selectedId != curr.selectedId,
        listener: (context, state) {
          final post = state.selected!;
          _animateCamera(bloc, center: post.position);
          unawaited(
            showPostDetailSheet(context, post).whenComplete(() {
              if (bloc.state.selectedId == post.id) {
                bloc.add(const MapPostSelected(null));
              }
            }),
          );
        },
        builder: (context, state) {
          // Posts that expired since the last fetch are dropped right away.
          final posts = [
            for (final p in state.posts)
              if (p.timeLeft(now: _now) > Duration.zero) p,
          ];
          final visible = _visible;
          final inView = [
            for (final p in posts)
              if (visible == null || visible.contains(p.position)) p,
          ];
          final user = state.userPosition;
          return Stack(
            children: [
              FlutterMap(
                mapController: _controller,
                options: MapOptions(
                  initialCenter: defaultMapCenter,
                  initialZoom: _initialZoom,
                  minZoom: _minZoom,
                  maxZoom: _maxZoom,
                  backgroundColor: AppColors.pavement,
                  interactionOptions: InteractionOptions(
                    flags: _northLocked
                        ? InteractiveFlag.all & ~InteractiveFlag.rotate
                        : InteractiveFlag.all,
                  ),
                  onTap: (_, _) => bloc.add(const MapPostSelected(null)),
                  onMapReady: () => setState(
                    () => _visible = _controller.camera.visibleBounds,
                  ),
                  onMapEvent: (event) {
                    final visible = event.camera.visibleBounds;
                    if (event.camera.rotation != _rotation ||
                        visible != _visible) {
                      setState(() {
                        _rotation = event.camera.rotation;
                        _visible = visible;
                      });
                    }
                    if (event is MapEventMoveEnd ||
                        event is MapEventFlingAnimationEnd ||
                        event is MapEventDoubleTapZoomEnd) {
                      bloc.add(
                        MapCameraMoved(event.camera.center, event.camera.zoom),
                      );
                    }
                  },
                ),
                children: [
                  const OsmTileLayer(),
                  if (state.userPosition case final pos?)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: pos,
                          radius: captureRadiusMeters,
                          useRadiusInMeter: true,
                          color: AppColors.iridescent.withAlpha(
                            _captureFillAlpha,
                          ),
                          borderColor: AppColors.iridescent,
                          borderStrokeWidth: _captureBorderWidth,
                        ),
                      ],
                    ),
                  if (state.userPosition case final pos?)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: pos,
                          width: _userDotSize,
                          height: _userDotSize,
                          child: const _UserDot(),
                        ),
                      ],
                    ),
                  MapPostsLayer(
                    posts: posts,
                    now: _now,
                    selectedId: state.selectedId,
                    onPostTap: (post) {
                      unawaited(HapticFeedback.selectionClick());
                      bloc.add(MapPostSelected(post.id));
                    },
                  ),
                ],
              ),
              Positioned(
                top: top + AppSpacing.sm,
                left: AppSpacing.cozy,
                right: AppSpacing.cozy,
                child: MapHeader(
                  city: state.regionName ?? '…',
                  pigeonCount: inView.fold(0, (sum, p) => sum + p.count),
                  aroundYou: user != null && (visible?.contains(user) ?? true),
                  // TODO(profile): read points/initial from the profile feature.
                  points: NumberFormat.decimalPattern(
                    Localizations.localeOf(context).toString(),
                  ).format(_placeholderPoints),
                  initial: 'C',
                  onProfileTap: () => context.go(AppRoutes.profile),
                ),
              ),
              if (state.status == MapStatus.loading)
                const Center(child: PfLoadingIndicator()),
              if (state.status == MapStatus.failure)
                Center(
                  child: PfErrorState(
                    message: state.errorMessage ?? l10n.mapLoadError,
                    actionLabel: l10n.retry,
                    onAction: () => bloc.add(const MapStarted()),
                  ),
                ),
              Positioned(
                right: AppSpacing.cozy,
                bottom: bottom + _overlayGap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MapFloatingButton(
                      tooltip: _northLocked
                          ? l10n.mapNorthUnlock
                          : l10n.mapNorthLock,
                      active: _northLocked,
                      onPressed: () => _toggleNorthLock(bloc),
                      // The needle keeps pointing north as the map rotates.
                      icon: Transform.rotate(
                        angle: -_rotation * math.pi / _halfTurn,
                        child: const Icon(Icons.explore),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    MapFloatingButton(
                      tooltip: l10n.mapRecenter,
                      icon: const Icon(Icons.my_location),
                      onPressed: state.userPosition == null
                          ? null
                          : () => _animateCamera(
                              bloc,
                              center: state.userPosition,
                              zoom: _recenterZoom,
                            ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: AppSpacing.sm,
                bottom: bottom + AppSpacing.compact,
                child: const OsmAttribution(),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Pulsing "you are here" dot.
class _UserDot extends StatefulWidget {
  const _UserDot();

  @override
  State<_UserDot> createState() => _UserDotState();
}

const _pulse = Duration(seconds: 2);
const _pulseGrowth = 2.0;
const _pulseOpacity = .5;
const _dotBorder = 3.0;
const _dotShadowBlur = 6.0;

class _UserDotState extends State<_UserDot>
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
    const color = AppColors.night;
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
