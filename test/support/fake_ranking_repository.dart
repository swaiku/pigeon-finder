import 'package:latlong2/latlong.dart';
import 'package:pigeon_finder/core/error/failures.dart';
import 'package:pigeon_finder/features/ranking/domain/entities/ranking_entry.dart';
import 'package:pigeon_finder/features/ranking/domain/repositories/ranking_repository.dart';

/// Returns [byScope], or throws [failure] when set. Records each call.
class FakeRankingRepository implements RankingRepository {
  FakeRankingRepository([this.byScope = const {}]);

  Map<RankingScope, List<RankingEntry>> byScope;
  Failure? failure;
  final calls = <(RankingScope, LatLng?, String?)>[];

  @override
  Future<List<RankingEntry>> getLeaderboard(
    RankingScope scope, {
    LatLng? around,
    String? countryCode,
  }) async {
    calls.add((scope, around, countryCode));
    if (failure case final f?) throw f;
    return byScope[scope] ?? const [];
  }
}
