import 'package:latlong2/latlong.dart';

import '../entities/ranking_entry.dart';

/// Source of the leaderboard. Implementations throw a `Failure` (see
/// core/error/failures.dart) when it cannot be loaded.
abstract interface class RankingRepository {
  /// Best players of [scope], best first, plus the user's own row when they
  /// are not among them. [around] centers [RankingScope.nearby] and
  /// [RankingScope.city]; [countryCode] (ISO 3166-1 alpha-2) picks
  /// [RankingScope.country]. When either is null the server falls back on
  /// the user's latest post.
  Future<List<RankingEntry>> getLeaderboard(
    RankingScope scope, {
    LatLng? around,
    String? countryCode,
  });
}
