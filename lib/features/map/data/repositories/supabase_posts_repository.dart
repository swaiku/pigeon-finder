import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/map_post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_remote_data_source.dart';

/// Posts read from Supabase: the last 24 h around a point, or all the user's
/// own.
class SupabasePostsRepository(final PostsRemoteDataSource _dataSource)
    implements PostsRepository {
  /// Search radius around the user, in meters.
  static const radiusMeters = 5000;

  /// Re-sign before the 1 h URL lifetime runs out.
  static const _urlMaxAge = Duration(minutes: 50);

  /// photo_path → signed URL. Reusing the same URL lets the image cache
  /// (keyed by URL) skip re-downloading photos on every fetch.
  final _signedUrls = <String, ({String url, DateTime signedAt})>{};

  /// Page size of `my_posts`, the most the RPC returns per call.
  static const myPostsPageSize = 100;

  @override
  Future<List<MapPost>> getActivePosts({required LatLng around}) => _load(
    () => _dataSource.postsAround(
      latitude: around.latitude,
      longitude: around.longitude,
      radiusMeters: radiusMeters,
    ),
  );

  // shortcut: loads every post up front because the Pigeondex sorts on the
  // client, switch to paged loading per sort if users reach thousands of posts
  @override
  Future<List<MapPost>> getMyPosts() => _load(() async {
    final rows = <Map<String, dynamic>>[];
    DateTime? before;
    while (true) {
      final page = await _dataSource.myPosts(
        before: before,
        limit: myPostsPageSize,
      );
      rows.addAll(page);
      if (page.length < myPostsPageSize) return rows;
      before = DateTime.parse(page.last['created_at'] as String);
    }
  });

  /// Fetches rows, signs their photos and maps them, turning errors into
  /// failures.
  Future<List<MapPost>> _load(
    Future<List<Map<String, dynamic>>> Function() fetch,
  ) async {
    try {
      final rows = await fetch();
      final now = DateTime.now();
      bool needsSigning(String path) {
        final cached = _signedUrls[path];
        return cached == null || now.difference(cached.signedAt) > _urlMaxAge;
      }

      final fresh = await _dataSource.signPhotoUrls([
        for (final row in rows)
          if (needsSigning(row['photo_path'] as String))
            row['photo_path'] as String,
      ]);
      for (final MapEntry(:key, :value) in fresh.entries) {
        _signedUrls[key] = (url: value, signedAt: now);
      }
      return [
        for (final row in rows)
          if (_signedUrls[row['photo_path']]?.url case final url?)
            fromRow(row, url),
      ];
    } on SocketException catch (e) {
      throw NetworkFailure(e.message);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } on StorageException catch (e) {
      throw ServerFailure(e.message);
    } on Exception catch (e) {
      // Offline errors reach us wrapped in the http client's exception.
      throw NetworkFailure(e.toString());
    }
  }

  /// Maps a `posts_around` or `my_posts` row to a [MapPost].
  static MapPost fromRow(Map<String, dynamic> row, String photoUrl) => MapPost(
    id: row['id'] as String,
    user: row['username'] as String,
    place: row['city'] as String? ?? '',
    photoUrl: photoUrl,
    position: LatLng(
      (row['latitude'] as num).toDouble(),
      (row['longitude'] as num).toDouble(),
    ),
    createdAt: DateTime.parse(row['created_at'] as String),
    count: (row['pigeon_count'] as num).toInt(),
    points: (row['points'] as num).toInt(),
    coos: (row['coos'] as num).toInt(),
    reports: (row['reports'] as num).toInt(),
    mine: row['mine'] as bool? ?? false,
    description: row['description'] as String?,
  );
}
