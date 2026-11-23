import 'package:supabase_flutter/supabase_flutter.dart';

/// Throws `PostgrestException` when a call is rejected.
abstract interface class RankingRemoteDataSource {
  /// Rows of the `leaderboard` RPC.
  Future<List<Map<String, dynamic>>> leaderboard({
    required String scope,
    String? countryCode,
    required int limit,
  });
}

class const SupabaseRankingDataSource(final SupabaseClient _client)
    implements RankingRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> leaderboard({
    required String scope,
    String? countryCode,
    required int limit,
  }) async {
    final rows = await _client.rpc<List<dynamic>>(
      'leaderboard',
      params: {'scope': scope, 'country_iso': ?countryCode, 'lim': limit},
    );
    return rows.cast<Map<String, dynamic>>();
  }
}
