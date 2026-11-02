import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/error/failures.dart';
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
    _clock = Timer.periodic(
      _clockTick,
      (_) => add(MapClockTicked(DateTime.now())),
    );
  }

  final PostsRepository _posts;
  final LocationRepository _location;
  final RegionRepository _regions;
  StreamSubscription<LatLng>? _positionSub;
  late final Timer _clock;

  /// Where the posts on the map were last fetched around.
  LatLng? _postsAnchor;

  static const _geocodeDebounce = Duration(milliseconds: 500);

  /// How often the expiry of the posts is checked.
  static const _clockTick = Duration(seconds: 30);

  /// Distance walked before the posts are fetched again around the user.
  static const _refreshDistance = 400.0; // meters

  @override
  Future<void> close() {
    _clock.cancel();
    unawaited(_positionSub?.cancel());
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
      final posts = await _posts.getActivePosts(around: center);
      _postsAnchor = center;
      final region = await _regionName(center, state.regionLevel);
      emit(
        state.copyWith(
          status: MapStatus.success,
          errorMessage: () => null,
          posts: posts,
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
      final posts = await _posts.getActivePosts(around: event.position);
      _postsAnchor = event.position;
      emit(state.copyWith(posts: posts));
    } on Failure {
      // Keep the posts already on the map.
    }
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
