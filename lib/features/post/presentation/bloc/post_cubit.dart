import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/failures.dart';
import '../../../detection/domain/entities/detection_result.dart';
import '../../../detection/domain/repositories/detection_repository.dart';
import '../../../map/domain/repositories/location_repository.dart';
import '../../domain/entities/new_post.dart';
import '../../domain/repositories/post_repository.dart';

part 'post_state.dart';

/// New post: locates the user while they frame the shot, counts the pigeons
/// of the photo on the device, then publishes it with that count. The camera
/// itself stays in the page; a failure shows up in the state.
class PostCubit extends Cubit<PostState> {
  PostCubit({
    required this._posts,
    required this._location,
    required this._detection,
  }) : super(const PostState());

  final PostRepository _posts;
  final LocationRepository _location;
  final DetectionRepository _detection;

  /// Starts locating early so the position is ready when the user publishes.
  Future<void> prepare() async {
    await _locate();
  }

  /// Counts and names the pigeons of the photo just taken.
  Future<void> analyse(String photoPath) async {
    emit(
      state.copyWith(analysis: AnalysisStatus.running, detection: () => null),
    );
    try {
      final result = await _detection.detect(photoPath);
      debugPrint(
        'Detection: ${result.count} birds in ${result.inferenceTime.inMilliseconds} ms',
      );
      if (isClosed) return;
      emit(
        state.copyWith(analysis: AnalysisStatus.done, detection: () => result),
      );
    } on Failure catch (e) {
      debugPrint('Detection failed: ${e.message}');
      if (!isClosed) emit(state.copyWith(analysis: AnalysisStatus.failed));
    }
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
          // shortcut: the posts table takes 1 to 10 pigeons, so a bigger
          // flock is published as 10 until the schema allows more.
          pigeonCount: (state.detection?.count ?? 1).clamp(
            1,
            NewPost.maxPigeonCount,
          ),
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

  /// Clears the last error and the count, e.g. when the user retakes the
  /// photo.
  void dismissError() => emit(
    state.copyWith(
      status: PostStatus.idle,
      error: () => null,
      analysis: AnalysisStatus.none,
      detection: () => null,
    ),
  );

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
