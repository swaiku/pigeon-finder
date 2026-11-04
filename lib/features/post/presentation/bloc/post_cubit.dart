import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/failures.dart';
import '../../../map/domain/repositories/location_repository.dart';
import '../../domain/entities/new_post.dart';
import '../../domain/repositories/post_repository.dart';

part 'post_state.dart';

/// New post: locates the user while they frame the shot, then publishes the
/// photo. The camera itself stays in the page; a failure shows up in the
/// state.
class PostCubit extends Cubit<PostState> {
  PostCubit({required this._posts, required this._location})
    : super(const PostState());

  final PostRepository _posts;
  final LocationRepository _location;

  /// Starts locating early so the position is ready when the user publishes.
  Future<void> prepare() async {
    await _locate();
  }

  /// Whether the post was published; the page closes on `true`.
  Future<bool> publish({required String photoPath, String? description}) async {
    if (state.isBusy) return false;
    final position = state.position ?? await _locate();
    if (position == null) return false;
    emit(state.copyWith(status: PostStatus.publishing, error: () => null));
    try {
      await _posts.publish(
        NewPost(
          photoPath: photoPath,
          position: position,
          description: description,
        ),
      );
      emit(state.copyWith(status: PostStatus.success));
      return true;
    } on Failure catch (e) {
      debugPrint('Publishing failed: ${e.message}');
      emit(
        state.copyWith(
          status: PostStatus.failure,
          error: () => switch (e) {
            RateLimitFailure() => PostError.rateLimited,
            PhotoTooLargeFailure() => PostError.tooLarge,
            NetworkFailure() => PostError.network,
            _ => PostError.unknown,
          },
        ),
      );
      return false;
    }
  }

  /// Clears the last error, e.g. when the user retakes the photo.
  void dismissError() =>
      emit(state.copyWith(status: PostStatus.idle, error: () => null));

  Future<LatLng?> _locate() async {
    emit(state.copyWith(status: PostStatus.locating, error: () => null));
    try {
      final position = await _location.getUserPosition();
      emit(state.copyWith(status: PostStatus.idle, position: position));
      return position;
    } on PermissionFailure {
      emit(
        state.copyWith(
          status: PostStatus.failure,
          error: () => PostError.locationDenied,
        ),
      );
    } on Failure catch (e) {
      debugPrint('Locating failed: ${e.message}');
      emit(
        state.copyWith(
          status: PostStatus.failure,
          error: () => PostError.locationUnavailable,
        ),
      );
    }
    return null;
  }
}
