part of 'post_cubit.dart';

enum PostStatus { idle, locating, publishing, success, failure }

/// The on-device count of the photo being reviewed.
enum AnalysisStatus { none, running, done, failed }

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
  final AnalysisStatus analysis = AnalysisStatus.none,
  final DetectionResult? detection,
}) extends Equatable {
  /// Whether a publish is running.
  bool get isBusy => status == PostStatus.publishing;

  PostState copyWith({
    PostStatus? status,
    LatLng? position,
    PostError? Function()? error,
    AnalysisStatus? analysis,
    DetectionResult? Function()? detection,
  }) => PostState(
    status: status ?? this.status,
    position: position ?? this.position,
    error: error != null ? error() : this.error,
    analysis: analysis ?? this.analysis,
    detection: detection != null ? detection() : this.detection,
  );

  @override
  List<Object?> get props => [status, position, error, analysis, detection];
}
