import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../post/data/datasources/post_remote_data_source.dart';

/// Source of the user's profile. Throws `PostgrestException` or
/// `StorageException` when a call is rejected.
abstract interface class ProfileRemoteDataSource {
  /// `username` and `avatar_path` of the signed-in user's `profiles` row.
  Future<Map<String, dynamic>> profileRow();

  /// Number of posts the user liked.
  Future<int> likesGiven();

  /// Uploads [file] as a new avatar and returns its path in the bucket.
  Future<String> uploadAvatar(File file);

  Future<void> setAvatarPath(String path);

  Future<void> deleteAvatar(String path);

  /// Temporary download URL of [path] (the bucket is private).
  Future<String> signUrl(String path);
}

class const SupabaseProfileDataSource(final SupabaseClient _client)
    implements ProfileRemoteDataSource {
  static const _urlLifetime = Duration(hours: 1);

  static const _uuid = Uuid();

  String get _userId => _client.auth.currentUser!.id;

  StorageFileApi get _photos =>
      _client.storage.from(SupabasePostDataSource.bucket);

  @override
  Future<Map<String, dynamic>> profileRow() => _client
      .from('profiles')
      .select('username, avatar_path')
      .eq('id', _userId)
      .single();

  // The likes_select policy only returns the user's own likes.
  @override
  Future<int> likesGiven() => _client.from('likes').count(CountOption.exact);

  /// At the root of the user's folder, where the storage policies and
  /// delete-account expect it.
  @override
  Future<String> uploadAvatar(File file) async {
    final path = '$_userId/avatar-${_uuid.v4()}.jpg';
    await _photos.upload(
      path,
      file,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );
    return path;
  }

  @override
  Future<void> setAvatarPath(String path) =>
      _client.from('profiles').update({'avatar_path': path}).eq('id', _userId);

  @override
  Future<void> deleteAvatar(String path) => _photos.remove([path]);

  @override
  Future<String> signUrl(String path) =>
      _photos.createSignedUrl(path, _urlLifetime.inSeconds);
}
