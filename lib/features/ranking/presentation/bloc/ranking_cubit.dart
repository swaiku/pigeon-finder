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

/// The leaderboard around the user, of their country or the world, reloaded
/// when [PostsChanges] signals a new post.
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

  /// The user's country on first load, null when unknown: the server then
  /// uses their latest post's.
  String? _countryCode;

  /// Locates the user on first call, then loads the current scope; whether
  /// it worked. A refresh that fails keeps the rows already shown.
  Future<bool> load() async {
    if (state.labels == null) {
      final labels = await _locate();
      if (isClosed) return false;
      emit(state.copyWith(labels: labels));
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
        countryCode: _countryCode,
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

  /// Reads the country code used to filter, and the city and
  /// country names shown on the scopes. Each one may be missing.
  Future<Map<RankingScope, String>> _locate() async {
    final position = await _orNull(_location.getUserPosition());
    if (position == null) return const {};
    final (code, city, country) = await (
      _orNull(_regions.getCountryCode(position)),
      _orNull(_regions.getRegionName(position, RegionLevel.city)),
      _orNull(_regions.getRegionName(position, RegionLevel.country)),
    ).wait;
    _countryCode = code;
    return {RankingScope.city: ?city, RankingScope.country: ?country};
  }

  static Future<T?> _orNull<T>(Future<T> lookup) async {
    try {
      return await lookup;
    } on Failure catch (e) {
      debugPrint('Locating the ranking failed: ${e.message}');
      return null;
    }
  }

  @override
  Future<void> close() {
    unawaited(_changesSub?.cancel());
    return super.close();
  }
}
