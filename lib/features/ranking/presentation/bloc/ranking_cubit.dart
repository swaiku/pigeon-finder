import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/events/posts_changes.dart';
import '../../../map/domain/entities/region_level.dart';
import '../../../map/domain/repositories/location_repository.dart';
import '../../../map/domain/repositories/region_repository.dart';
import '../../domain/entities/ranking_entry.dart';
import '../../domain/repositories/ranking_repository.dart';

part 'ranking_state.dart';

/// The leaderboard of the user's city, country or the world, reloaded when
/// [PostsChanges] signals a new post.
class RankingCubit extends Cubit<RankingState> {
  RankingCubit({
    required this._ranking,
    required this._location,
    required this._regions,
    PostsChanges? changes,
  }) : super(const RankingState()) {
    _changesSub = changes?.stream.listen((_) => unawaited(load()));
  }

  final RankingRepository _ranking;
  final LocationRepository _location;
  final RegionRepository _regions;
  StreamSubscription<void>? _changesSub;

  /// Names the user's zones on first call, then loads the current scope;
  /// whether it worked. A refresh that fails keeps the rows already shown.
  Future<bool> load() async {
    if (state.zones == null) {
      final zones = await _resolveZones();
      if (isClosed) return false;
      // Without a city (no location), open on the world.
      final scope = zones.containsKey(state.scope)
          ? state.scope
          : RankingScope.world;
      emit(state.copyWith(zones: zones, scope: scope));
    }
    return _fetch(state.scope);
  }

  Future<bool> setScope(RankingScope scope) {
    if (scope == state.scope && state.status == RankingStatus.ready) {
      return Future.value(true);
    }
    emit(state.copyWith(scope: scope, status: RankingStatus.loading));
    return _fetch(scope);
  }

  Future<bool> _fetch(RankingScope scope) async {
    if (state.status != RankingStatus.ready) {
      emit(state.copyWith(status: RankingStatus.loading));
    }
    try {
      final entries = await _ranking.getLeaderboard(
        scope,
        zone: state.zones?[scope],
      );
      // The user switched scope while this one loaded.
      if (isClosed || scope != state.scope) return false;
      emit(state.copyWith(status: RankingStatus.ready, entries: entries));
      return true;
    } on Failure catch (e) {
      debugPrint('Loading the ranking failed: ${e.message}');
      if (!isClosed &&
          scope == state.scope &&
          state.status != RankingStatus.ready) {
        emit(state.copyWith(status: RankingStatus.failure));
      }
      return false;
    }
  }

  /// City and country names of the user's position, as the posts store them.
  /// Empty when the position or the names are unavailable.
  Future<Map<RankingScope, String>> _resolveZones() async {
    try {
      final position = await _location.getUserPosition();
      final (city, country) = await (
        _regions.getRegionName(position, RegionLevel.city),
        _regions.getRegionName(position, RegionLevel.country),
      ).wait;
      return {RankingScope.city: city, RankingScope.country: country};
    } on Failure catch (e) {
      debugPrint('Locating the ranking zones failed: ${e.message}');
      return const {};
    } on ParallelWaitError<Object?, Object?> {
      // A name lookup failed: the record's `wait` wraps the Failure.
      return const {};
    }
  }

  @override
  Future<void> close() {
    unawaited(_changesSub?.cancel());
    return super.close();
  }
}
