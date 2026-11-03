import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Supabase calls to publish a post. Throws `StorageException` or
/// `PostgrestException` when a call is rejected.
class const SupabasePostDataSource(final SupabaseClient _client) {
  static const bucket = 'photos';

  static const _uuid = Uuid();

  /// Uploads the JPEG into the user's folder (required by the storage and
  /// `posts_insert` policies) and returns its path in the bucket.
  Future<String> uploadPhoto(File file) async {
    final path = '${_client.auth.currentUser!.id}/${_uuid.v4()}.jpg';
    await _client.storage
        .from(bucket)
        .upload(
          path,
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return path;
  }

  /// `user_id`, `created_at` and `points` are set by the
  /// `posts_before_insert` trigger.
  Future<void> insertPost({
    required String photoPath,
    required double latitude,
    required double longitude,
    required int pigeonCount,
    String? description,
    String? city,
    String? region,
    String? country,
  }) => _client.from('posts').insert({
    'photo_path': photoPath,
    'description': description,
    // EWKT, cast to geography by PostgREST.
    'location': 'SRID=4326;POINT($longitude $latitude)',
    'pigeon_count': pigeonCount,
    'city': city,
    'region': region,
    'country': country,
  });
}
