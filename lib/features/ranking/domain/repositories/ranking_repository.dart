import '../entities/ranking_entry.dart';

/// Source of the leaderboard. Implementations throw a `Failure` (see
/// core/error/failures.dart) when it cannot be loaded.
abstract interface class RankingRepository {
  /// Best players of [scope], best first, plus the user's own row when they
  /// are not among them. The server centers [RankingScope.nearby] and
  /// [RankingScope.city] on the user's latest post, never on a point the
  /// client picks, so nobody can probe where others posted. [countryCode]
  /// (ISO 3166-1 alpha-2) picks [RankingScope.country], or the latest
  /// post's country when null.
  Future<List<RankingEntry>> getLeaderboard(
    RankingScope scope, {
    String? countryCode,
  });
}
