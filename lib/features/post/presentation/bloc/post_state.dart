part of 'post_cubit.dart';

enum PostStatus { idle, locating, publishing, success, failure }

enum PostError {
  locationDenied,
  locationUnavailable,
  network,
  rateLimited,
  tooLarge,
  unknown,
}

final class const PostState({
  final PostStatus status = PostStatus.idle,
  final LatLng? position,
  final PostError? error,
}) extends Equatable {
  /// Whether a publish is running.
  bool get isBusy => status == PostStatus.publishing;

  PostState copyWith({
    PostStatus? status,
    LatLng? position,
    PostError? Function()? error,
  }) => PostState(
    status: status ?? this.status,
    position: position ?? this.position,
    error: error != null ? error() : this.error,
  );

  @override
  List<Object?> get props => [status, position, error];
}
