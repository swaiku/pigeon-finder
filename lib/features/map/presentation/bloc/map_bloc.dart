import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/events/posts_changes.dart';
import '../../domain/entities/map_defaults.dart';
import '../../domain/entities/map_post.dart';
import '../../domain/entities/region_level.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/posts_repository.dart';
import '../../domain/repositories/region_repository.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required this._posts,
    required this._location,
    required this._regions,
    PostsChanges? changes,
  }) : super(MapState(now: DateTime.now())) {
    on<MapStarted>(_onStarted);
    // Debounced to spare the platform geocoder while the user keeps panning;
    // restartable drops a lookup still running when the camera moves again.
    on<MapCameraMoved>(
      _onCameraMoved,
      transformer: (events, mapper) => restartable<MapCameraMoved>()(
        events.debounce(_geocodeDebounce),
        mapper,
      ),
    );
    // Restartable: a fetch still running is stale once the user moved again.
    on<MapUserPositionChanged>(
      _onUserPositionChanged,
      transformer: restartable(),
    );
    on<MapPostSelected>(
      (event, emit) => emit(state.copyWith(selectedId: () => event.postId)),
    );
    on<MapClockTicked>((event, emit) => emit(state.copyWith(now: event.now)));
    on<MapPostsRefreshRequested>(_onRefresh, transformer: restartable());
    _changesSub = changes?.stream.listen(
      (_) => add(const MapPostsRefreshRequested()),
    );
    _clock = Timer.periodic(
      _clockTick,
      (_) => add(MapClockTicked(DateTime.now())),
    );
  }

  final PostsRepository _posts;
  final LocationRepository _location;
  final RegionRepository _regions;
  StreamSubscription<LatLng>? _positionSub;
  StreamSubscription<void>? _changesSub;
  late final Timer _clock;

  /// Where the posts on the map were last fetched around.
  LatLng? _postsAnchor;

  /// Id of the latest posts fetch; older ones are dropped when they finish.
  int _fetchId = 0;

  static const _geocodeDebounce = Duration(milliseconds: 500);

  /// How often the expiry of the posts is checked.
  static const _clockTick = Duration(seconds: 30);

  /// Distance walked before the posts are fetched again around the user.
  static const _refreshDistance = 400.0; // meters

  @override
  Future<void> close() {
    _clock.cancel();
    unawaited(_positionSub?.cancel());
    unawaited(_changesSub?.cancel());
    return super.close();
  }

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: MapStatus.loading));
    try {
      // The map is still useful without the user position (permission denied,
      // GPS off): fall back to the default center.
      LatLng? position;
      try {
        position = await _location.getUserPosition();
      } on Failure {
        position = null;
      }
      final center = position ?? defaultMapCenter;
      final posts = await _fetchPosts(center);
      final region = await _regionName(center, state.regionLevel);
      emit(
        state.copyWith(
          status: MapStatus.success,
          errorMessage: () => null,
          posts: posts ?? state.posts,
          userPosition: position,
          center: center,
          regionName: region,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: MapStatus.failure,
          errorMessage: () => f.message,
        ),
      );
      return;
    }
    await _positionSub?.cancel();
    _positionSub = _location.watchUserPosition().listen(
      (p) => add(MapUserPositionChanged(p)),
      onError: (_) {}, // Keep the last known position.
    );
  }

  Future<void> _onUserPositionChanged(
    MapUserPositionChanged event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(userPosition: event.position));
    final anchor = _postsAnchor;
    if (anchor == null ||
        const Distance()(anchor, event.position) < _refreshDistance) {
      return;
    }
    try {
      final posts = await _fetchPosts(event.position);
      if (posts != null) emit(state.copyWith(posts: posts));
    } on Failure {
      // Keep the posts already on the map.
    }
  }

  /// Refetches the posts around the user, e.g. after publishing.
  Future<void> _onRefresh(
    MapPostsRefreshRequested event,
    Emitter<MapState> emit,
  ) async {
    final anchor = state.userPosition ?? _postsAnchor;
    if (anchor == null) return; // Not started yet: MapStarted will fetch.
    try {
      final posts = await _fetchPosts(anchor);
      if (posts != null) emit(state.copyWith(posts: posts));
    } on Failure {
      // Keep the posts already on the map.
    }
  }

  /// Posts around [anchor], or null when a newer fetch started meanwhile:
  /// several handlers fetch concurrently, and the latest request wins.
  Future<List<MapPost>?> _fetchPosts(LatLng anchor) async {
    final id = ++_fetchId;
    final posts = await _posts.getActivePosts(around: anchor);
    if (id != _fetchId) return null;
    _postsAnchor = anchor;
    return posts;
  }

  Future<void> _onCameraMoved(
    MapCameraMoved event,
    Emitter<MapState> emit,
  ) async {
    final level = RegionLevel.fromZoom(event.zoom);
    emit(
      state.copyWith(
        center: event.center,
        regionLevel: level,
        visibleBounds: event.bounds,
      ),
    );
    final region = await _regionName(event.center, level);
    // Ignore the answer if the camera moved again in the meantime.
    if (region != null &&
        state.center == event.center &&
        state.regionLevel == level) {
      emit(state.copyWith(regionName: region));
    }
  }

  /// The zone is only a label: when it cannot be resolved (offline,
  /// throttled geocoder) the map keeps working and the previous name stays.
  Future<String?> _regionName(LatLng position, RegionLevel level) async {
    try {
      return await _regions.getRegionName(position, level);
    } on Failure {
      return null;
    }
  }
}
