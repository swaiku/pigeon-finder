import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/events/posts_changes.dart';
import '../../../map/domain/entities/region_level.dart';
import '../../../map/domain/repositories/region_repository.dart';
import '../../domain/entities/new_post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';

class const PostRepositoryImpl(
  final SupabasePostDataSource _dataSource,
  final RegionRepository _regions,
  final PostsChanges _changes,
) implements PostRepository {
  /// `file_size_limit` of the `photos` bucket.
  static const maxPhotoBytes = 5 * 1024 * 1024;

  /// Window of the `max_posts_per_hour` limit.
  static const _rateLimitWindow = Duration(hours: 1);

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
      final description = post.description?.trim();
      final path = await _dataSource.uploadPhoto(file);
      // Known limitation: if the insert fails, the uploaded photo stays
      // orphaned, since clients cannot delete from the bucket.
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
