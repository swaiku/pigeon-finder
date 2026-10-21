import 'dart:async';
import 'dart:math' as math;

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/map_defaults.dart';
import '../../domain/entities/map_post.dart';
import '../../domain/entities/region_level.dart';
import '../../domain/repositories/map_repository.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._repository) : super(const MapState()) {
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
  }

  final MapRepository _repository;
  StreamSubscription<LatLng>? _positionSub;

  /// Where the posts on the map were last fetched around.
  LatLng? _postsAnchor;

  /// Zoom the first region name is looked up at.
  static const _initialZoom = 14.0;

  /// Latitude limit of the web mercator projection, in degrees.
  static const _maxLatitude = 85.0;

  static const _halfWorldDegrees = 180;

  static const _geocodeDebounce = Duration(milliseconds: 500);

  /// Distance walked before the posts are fetched again around the user.
  static const _refreshDistance = 400.0; // meters

  @override
  Future<void> close() {
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
        position = await _repository.getUserPosition();
      } on Failure {
        position = null;
      }
      final center = position ?? defaultMapCenter;
      final posts = await _repository.getActivePosts(around: center);
      _postsAnchor = center;
      final region = await _regionName(
        center,
        state.regionLevel,
        zoom: _initialZoom,
      );
      emit(
        state.copyWith(
          status: MapStatus.success,
          posts: posts,
          userPosition: position,
          center: center,
          regionName: region,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: MapStatus.failure, errorMessage: f.message));
      return;
    }
    await _positionSub?.cancel();
    _positionSub = _repository.watchUserPosition().listen(
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
      final posts = await _repository.getActivePosts(around: event.position);
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
    emit(state.copyWith(center: event.center, regionLevel: level));
    try {
      final region = await _regionName(event.center, level, zoom: event.zoom);
      // Ignore the answer if the camera moved again in the meantime.
      if (state.center == event.center && state.regionLevel == level) {
        emit(state.copyWith(regionName: region));
      }
    } on Failure {
      // Keep showing the previous region name.
    }
  }

  /// Name of the zone that covers most of the view rather than the one under
  /// the exact center, which flips on a border or lands in a lake or the sea.
  /// The center and a point north and south of it vote; the center wins ties.
  Future<String> _regionName(
    LatLng center,
    RegionLevel level, {
    required double zoom,
  }) async {
    // About half a map tile, so the points stay inside the visible area.
    final dLat =
        _halfWorldDegrees / math.pow(2, zoom) * math.cos(center.latitudeInRad);
    final samples = [
      center,
      // The screen is taller than wide, so spread the points vertically.
      LatLng(
        (center.latitude + dLat).clamp(-_maxLatitude, _maxLatitude),
        center.longitude,
      ),
      LatLng(
        (center.latitude - dLat).clamp(-_maxLatitude, _maxLatitude),
        center.longitude,
      ),
    ];
    final names = await Future.wait(
      samples.map((p) async {
        try {
          return await _repository.getRegionName(p, level);
        } on Failure {
          return null;
        }
      }),
    );
    final votes = <String, int>{};
    for (final name in names.nonNulls) {
      votes[name] = (votes[name] ?? 0) + 1;
    }
    if (votes.isEmpty) throw const LocationFailure('No region name');
    // Map order is insertion order, so ties go to the earliest sample.
    return votes.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}
