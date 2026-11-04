import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/events/posts_changes.dart';
import '../../../map/domain/entities/region_level.dart';
import '../../../map/domain/repositories/region_repository.dart';
import '../../domain/entities/new_post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepositoryImpl(
  final SupabasePostDataSource _dataSource,
  final RegionRepository _regions,
  final PostsChanges _changes,
) implements PostRepository {
  /// `file_size_limit` of the `photos` bucket.
  static const maxPhotoBytes = 5 * 1024 * 1024;

  /// Window of the `max_posts_per_hour` limit.
  static const _rateLimitWindow = Duration(hours: 1);

  /// Local photo path → bucket path of photos uploaded but not yet linked to
  /// a post, so a retry reuses the upload instead of orphaning a new one.
  final _uploadedPaths = <String, String>{};

  @override
  Future<void> publish(NewPost post) async {
    final file = File(post.photoPath);
    try {
      if (await file.length() > maxPhotoBytes) {
        throw const PhotoTooLargeFailure('Photo above 5 MB');
      }
      final (city, region, country) = await (
        _regionName(post, RegionLevel.city),
        _regionName(post, RegionLevel.region),
        _regionName(post, RegionLevel.country),
      ).wait;
      // The field counts graphemes but Postgres' char_length counts code
      // points (an emoji family is 1 vs 5), so cap on code points here.
      final trimmed = post.description?.trim();
      final description = trimmed == null
          ? null
          : String.fromCharCodes(
              trimmed.runes.take(NewPost.maxDescriptionLength),
            );
      final path = _uploadedPaths[post.photoPath] ??=
          await _dataSource.uploadPhoto(file);
      // If the insert fails, the upload is kept for the next retry. It stays
      // orphaned only if the user gives up, since clients cannot delete from
      // the bucket.
      await _dataSource.insertPost(
        photoPath: path,
        latitude: post.position.latitude,
        longitude: post.position.longitude,
        pigeonCount: post.pigeonCount,
        description: (description?.isEmpty ?? true) ? null : description,
        city: city,
        region: region,
        country: country,
      );
      _uploadedPaths.remove(post.photoPath);
    } on SocketException catch (e) {
      throw NetworkFailure(e.message);
    } on StorageException catch (e) {
      if (e.statusCode == '413') throw PhotoTooLargeFailure(e.message);
      throw ServerFailure(e.message);
    } on PostgrestException catch (e) {
      if (e.message.contains('rate_limit_exceeded')) {
        throw RateLimitFailure(e.message, _rateLimitWindow);
      }
      throw ServerFailure(e.message);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on FileSystemException catch (e) {
      throw ServerFailure('Could not read the photo: ${e.message}');
    } on Failure {
      rethrow;
    } on Exception catch (e) {
      // Offline errors reach us wrapped in the http client's exception.
      final message = e.toString();
      if (message.contains('SocketException') ||
          message.contains('Failed host lookup')) {
        throw NetworkFailure(message);
      }
      throw ServerFailure(message);
    }
    _changes.notify();
  }

  /// Only labels the post: a missing name never blocks publishing.
  Future<String?> _regionName(NewPost post, RegionLevel level) async {
    try {
      return await _regions.getRegionName(post.position, level);
    } on Failure {
      return null;
    }
  }
}
