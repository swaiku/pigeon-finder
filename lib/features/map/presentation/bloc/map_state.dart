part of 'map_bloc.dart';

enum MapStatus { loading, success, failure }

final class MapState extends Equatable {
  MapState({
    required this.now,
    this.status = MapStatus.loading,
    this.posts = const [],
    this.userPosition,
    this.selectedId,
    this.errorMessage,
    this.center,
    this.visibleBounds,
    this.regionName,
    this.regionLevel = RegionLevel.city,
  });

  /// Clock the expiry of the posts is read against.
  final DateTime now;
  final MapStatus status;

  /// Posts as last fetched, some of which may have expired since.
  final List<MapPost> posts;
  final LatLng? userPosition;
  final String? selectedId;
  final String? errorMessage;
  final LatLng? center;

  /// Part of the map on screen, once the camera has moved.
  final LatLngBounds? visibleBounds;
  final String? regionName;
  final RegionLevel regionLevel;

  /// [posts] that have not expired yet.
  late final List<MapPost> activePosts = [
    for (final p in posts)
      if (p.timeLeft(now: now) > Duration.zero) p,
  ];

  /// Pigeons in the part of the map on screen; all of them until the camera
  /// has moved for the first time.
  late final int pigeonsInView = activePosts
      .where((p) => visibleBounds?.contains(p.position) ?? true)
      .fold(0, (sum, p) => sum + p.count);

  /// Whether the user is in the part of the map on screen.
  bool get userInView =>
      userPosition != null && (visibleBounds?.contains(userPosition!) ?? true);

  MapPost? get selected {
    for (final p in activePosts) {
      if (p.id == selectedId) return p;
    }
    return null;
  }

  /// A nullable field that can be cleared takes a function: `() => null`
  /// clears it, omitting it keeps the current value.
  MapState copyWith({
    DateTime? now,
    MapStatus? status,
    List<MapPost>? posts,
    LatLng? userPosition,
    String? Function()? selectedId,
    String? Function()? errorMessage,
    LatLng? center,
    LatLngBounds? visibleBounds,
    String? regionName,
    RegionLevel? regionLevel,
  }) {
    return MapState(
      now: now ?? this.now,
      status: status ?? this.status,
      posts: posts ?? this.posts,
      userPosition: userPosition ?? this.userPosition,
      selectedId: selectedId != null ? selectedId() : this.selectedId,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      center: center ?? this.center,
      visibleBounds: visibleBounds ?? this.visibleBounds,
      regionName: regionName ?? this.regionName,
      regionLevel: regionLevel ?? this.regionLevel,
    );
  }

  @override
  List<Object?> get props => [
    now,
    status,
    posts,
    userPosition,
    selectedId,
    errorMessage,
    center,
    visibleBounds,
    regionName,
    regionLevel,
  ];
}
