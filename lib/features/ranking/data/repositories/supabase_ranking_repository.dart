import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/ranking_entry.dart';
import '../../domain/repositories/ranking_repository.dart';
import '../datasources/ranking_remote_data_source.dart';

class const SupabaseRankingRepository(final RankingRemoteDataSource _dataSource)
    implements RankingRepository {
  /// Players listed above the user's own row.
  static const limit = 50;

  @override
  Future<List<RankingEntry>> getLeaderboard(
    RankingScope scope, {
    LatLng? around,
    String? countryCode,
  }) async {
    try {
      final rows = await _dataSource.leaderboard(
        scope: scope.name,
        latitude: around?.latitude,
        longitude: around?.longitude,
        countryCode: countryCode,
        limit: limit,
      );
      return [for (final row in rows) fromRow(row)];
    } on SocketException catch (e) {
      throw NetworkFailure(e.message);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } on Exception catch (e) {
      // Offline errors reach us wrapped in the http client's exception.
      throw NetworkFailure(e.toString());
    }
  }

  /// Maps a `leaderboard` row to a [RankingEntry].
  static RankingEntry fromRow(Map<String, dynamic> row) => RankingEntry(
    rank: (row['rank'] as num).toInt(),
    username: row['username'] as String,
    score: (row['score'] as num).toInt(),
    pigeons: (row['pigeons'] as num).toInt(),
    isMe: row['me'] as bool? ?? false,
    nextScore: (row['next_score'] as num?)?.toInt(),
    nextRank: (row['next_rank'] as num?)?.toInt(),
  );
}
