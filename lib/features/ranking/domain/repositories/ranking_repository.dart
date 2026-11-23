import '../entities/ranking_entry.dart';

/// Source of the leaderboard. Implementations throw a `Failure` (see
/// core/error/failures.dart) when it cannot be loaded.
abstract interface class RankingRepository {
  /// Best players of [scope], best first, plus the user's own row when they
  /// are not among them. [zone] names the city or country, as stored on the
  /// posts; it is ignored for [RankingScope.world].
  Future<List<RankingEntry>> getLeaderboard(RankingScope scope, {String? zone});
}
