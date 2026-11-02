import 'dart:async';

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
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pf_error_state.dart';
import '../../../../core/widgets/pf_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../post_detail/presentation/widgets/post_detail_sheet.dart';
import '../../domain/entities/map_defaults.dart';
import '../bloc/map_bloc.dart';
import '../controllers/map_camera_animator.dart';
import '../widgets/map_controls.dart';
import '../widgets/map_header.dart';
import '../widgets/map_posts_layer.dart';
import '../widgets/map_user_dot.dart';
import '../widgets/osm_tile_layer.dart';

const _captureBorderWidth = 2.0;
const _captureFillAlpha = 0x22;

/// Stand-in until the profile feature provides the real score.
const _placeholderPoints = 1240;

class const MapPage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(const MapStarted()),
      child: const _MapView(),
    );
  }
}

class const _MapView() extends StatefulWidget {
  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView>
    with SingleTickerProviderStateMixin {
  static const _overlayGap = AppSpacing.xxxl;
  static const _recenterZoom = 16.0;
  static const _minZoom = 3.0;
  static const _maxZoom = 19.0;

  final _controller = MapController();
  late final _camera = MapCameraAnimator(_controller, vsync: this);

  /// Rotation of the map, listened to by the compass alone: the map turns
  /// every frame while the user rotates it.
  final _rotation = ValueNotifier<double>(0);
  bool _northLocked = false;

  /// Smoothly moves the camera, then tells the bloc where it ended up.
  void _flyTo(MapBloc bloc, {LatLng? center, double? zoom, double? rotation}) {
    _camera.animateTo(
      center: center,
      zoom: zoom,
      rotation: rotation,
      onEnd: () {
        if (mounted) _reportCamera(bloc, _controller.camera);
      },
    );
  }

  void _reportCamera(MapBloc bloc, MapCamera camera) => bloc.add(
    MapCameraMoved(camera.center, camera.zoom, camera.visibleBounds),
  );

  void _toggleNorthLock(MapBloc bloc) {
    final lock = !_northLocked;
    setState(() => _northLocked = lock);
    if (lock && _rotation.value != 0) _flyTo(bloc, rotation: 0);
  }

  @override
  void dispose() {
    _camera.dispose();
    _rotation.dispose();
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
    return MultiBlocListener(
      listeners: [
        // First fix of the user position: fly there.
        BlocListener<MapBloc, MapState>(
          listenWhen: (prev, curr) =>
              prev.userPosition == null && curr.userPosition != null,
          listener: (_, state) =>
              _flyTo(bloc, center: state.userPosition, zoom: _recenterZoom),
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (prev, curr) =>
              curr.selectedId != null && prev.selectedId != curr.selectedId,
          listener: (context, state) {
            final post = state.selected;
            if (post == null) return;
            _flyTo(bloc, center: post.position);
            unawaited(
              showPostDetailSheet(context, post).whenComplete(() {
                if (bloc.state.selectedId == post.id) {
                  bloc.add(const MapPostSelected(null));
                }
              }),
            );
          },
        ),
      ],
      child: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: defaultMapCenter,
              initialZoom: defaultMapZoom,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              backgroundColor: AppColors.pavement,
              interactionOptions: InteractionOptions(
                flags: _northLocked
                    ? InteractiveFlag.all & ~InteractiveFlag.rotate
                    : InteractiveFlag.all,
              ),
              onTap: (_, _) => bloc.add(const MapPostSelected(null)),
              onMapEvent: (event) {
                _rotation.value = event.camera.rotation;
                if (event is MapEventMoveEnd ||
                    event is MapEventFlingAnimationEnd ||
                    event is MapEventDoubleTapZoomEnd) {
                  _reportCamera(bloc, event.camera);
                }
              },
            ),
            children: [
              const OsmTileLayer(),
              BlocSelector<MapBloc, MapState, LatLng?>(
                selector: (state) => state.userPosition,
                builder: (_, user) => user == null
                    ? const SizedBox.shrink()
                    : _UserLayers(position: user),
              ),
              BlocBuilder<MapBloc, MapState>(
                // The list is replaced, never mutated, when posts are fetched.
                buildWhen: (prev, curr) =>
                    !identical(prev.posts, curr.posts) ||
                    prev.now != curr.now ||
                    prev.selectedId != curr.selectedId,
                builder: (_, state) => MapPostsLayer(
                  posts: state.activePosts,
                  now: state.now,
                  selectedId: state.selectedId,
                  onPostTap: (post) {
                    unawaited(HapticFeedback.selectionClick());
                    bloc.add(MapPostSelected(post.id));
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: top + AppSpacing.sm,
            left: AppSpacing.cozy,
            right: AppSpacing.cozy,
            child: BlocBuilder<MapBloc, MapState>(
              buildWhen: (prev, curr) =>
                  prev.regionName != curr.regionName ||
                  prev.pigeonsInView != curr.pigeonsInView ||
                  prev.userInView != curr.userInView ||
                  prev.now != curr.now,
              builder: (context, state) => MapHeader(
                city: state.regionName ?? '…',
                pigeonCount: state.pigeonsInView,
                aroundYou: state.userInView,
                // TODO(profile): read points/initial from the profile feature.
                points: NumberFormat.decimalPattern(
                  Localizations.localeOf(context).toString(),
                ).format(_placeholderPoints),
                initial: 'C',
                onProfileTap: () => context.go(AppRoutes.profile),
              ),
            ),
          ),
          BlocBuilder<MapBloc, MapState>(
            buildWhen: (prev, curr) =>
                prev.status != curr.status ||
                prev.errorMessage != curr.errorMessage,
            builder: (_, state) => switch (state.status) {
              MapStatus.loading => const Center(child: PfLoadingIndicator()),
              MapStatus.failure => Center(
                child: PfErrorState(
                  message: state.errorMessage ?? l10n.mapLoadError,
                  actionLabel: l10n.retry,
                  onAction: () => bloc.add(const MapStarted()),
                ),
              ),
              MapStatus.success => const SizedBox.shrink(),
            },
          ),
          Positioned(
            right: AppSpacing.cozy,
            bottom: bottom + _overlayGap,
            child: BlocSelector<MapBloc, MapState, LatLng?>(
              selector: (state) => state.userPosition,
              builder: (_, user) => MapControls(
                rotation: _rotation,
                northLocked: _northLocked,
                onToggleNorthLock: () => _toggleNorthLock(bloc),
                onRecenter: user == null
                    ? null
                    : () => _flyTo(bloc, center: user, zoom: _recenterZoom),
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.sm,
            bottom: bottom + AppSpacing.compact,
            child: const OsmAttribution(),
          ),
        ],
      ),
    );
  }
}

/// The user's dot and the circle they can post within.
class const _UserLayers({required final LatLng position})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CircleLayer(
          circles: [
            CircleMarker(
              point: position,
              radius: captureRadiusMeters,
              useRadiusInMeter: true,
              color: AppColors.iridescent.withAlpha(_captureFillAlpha),
              borderColor: AppColors.iridescent,
              borderStrokeWidth: _captureBorderWidth,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: position,
              width: MapUserDot.size,
              height: MapUserDot.size,
              child: const MapUserDot(),
            ),
          ],
        ),
      ],
    );
  }
}
