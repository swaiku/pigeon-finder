import 'dart:io';

import '../entities/profile.dart';

/// The signed-in user's account. Implementations throw a `Failure` (see
/// core/error/failures.dart) when a call fails.
abstract interface class ProfileRepository {
  Future<Profile> getProfile();

  /// Uploads [photo] (a JPEG) as the new profile photo, replacing the old
  /// one, and returns its URL.
  Future<String> setAvatar(File photo);
}
