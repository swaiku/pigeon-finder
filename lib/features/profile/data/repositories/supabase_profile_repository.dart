import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

/// The profile read from and written to Supabase.
class const SupabaseProfileRepository(final ProfileRemoteDataSource _dataSource)
    implements ProfileRepository {
  @override
  Future<Profile> getProfile() => _guard(() async {
    final row = await _dataSource.profileRow();
    final avatarPath = row['avatar_path'] as String?;
    return Profile(
      username: row['username'] as String,
      avatarUrl: avatarPath == null
          ? null
          : await _dataSource.signUrl(avatarPath),
      likesGiven: await _dataSource.likesGiven(),
    );
  });

  @override
  Future<String> setAvatar(File photo) => _guard(() async {
    final old = (await _dataSource.profileRow())['avatar_path'] as String?;
    final path = await _dataSource.uploadAvatar(photo);
    try {
      await _dataSource.setAvatarPath(path);
    } on Exception {
      await _deleteQuietly(path);
      rethrow;
    }
    if (old != null) await _deleteQuietly(old);
    return _dataSource.signUrl(path);
  });

  // shortcut: a failed delete leaves an unreachable file behind until
  // delete-account clears the folder, add a cleanup job if it piles up
  Future<void> _deleteQuietly(String path) async {
    try {
      await _dataSource.deleteAvatar(path);
    } on Exception catch (e) {
      debugPrint('Deleting the avatar $path failed: $e');
    }
  }

  /// Runs [call], turning errors into failures.
  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
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
}
