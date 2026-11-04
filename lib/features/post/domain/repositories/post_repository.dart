import '../entities/new_post.dart';

/// Publishes posts. Implementations throw a `Failure` (see
/// core/error/failures.dart): `NetworkFailure`, `RateLimitFailure`,
/// `PhotoTooLargeFailure` or `ServerFailure`.
abstract interface class PostRepository {
  Future<void> publish(NewPost post);
}
