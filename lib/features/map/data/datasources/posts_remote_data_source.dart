import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../post/data/datasources/post_remote_data_source.dart';

/// Source of the posts shown on the map. Throws `PostgrestException` or
/// `StorageException` when a call is rejected.
abstract interface class PostsRemoteDataSource {
  /// Rows of the `posts_around` RPC: posts less than 24 h old near a point.
  Future<List<Map<String, dynamic>>> postsAround({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  });

  /// Temporary download URL of each photo path (the bucket is private),
  /// keyed by path. Paths that could not be signed are left out.
  Future<Map<String, String>> signPhotoUrls(List<String> paths);
}

class const SupabasePostsDataSource(final SupabaseClient _client)
    implements PostsRemoteDataSource {
  /// The repository caches URLs and re-signs them before this runs out.
  static const _urlLifetime = Duration(hours: 1);

  @override
  Future<List<Map<String, dynamic>>> postsAround({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    final rows = await _client.rpc<List<dynamic>>(
      'posts_around',
      params: {'lat': latitude, 'lng': longitude, 'radius_m': radiusMeters},
    );
    return rows.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, String>> signPhotoUrls(List<String> paths) async {
    if (paths.isEmpty) return const {};
    final results = await _client.storage
        .from(SupabasePostDataSource.bucket)
        .createSignedUrlsResult(paths, _urlLifetime.inSeconds);
    return {
      for (final r in results)
        if (r case SignedUrlSuccess(:final path, :final signedUrl))
          path: signedUrl,
    };
  }
}
